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

    BASH.Registry:AddVariable{
        Name = "BASHID",
        Type = "string",
        Default = "BASH_ID",
        Public = true,
        SQLTable = "bash_players"
    };

    BASH.Registry:AddVariable{
        Name = "SteamID",
        Type = "string",
        Default = "STEAM_ID",
        Public = true,
        SQLTable = "bash_players"
    };

    hook.Call("LoadVariables", BASH);
end

/*
**  BASH.Registry.AddVariable
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
function BASH.Registry:AddVariable(var)
    if !var.Name then return end;

    self.Vars = self.Vars or {};
    if self.Vars[var.Name] then
        MsgErr("[BASH.Registry.AddVariable] -> A variable with the name '%s' already exists!", var.Name);
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
            MsgErr("[Player.Get%s] -> %s not registered! (%s)", var.Name, (CLIENT and "You're") or _self:Nick(), _self:SteamID());
            return;
        end

        return self.Players[_self:SteamID()][var.Name];
    end

    if SERVER then
        Player["Set" .. var.Name] = function(_self, val)
            if !checkply(_self) then return end;

            local steamID = _self:SteamID();
            if !self.Players[steamID] then
                MsgErr("[Player.Set%s] -> Player not registered! (%s/%s)", var.Name, _self:Nick(), steamID);
                return;
            end

            val = detype(val, var.Type);
            self.Players[steamID][var.Name] = val;

            local packetString = {[steamID] = {[var.Name] = val}};
            packetString = von.serialize(packetString);
            local targets;
            if var.Public then
                targets = player.GetAll();
            else
                targets = _self;
            end
            vnet.SendString("BASH_UPDATE_VAR", packetString, targets);
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

function Player:SetVars(vars)
    if !checkply(self) then return end;
    if !varTab or table.IsEmpty(varTab) then return end;

    local steamID = self:SteamID();
    if !BASH.Registry.Players[steamID] then
        MsgErr("[Player.Set%s]: Player not registered! (%s/%s)", var.Name, self:Nick(), steamID);
        return;
    end

    local varTab, val;
    local pubString, privString = {[steamID] = {}}, {[steamID] = {}};
    for var, val in pairs(vars) do
        varTab = BASH.Registry.Vars[var];
        if !varTab then
            MsgErr("[Player.SetVars] -> No variable found under name '%s'!", var);
            continue;
        end
        //CONTINUE HERE
        val = detype(val, varTab.Type);
        BASH.Registry.Players[steamID][varTab.Name] = val;

        if varTab.Public then
            pubString[steamID][var.Name] = val;
        else
            privString[steamID][var.Name] = val;
        end
    end

    if !table.IsEmpty(pubString[steamID]) then
        pubString = von.serialize(pubString);
        vnet.SendString("BASH_UPDATE_VAR", pubString, player.GetAll());
    end
    if !table.IsEmpty(privString[steamID]) then
        privString = von.serialize(privString);
        vnet.SendString("BASH_UPDATE_VAR", privString, self);
    end
end

if SERVER then

    function Player:Register(data)
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

        local nextPos = BASH.Registry.Queue:first();
    	if nextPos and nextPos != steamID then
            BASH.Registry.Queue:enqueue(steamID);
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

        self.SQLDATA
        local index, vars, vals = 1;
		for name, var in pairs(BASH.Registry.Vars) do
			if self.SQLData[name] then
                vars[index] =
	        	self["Set" .. name](self, (tableData[name] == nil and !isbool(var.Default) and var.Default) or tableData[name]);
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
        local vars = data:String();
        vars = von.deserialize(vars);
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
