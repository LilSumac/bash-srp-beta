local BASH = BASH;
BASH.Registry = {};
BASH.Registry.Name = "Registry";
BASH.Registry.Vars = {};
BASH.Registry.Players = {};
BASH.Registry.Queue = {};
BASH.Registry.Dependencies = {["SQL"] = SERVER};
local Player = FindMetaTable("Player");

function BASH.Registry:Init()
    /*
    **  Create Default Variables
    */

    BASH.Registry:NewVariable("BASHID",     "string", "BASH_ID",    true, "bash_players");
    BASH.Registry:NewVariable("SteamName",  "string", "STEAM_NAME", true, "bash_players");
    BASH.Registry:NewVariable("SteamID",    "string", "STEAM_ID",   true, "bash_players");
    BASH.Registry:NewVariable("Rank",       "string", "default",    true, "bash_players");
    hook.Call("LoadVariables");
end

/*
**  BASH.Registry.NewVariable
**  Args: Name, Type, Default Value, Is Public, SQL Source Table
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
function BASH.Registry:NewVariable(name, type, default, public, sqlTable)
    if !name or !type or !default then return end;
    if SERVER and sqlTable then
        if !BASH.SQL.Tables[sqlTable] then
            local args = concatArgs(name, type, default, public, sqlTable);
            MsgErr("[BASH.Registry:NewVariable(%s)]: This variable points to the SQL table '%s', which doesn't exist!", args, sqlTable);
            return;
        end
    end

    if !self.Vars then self.Vars = {} end;
    if self.Vars[name] then
        local args = concatArgs(name, type, default, public, sqlTable);
        MsgErr("[BASH.Registry:NewVariable(%s)]: A variable with that name already exists!", args);
        return;
    end

    self.Vars[name] = {};
    self.Vars[name].Type = type;
    self.Vars[name].Default = default;
    self.Vars[name].Public = public or false;
    self.Vars[name].SQLTable = sqlTable;

    Player["Get" .. name] = function(_self)
        if !self.Players[_self:SteamID()] then
            MsgErr("[Player:Get%s()]: Player not registered! (%s/%s)", name, _self:Nick(), _self:SteamID());
            return;
        end

        return self.Players[_self:SteamID()][name];
    end

    if CLIENT then
        net.Receive("BASH_UPDATE_VAR", function(len)
            local varName = net.ReadString();
            local var = self.Vars[varName];
            local steamID = net.ReadString();
            local val = net["Read" .. NET_TYPE[var.Type]](32);
            val = detype(val, var.Type);

            if !self.Players[steamID] then
                self.Players[steamID] = {};
            end

            self.Players[steamID][name] = val;
        end);
    elseif SERVER then
        Player["Set" .. name] = function(_self, val)
            local steamID = _self:SteamID();

            if !self.Players[steamID] then
                MsgErr("[Player:Set%s(%s)]: Player not registered! (%s/%s)", name, detype(val, "string"), _self:Nick(), steamID);
                return;
            end

            self.Players[steamID][name] = val;

            local var = self.Vars[name];
            val = detype(val, var.Type);
            net.Start("BASH_UPDATE_VAR");
                net.WriteString(name);
                net.WriteString(steamID);
                net["Write" .. NET_TYPE[var.Type]](val, 32);

            if var.Public then
                net.Broadcast();
            else
                local recipients = BASH.Ranks:GetStaff();
                table.Add(recipients, {_self});
                net.Send(recipients);
            end
        end

        if sqlTable then
            if BASH.SQL.ColumnsConsolidated then
                local args = concatArgs(name, type, default, public, sqlTable);
                MsgErr("[BASH.Registry:NewVariable(%s)]: The database structure has already been consolidated! You must call this function earlier in order for this variable to be saved to the entered table.", args);
                return;
            end

            local index = #BASH.SQL.Tables[sqlTable].Struct + 1;
            BASH.SQL.Tables[sqlTable].Struct[index] = "`" .. name .. "` " .. SQL_TYPE[type] .. ((default != "" and " DEFAULT \'" .. default .. "\'") or "");
        end
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
            BASH.Registry.Queue = {};
        end
    	if BASH.Registry.Queue[1] and BASH.Registry.Queue[1] != steamID then
    		local index = #BASH.Registry.Queue + 1;
    		BASH.Registry.Queue[index] = steamID;
    		snow.Send(ply, "BASH_REGISTRY_QUEUED", index);
    		self.SQLData = data;

    		return;
    	elseif !BASH.Registry.Queue[1] then
    		BASH.Registry.Queue[1] = steamID;
    	end

    	self.SQLData = data;
    	self:PushData();
    	self:PullData();

    	snow.Send(self, "BASH_PLAYER_LOADED");
    	self.Registered = true;
    	BASH.LastRegistered = steamID;
    end
    hook.Add("Think", "BASH_HandleRegistryQueue", function()
        if !BASH.Registry.Queue then
            BASH.Registry.Queue = {};
        end

    	if BASH.LastRegistered == BASH.Registry.Queue[1] then
            table.Remove(BASH.Registry.Queue, 1);

    		local ply = player.GetBySteamID(BASH.Registry.Queue[1]);
    		if CheckPly(ply) and ply.SQLData then
    			ply:Register(ply.SQLData);
    		end

    		if #BASH.Registry.Queue > 1 then
    			for index = 2, #BASH.Registry.Queue do
    				local ply = player.GetBySteamID(BASH.Registry.Queue[index]);
    				if CheckPly(ply) then
                        snow.Send(ply, "BASH_REGISTRY_QUEUED", index);
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

    	local steamID, varTable;
    	for _, ply in pairs(player.GetAll()) do
    		if self != ply and ply.Registered then
    			steamID = ply:SteamID();
    			if !BASH.Players[steamID] then continue end;

    			for var, val in pairs(BASH.Players[steamID]) do
    				varTable = BASH.Registry.Vars[var];
    				if !varTable then continue end;

    				if varTable.Public or self:IsStaff() then
    					net.Start("BASH_UPDATE_VAR");
    						net.WriteString(name);
    						net.WriteString(steamID);
    						net["Write" .. NET_TYPE[varTable.Type]](val, 32);
    					net.Send(self);
    				end
    			end
    		end
    	end
    end
end

if CLIENT then
    /*
    **  Networking
    */
    net.Receive("BASH_PLAYER_LOADED", function(len)
        LocalPlayer().Initialized = true;
        BASH.IntroStage = 2;
    end);

    net.Receive("BASH_REGISTRY_PROGRESS", function(len)
        LocalPlayer().RegistryProgress = net.ReadInt(32);
    end);

    net.Receive("BASH_REGISTRY_QUEUED", function(len)
        LocalPlayer().QueuePlace = net.ReadInt(32);
    end);
elseif SERVER then
    /*
    **  Networking
    */
    util.AddNetworkString("BASH_PLAYER_LOADED");
    util.AddNetworkString("BASH_REGISTRY_PROGRESS");
    util.AddNetworkString("BASH_REGISTRY_QUEUED");
end

BASH:RegisterLib(BASH.Registry);
