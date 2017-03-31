local BASH = BASH;
BASH.Registry = {};
BASH.Registry.Name = "Registry";
BASH.Registry.Vars = BASH.Registry.Vars or {};
BASH.Registry.Players = BASH.Registry.Players or {};
BASH.Registry.Queue = BASH.Registry.Queue or nil;
BASH.Registry.VarBuffer = BASH.Registry.VarBuffer or {};
BASH.Registry.LastVarUpdate = BASH.Registry.LastVarUpdate or 0;
BASH.Registry.Dependencies = {["SQL"] = SERVER};
local Player = FindMetaTable("Player");

function BASH.Registry:Init()
    /*
    **  Create Default Variables
    */

    BASH.Registry:NewVariable{
        Name = "BASHID",
        Type = "string",
        Default = "BASH_ID",
        Public = true,
        SQLTable = "bash_players"
    };

    BASH.Registry:NewVariable{
        Name = "SteamID",
        Type = "string",
        Default = "STEAM_ID",
        Public = true,
        SQLTable = "bash_players"
    };

    hook.Call("LoadVariables", BASH);
end

/*
**  BASH.Registry.NewVariable
**  Args: Variable Table Structure
**
**  Note: 'boolean' type variables must be registered with a
**  default value of 0 (false) or 1 (true).
**
**  Note: Public variables are sent to all connected clients,
**  while non-public variables are only sent to individual
**  clients. Keep in mind that all variables are sent to staff
**  members, regardless of whether or not they are public.
**
**  Note: The SQL Source Table argument is used to assign the
**  value a home table, i.e. the SQL table in which this
**  variable is saved in.
*/
function BASH.Registry:NewVariable(var)
    if !var.Name then return end;
    if SERVER and var.SQLTable then
        if !BASH.SQL.Tables[var.SQLTable] then
            MsgErr("[BASH.Registry:NewVariable(%s)]: This variable points to the SQL table '%s', which doesn't exist!", var.Name, var.SQLTable);
            return;
        end
    end

    self.Vars = self.Vars or {};
    if self.Vars[var.Name] then
        MsgErr("[BASH.Registry:NewVariable(%s)]: A variable with that name already exists!", var.Name);
        return;
    end

    var.Type = var.Type or "string";
    var.Default = var.Default or "";
    var.Public = var.Public or false;
    var.SQLTable = var.SQLTable or "bash_players";

    self.Vars[var.Name] = var;

    Player["Get" .. var.Name] = function(_self)
        if !checkply(_self) then return end;
        if !self.Players[_self:SteamID()] then
            MsgErr("[Player:Get%s()]: %s not registered! (%s)", var.Name, (CLIENT and "You're") or _self:Nick(), _self:SteamID());
            return;
        end

        return self.Players[_self:SteamID()][var.Name];
    end

    if SERVER then
        Player["Set" .. var.Name] = function(_self, val)
            if !checkply(_self) then return end;

            local steamID = _self:SteamID();
            if !self.Players[steamID] then
                MsgErr("[Player:Set%s(...)]: Player not registered! (%s/%s)", var.Name, _self:Nick(), steamID);
                return;
            end

            val = detype(val, var.Type);
            self.Players[steamID][var.Name] = val;

            if var.Public then
                self.VarBuffer = self.VarBuffer or {};
                self.VarBuffer[steamID] = self.VarBuffer[steamID] or {};
                self.VarBuffer[steamID][var.Name] = val;
                self.LastVarUpdate = SysTime();
            else
                _self.VarBuffer = _self.VarBuffer or {};
                _self.VarBuffer[var.Name] = val;
                _self.LastVarUpdate = SysTime();
            end
        end

        if var.SQLTable then
            if BASH.SQL.ColumnsConsolidated then
                local args = detype(var, "string");
                MsgErr("[BASH.Registry:NewVariable(%s)]: The database structure has already been consolidated! You must call this function earlier in order for this variable to be saved to the entered table.", args);
                return;
            end

            local index = #BASH.SQL.Tables[var.SQLTable].Struct + 1;
            BASH.SQL.Tables[var.SQLTable].Struct[index] = Format("`%s` %s %s", var.Name, SQL_TYPE[var.Type], ((var.Default != "" and " DEFAULT \'" .. var.Default .. "\'") or ""));
        end
    end
end

function Player:GetVars(vars)
    if !vars or #vars == 0 then return end;

    local vals = {};
    for index, var in ipairs(vars) do
        vals[index] = self["Get" .. var](self);
    end

    return unpack(vals);
end

function Player:SetVars(vars, vals)
    if !vars or #vars == 0 then return end;
    vals = vals or {};

    for index, var in ipairs(vars) do
        self["Set" .. var](self, vals[index]);
    end
end

if SERVER then
    hook.Add("Think", "BASH_HandleVarUpdateQueue", function()
        BASH.Registry.VarBuffer = BASH.Registry.VarBuffer or {};
        BASH.Registry.LastVarUpdate = BASH.Registry.LastVarUpdate or 0;
        if table.Count(BASH.Registry.VarBuffer) > 0 and SysTime() - BASH.Registry.LastVarUpdate > 0.5 then
            local ply;
            for steamID, varTab in pairs(BASH.Registry.VarBuffer) do
                ply = player.GetBySteamID(steamID);
                if !checkply(ply) then
                    BASH.Registry.VarBuffer[steamID] = nil;
                end
            end

            local broadcastPacket = vnet.CreatePacket("BASH_UPDATE_VAR");
            broadcastPacket:Table(BASH.Registry.VarBuffer);
            broadcastPacket:AddTargets(player.GetAll());
            broadcastPacket:Send();
            BASH.Registry.VarBuffer = {};
        end

        local steamID, curTab, curPacket;
        for _, ply in pairs(player.GetAll()) do
            if !ply.VarBuffer or table.Count(ply.VarBuffer) == 0 then continue end;

            ply.LastVarUpdate = ply.LastVarUpdate or 0;
            if SysTime() - ply.LastVarUpdate < 0.5 then continue end;

            steamID = ply:SteamID();
            for var, val in pairs(ply.VarBuffer) do
                BASH.Registry.VarBuffer[steamID][var] = val;
            end
            ply.VarBuffer = {};
        end
    end);

    function Player:Register(data, queued)
        if !checkply(self) then return end;
        if !BASH.Registry.Vars then return end;

    	if !BASH.Registry.Players then
    		BASH.Registry.Players = {};
    	end
        local steamID = self:SteamID();
    	if !BASH.Registry.Players[steamID] then
        	BASH.Registry.Players[steamID] = {};
    	end

        if !BASH.Registry.Queue then
            BASH.Registry.Queue = Queue:Create();
        end

        BASH.Registry.Queue:print();
        local nextPos = BASH.Registry.Queue:first();
    	if nextPos and nextPos != steamID then
            local index = BASH.Registry.Queue:enqueue(steamID);
            net.Start("BASH_REGISTRY_QUEUED");
                net.WriteInt(index, 8);
            net.Send(self);

    		self.SQLData = data;
    		return;
    	elseif !nextPos then
            BASH.Registry.Queue:enqueue(steamID);
        end

    	self.SQLData = data;
    	self:PushData();
    	self:PullData();

        net.Empty("BASH_PLAYER_LOADED", self);

    	self.Registered = true;
    	BASH.LastRegistered = steamID;
    end
    hook.Add("Think", "BASH_HandleRegistryQueue", function()
        if !BASH.Registry.Queue then
            BASH.Registry.Queue = Queue:Create();
        end
        if !BASH.Registry.Queue:first() then return end;
        if BASH.LastRegistered == BASH.Registry.Queue:first() then
            //  Get rid of the finished player.
            BASH.Registry.Queue:dequeue();

            local nextID = BASH.Registry.Queue:dequeue();
    		local ply = player.GetBySteamID(nextID);
    		if CheckPly(ply) and ply.SQLData then
    			ply:Register(ply.SQLData);
    		end

    		if BASH.Registry.Queue:len() > 1 then
    			for index, id in pairs(BASH.Registry.Queue:elem()) do
                    if index == 1 then continue end;
    				local ply = player.GetBySteamID(id);
    				if CheckPly(ply) then
                        local queuePacket = vnet.CreatePacket("BASH_REGISTRY_QUEUED");
                        queuePacket:Byte(index);
                        queuePacket:AddTargets(ply);
                        queuePacket:Send();
    				end
    			end
    		end
    	end
    end);

    //  Push To Registry
    function Player:PushData()
        MsgCon(color_green, false, "[PUSH] %s", self:Name());

    	for table, tableData in pairs(self.SQLData) do
    		for name, var in pairs(BASH.Registry.Vars) do
    			if tableData[name] and var.SQLTable == table then
    	        	self["Set" .. name](self, (tableData[name] == nil and !isbool(var.Default) and var.Default) or tableData[name]);
    			end
    	    end
    	end
    end

    //  Pull From Players
    function Player:PullData()
    	MsgCon(color_green, false, "[PULL] %s", self:Name());

        local pullTab = {};
    	local steamID, varTable;
    	for _, ply in pairs(player.GetAll()) do
    		if self != ply and ply.Registered then
    			steamID = ply:SteamID();
    			if !BASH.Players[steamID] then continue end;

                pullTab[steamID] = {};
    			for var, val in pairs(BASH.Players[steamID]) do
    				varTable = BASH.Registry.Vars[var];
    				if !varTable then continue end;

    				if varTable.Public or self:IsStaff() then
                        pullTab[steamID][var] = val;
    				end
    			end
    		end
    	end

        if table.Count(pullTab) > 0 then
            local packet = vnet.CreatePacket("BASH_UPDATE_VAR");
            packet:Table(pullTab);
            packet:AddTargets(self);
            packet:Send();
        end
    end
end

if CLIENT then
    /*
    **  Networking
    */
    net.Receive("BASH_PLAYER_LOADED", function(len)
        LP().Initialized = true;
        BASH.IntroStage = 2;
    end);

    /*
    vnet.Watch("BASH_REGISTRY_PROGRESS", function(data)
        LocalPlayer().RegistryProgress = data:Byte();
    end);
    */

    vnet.Watch("BASH_REGISTRY_QUEUED", function(data)
        LP().QueuePlace = data:Byte();
    end);

    vnet.Watch("BASH_UPDATE_VAR", function(data)
        local vars = data:Table();
        for steamID, varTab in pairs(vars) do
            BASH.Players[steamID] = BASH.Players[steamID] or {};
            for var, val in pairs(varTab) do
                BASH.Players[steamID][var] = val;
            end
        end
    end);
elseif SERVER then
    /*
    **  Networking
    */
    util.AddNetworkString("BASH_PLAYER_LOADED");
    util.AddNetworkString("BASH_REGISTRY_PROGRESS");
    util.AddNetworkString("BASH_REGISTRY_QUEUED");
    util.AddNetworkString("BASH_UPDATE_VAR");
end

BASH:RegisterLib(BASH.Registry);
