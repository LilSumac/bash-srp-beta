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

    // lol

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

    	self:PushData();
    	self:PullData();

        net.Empty("BASH_PLAYER_LOADED", self);

    	self.Registered = true;
    	BASH.LastRegistered = steamID;
    end
    hook.Add("Think", "BASH_HandleRegistryQueue", function()
        if !BASH.Registry.Queue then return end;
        if !BASH.Registry.Queue:first() then return end;
        if BASH.LastRegistered == BASH.Registry.Queue:first() then
            //  Get rid of the finished player.
            BASH.Registry.Queue:dequeue();

            local nextID = BASH.Registry.Queue:dequeue();
    		local ply = player.GetBySteamID(nextID);
    		if CheckPly(ply) and !ply.SQLData then
    			ply:SQLInit();
    		end

    		if BASH.Registry.Queue:len() >= 1 then
                local targets = {};
                local places = {};
    			for index, id in pairs(BASH.Registry.Queue:elem()) do
    				local ply = player.GetBySteamID(id);
    				if CheckPly(ply) then
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

    //  Push To Registry
    function Player:PushData()
        MsgCon(color_green, false, "[PUSH] %s", self:Name());

        local vars = {};
		for name, var in pairs(BASH.Registry.Vars) do
			if self.SQLData[name] then
                vars[var.Name] = (self.SQLData[name] == nil and var.Default) or self.SQLData[name];
			end
	    end
        self:SetVars(vars);
    end

    //  Pull From Players
    function Player:PullData()
    	MsgCon(color_green, false, "[PULL] %s", self:Name());

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
            pullTab = von.serialize(pullTab);
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
        local progress = data:String();
        MsgCon(color_sql, true, progress);
        // set data:String() to current message
    end);

    vnet.Watch("BASH_REGISTRY_QUEUED", function(data)
        local places = data:Table();
        local place = places[LP():SteamID()] or -1;
        MsgCon(color_sql, true, "You're in position %n for the registry queue.", place);
        LP().QueuePlace = place;
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
