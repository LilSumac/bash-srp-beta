local BASH = BASH;
BASH.Registry = {};
BASH.Registry.Name = "Registry";
BASH.Registry.Vars = BASH.Registry.Vars or {};
BASH.Registry.Globals = BASH.Registry.Globals or {};
BASH.Registry.Players = BASH.Registry.Players or {};
BASH.Registry.Queue = BASH.Registry.Queue or nil;
BASH.Registry.Dependencies = {["SQL"] = SERVER};
local Player = FindMetaTable("Player");

function BASH.Registry:Init()
    /*
    **  Create Default Variables
    */

    self:AddVariable{
        Name = "FirstLogin",
        Type = "number",
        Default = os.time,
        Public = true,
        SQLTable = "bash_players"
    };

    self:AddVariable{
        Name = "IsNewPlayer",
        Type = "boolean",
        Default = false,
        Public = true
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
    if !var.Name then return; end
    if var.ServerPersist and CLIENT then return; end

    self.Vars = self.Vars or {};
    if self.Vars[var.Name] then
        MsgErr("[BASH.Registry.AddVariable] -> A variable with the name '%s' already exists!", var.Name);
        return;
    end

    var.Type = var.Type or "string";
    var.Default = var.Default or "";
    var.Public = var.Public or false;

    if var.ServerPersist then
        var.IsGlobal = var.IsGlobal or false;
        var.IgnoreMap = var.IgnoreMap or false;
        self.Globals[var.Name] = BASH.Persist:Get(var.Name, var.Default, var.IsGlobal, var.IgnoreMap);
        return;
    end

    var.SQLTable = var.SQLTable or "";
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
            packetString = pon.encode(packetString);
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

function BASH.Registry:GetGlobal(name)
    return self.Globals[name];
end

function Player:GetVars(vars, asTab)
    if !vars or #vars == 0 then return end;

    local vals = {};
    for index, var in ipairs(vars) do
        vals[index] = self["Get" .. var](self);
    end

    if asTab then return vals;
    else return unpack(vals) end;
end

if CLIENT then

    function Player:RequestChange()
        // most likely wont be implemented cause
        // variable changes should be hard-coded
        // server-side for safety reasons
    end

    function Player:RequestChanges()
        // most likely wont be implemented cause
        // variable changes should be hard-coded
        // server-side for safety reasons
    end

elseif SERVER then

	function BASH.Registry:PushToColumns()
		for name, var in pairs(self.Vars) do
			if !var.SQLTable or var.SQLTable == "" then continue end;
			if !BASH.SQL.Tables[var.SQLTable] then
				MsgErr("[BASH.Registry.PushToColumns] -> No such SQL table '%s' exists for variable '%s'!", var.SQLTable, name);
				continue;
			end

			BASH.SQL:AddColumn(var.SQLTable, name, var.Type);
		end
	end

    function BASH.Registry:SetGlobal(name, val)
        if !self.Vars[name] then return; end
        if self.Globals[name] and type(val) != type(self.Globals[name]) then return end;
        if val == self.Globals[name] then return; end

        self.Globals[name] = val;
        local update = vnet.CreatePacket("BASH_UPDATE_GVAR");
        update:Table({[name] = val});
        update:AddTargets(player.GetAll());
        update:Send();
    end

    function Player:SetVars(vars)
        if !checkply(self) then return end;
        if !vars or table.IsEmpty(vars) then return end;

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

            val = detype(val, varTab.Type);
            BASH.Registry.Players[steamID][varTab.Name] = val;

            if varTab.Public then
                pubString[steamID][var] = val;
            else
                privString[steamID][var] = val;
            end
        end

        if !table.IsEmpty(pubString[steamID]) then
            pubString = pon.encode(pubString);
            vnet.SendString("BASH_UPDATE_VAR", pubString, player.GetAll());
        end
        if !table.IsEmpty(privString[steamID]) then
            privString = pon.encode(privString);
            vnet.SendString("BASH_UPDATE_VAR", privString, self);
        end
    end

    function Player:Register()
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

        BASH.Registry.Queue:enqueue(steamID);
        local nextPos = BASH.Registry.Queue:first();
    	if nextPos and nextPos != steamID then return; end

    	self:PushData();
    	self:PullData();

        hook.Call("OnRegister", BASH, self);

        net.Empty("BASH_PLAYER_LOADED", self);

    	self.Registered = true;
    	BASH.LastRegistered = steamID;
        PrintTable(BASH.Registry.Players)
    end
    hook.Add("Think", "BASH_HandleRegistryQueue", function()
        if !BASH.Registry.Queue then return end;
        if !BASH.Registry.Queue:first() then return end;
        if BASH.LastRegistered == BASH.Registry.Queue:first() then
            //  Get rid of the finished player.
            BASH.Registry.Queue:dequeue();

            local nextID = BASH.Registry.Queue:dequeue();
    		local ply = player.GetBySteamID(nextID);
    		if checkply(ply) and !ply.SQLData then
    			ply:SQLInit();
    		end

    		if BASH.Registry.Queue:len() >= 1 then
                local targets = {};
                local places = {};
    			for index, id in pairs(BASH.Registry.Queue:elem()) do
    				local ply = player.GetBySteamID(id);
    				if checkply(ply) then
                        targets[#targets + 1] = ply;
                        places[id] = index;
    				end
    			end
                local queuePacket = vnet.CreatePacket("BASH_REGISTRY_QUEUED");
                queuePacket:Table(places);
                queuePacket:AddTargets(targets);
                queuePacket:Send();
    		end
    	end
    end);

    //  Sync Globals
    function BASH.Registry:SyncGlobals(ply)
        ply = ply or player.GetAll();
        local update = vnet.CreatePacket("BASH_UPDATE_GVAR");
        update:Table(BASH.Registry.Globals);
        update:AddTargets(ply);
        update:Send();
    end

    //  Push To Registry
    function Player:PushData()
        MsgCon(color_darkgreen, false, "[PUSH] %s", self:Name());

        local vars = {};
		for name, var in pairs(BASH.Registry.Vars) do
			if self.SQLData[var.SQLTable] then
                vars[var.Name] = (self.SQLData[var.SQLTable][name] == nil and var.Default) or self.SQLData[var.SQLTable][name];
			end
	    end

        self:SetVars(vars);
    end

    //  Pull From Players
    function Player:PullData()
    	MsgCon(color_darkgreen, false, "[PULL] %s", self:Name());

        local pullTab, varTab = {};
        for steamID, vars in pairs(BASH.Registry.Players) do
            if steamID == self:SteamID() then continue end;

            pullTab[steamID] = {};
            for var, val in pairs(vars) do
                varTab = BASH.Registry.Vars[var];
                if !varTab then continue end;

                if varTab.Public or self:IsStaff() then
                    pullTab[steamID][var] = val;
                end
            end
        end

        if !table.IsEmpty(pullTab) then
            pullTab = pon.encode(pullTab);
            vnet.SendString("BASH_UPDATE_VAR", pullTab, self);
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

    vnet.Watch("BASH_REGISTRY_PROGRESS", function(data)
        PrintTable(data);
        local progress = data.Data;
        MsgN(progress)
        BASH.IntroMessage = progress;
    end);

    vnet.Watch("BASH_REGISTRY_QUEUED", function(data)
        local places = data.Data;
        local place = places[LP():SteamID()] or -1;
        MsgCon(color_sql, true, "You're in position %n for the registry queue.", place);
        BASH.IntroMessage = Fmt("You're in position %n for the registry queue.", place);
    end);

    vnet.Watch("BASH_UPDATE_VAR", function(data)
        local vars = data.Data;
        vars = pon.decode(vars);
        for steamID, varTab in pairs(vars) do
            BASH.Registry.Players[steamID] = BASH.Registry.Players[steamID] or {};
            for var, val in pairs(varTab) do
                BASH.Registry.Players[steamID][var] = val;
            end
        end
    end);

    vnet.Watch("BASH_UPDATE_GVAR", function(data)
        PrintTable(data)
        local vars = data.Data;
        for name, var in pairs(vars) do
            BASH.Registry.Globals[name] = var;
        end
    end);

elseif SERVER then
	/*
	**	BASH Hooks
	*/
	hook.Add("EditSQLTables", "BASH_InsertVariablesIntoSQL", function()
		BASH.Registry:PushToColumns();
	end);

    /*
    **  Networking
    */
    util.AddNetworkString("BASH_PLAYER_LOADED");
    util.AddNetworkString("BASH_REGISTRY_PROGRESS");
    util.AddNetworkString("BASH_REGISTRY_QUEUED");
    util.AddNetworkString("BASH_UPDATE_VAR");
    util.AddNetworkString("BASH_UPDATE_GVAR");

end

BASH:RegisterLib(BASH.Registry);
