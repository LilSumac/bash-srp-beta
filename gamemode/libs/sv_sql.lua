local BASH = BASH;
BASH.SQL = BASH.SQL or {};
BASH.SQL.Name = "SQL";
BASH.SQL.DB = BASH.SQL.DB or nil;
BASH.SQL.Connected = BASH.SQL.Connected or false;
BASH.SQL.Tables = BASH.SQL.Tables or {};
BASH.SQL.ServerData = BASH.SQL.ServerData or {};
BASH.SQL.Dependencies = {["Registry"] = SERVER};
local Player = FindMetaTable("Player");
local color_sql = Color(0, 151, 151, 255);

/*  Movin on.
if !mysqloo then
    require("mysqloo");
end
*/

if !tmysql then
    require("tmysql4");
end

/*
**  BASH Hooks
*/
function BASH:CreateSQLTables() end;
function BASH:EditSQLTables() end;

function BASH.SQL:Init()
    if self.DB then return end;

    /*
    **  Default SQL Structure [Do Not Edit]
    **
    **  Note: 'bash_players' is the default table; it
    **  must always exist as long as SQL is used to
    **  store player data.
    */
    self:AddTable{
        Name = "bash_players",
        Type = SQL_GLOBAL,
        Scope = DATA_PLY,
        Struct = {
			["FirstLogin"] = "INT(10) NOT NULL"
        }
    };

    self:AddTable{
        Name = "bash_characters",
        Type = SQL_GLOBAL,
        Scope = DATA_CHAR,
        Struct = {
			["CharName"] = "TEXT NOT NULL",
			["CharDesc"] = "TEXT NOT NULL",
			["BaseModel"] = "TEXT NOT NULL"
        }
    };

    self:AddTable{
        Name = "bash_bans",
        Type = SQL_GLOBAL,
        Scope = DATA_PLY,
        Struct = {
			["VictimName"] = "TEXT NOT NULL",
			["VictimSteamID"] = "TEXT NOT NULL",
			["BannerName"] = "TEXT NOT NULL",
			["BannerSteamID"] = "TEXT NOT NULL",
			["BanTime"] = "INT(10) NOT NULL",
			["BanLength"] = "INT(10) NOT NULL",
			["BanReason"] = "TEXT NOT NULL"
        }
    };

    hook.Call("CreateSQLTables", BASH);
	hook.Call("EditSQLTables", BASH);

    PrintTable(self.Tables);

	if !tmysql then
        MsgErr("[BASH.SQL.Init] -> tmysql wasn't found!");
		self.Tables = {};
        return;
    end

    local db, err = tmysql.Connect(
        BASH.SQL.Hostname, BASH.SQL.Username,
        BASH.SQL.Password, BASH.SQL.Database,
        BASH.SQL.Port, nil, CLIENT_MULTI_STATEMENTS
    );

    if err then
        MsgErr("[BASH.SQL.Init] -> Unable to connect to database!");
        MsgErr(err);
        self.Connected = false;
    else
        MsgCon(color_sql, true, "Database connected successfully!");
        self.DB = db;
        self.Connected = true;
        self:TableCheck();
    end
end

function BASH.SQL:Query(query, sqlType, callback, obj)
    if !query or query == "" then return end;
    if !sqlType then
        MsgErr("[BASH.SQL.Query] -> No SQL type specified for query: %s", query);
        return;
    end

    local _query;
    if sqlType == SQL_LOCAL then
        //query = sql.SQLStr(query, true);
        _query = sql.Query(query);
        if !_query then
            MsgErr("[BASH.SQL.Query] -> Local SQL query failed! %s", query);
            return;
        else return _query end;
    elseif sqlType == SQL_GLOBAL then
        if !self.Connected then
            MsgErr("[BASH.SQL.Query] -> Global SQL query failed (Not connected to database)! %s", query);
            return;
        end

        //query = self.DB:Escape(query);
        _query = self.DB:Query(query, callback, obj);
        return _query;
    end
end

function BASH.SQL:AddTable(sqlTab)
    if !sqlTab or !sqlTab.Name then return end;
    if self.Tables[sqlTab.Name] then
        MsgErr("[BASH.SQL.AddTable] -> A table with the name '%s' already exists!", sqlTab.Name);
        return;
    end

    sqlTab.Type = sqlTab.Type or SQL_GLOBAL;
    sqlTab.Scope = sqlTab.Scope or DATA_PLY;
    //  If the user has supplied a struct, then we assume they know what they're doing.
    sqlTab.Struct = sqlTab.Struct or {};
	if sqlTab.Scope == DATA_PLY then
		sqlTab.Struct["PlayerNum"] = "INT(10) UNSIGNED NOT NULL AUTO_INCREMENT";
		sqlTab.Struct["SteamID"] = "TEXT NOT NULL";
		sqlTab.Key = "PlayerNum";
	elseif sqlTab.Scope == DATA_CHAR then
		sqlTab.Struct["CharNum"] = "INT(10) UNSIGNED NOT NULL AUTO_INCREMENT";
		sqlTab.Struct["SteamID"] = "TEXT NOT NULL";
		sqlTab.Struct["CharID"] = "TEXT NOT NULL";
		sqlTab.Key = "CharNum";
	elseif sqlTab.Scope == DATA_SERVER then
		sqlTab.Struct["EntryNum"] = "INT(10) UNSIGNED NOT NULL AUTO_INCREMENT";
		sqlTab.Key = "EntryNum";
	end
    sqlTab.Key = sqlTab.Key or "PlayerNum";

    self.Tables[sqlTab.Name] = sqlTab;
    MsgCon(color_sql, true, "Table registered with name '%s'.", sqlTab.Name);
end

function BASH.SQL:AddColumn(tableName, colName, colType, override)
    if !tableName or !colName or !colType then return end;
    if !self.Tables[tableName] then
        MsgErr("[BASH.SQL.AddColumn] -> A table with the name '%s' doesn't exist!", name);
        return;
    end
    if !SQL_TYPE[colType] then
        MsgErr("[BASH.SQL.AddColumn] -> A default SQL structure of the type '%s' doesn't exist!", colType);
        return;
    end

	if self.Tables[tableName].Struct[colName] then
		if override then
			MsgCon(color_sql, true, "Overriding column '%s' in table '%s'.", colName, tableName);
		else
			MsgErr("[BASH.SQL.AddColumn] -> The column '%s' already exists in table '%s'! Provide the override argument to this function to bypass this.", colName, tableName);
			return;
		end
	else
		MsgCon(color_sql, true, "Adding column '%s' to table '%s'.", colName, tableName);
	end

	self.Tables[tableName].Struct[colName] = SQL_TYPE[colType];
end

function BASH.SQL:TableCheck()
    if !self.Connected then return end;

    local globalQuery = "";
    local localQuery = "";
    for name, sqlTab in pairs(self.Tables) do
        if sqlTab.Type == SQL_GLOBAL then
            globalQuery = globalQuery .. Fmt("CREATE TABLE IF NOT EXISTS %s(", name);
            for colName, col in pairs(sqlTab.Struct) do
				globalQuery = globalQuery .. Fmt("`%s` %s, ", colName, col);
            end
            globalQuery = globalQuery .. Fmt("PRIMARY KEY(`%s`)); ", sqlTab.Key);
        elseif sqlTab.Type == SQL_LOCAL then
            localQuery = localQuery .. Fmt("CREATE TABLE IF NOT EXISTS %s(", name);
            for colName, col in pairs(sqlTab.Struct) do
				localQuery = localQuery .. Fmt("`%s` %s, ", colName, col);
            end
            localQuery = localQuery .. Fmt("PRIMARY KEY(`%s`)); ", sqlTab.Key);
        end
    end

    if localQuery != "" then
        MsgCon(color_sql, true, "Creating missing tables in local DB...");
        local lCreate = self:Query(localQuery, SQL_LOCAL);
        if !lCreate then
            MsgErr("[BASH.SQL.TableCheck] -> Local table creation returned an error!");
        else
            MsgCon(color_sql, true, "Missing tables were created in local DB.");
        end
    else
        MsgCon(color_sql, true, "No tables to be made in the local DB.");
    end

    if globalQuery != "" then
        local function tableCallback(resultsTab)
    		for queryNum, results in pairs(resultsTab) do
    			if !results.status then
    				MsgErr("[BASH.SQL.TableCheck] -> Global table creation returned an error! The rest of the SQL init process has been stopped.");
    				MsgErr(results.error);
    				return;
    			end
    		end

            MsgCon(color_sql, true, "Missing tables were created in global DB.");
            BASH.SQL:ColumnCheck();
        end

        MsgCon(color_sql, true, "Creating missing tables in global DB...");
        local gCreate = self:Query(globalQuery, SQL_GLOBAL, tableCallback);
    else
        MsgCon(color_sql, true, "No tables to be made in the global DB.");
    end
end

function BASH.SQL:ColumnCheck()
    if !self.Connected then return end;

	MsgCon(color_sql, true, "Creating missing columns in local DB...");
    local lCreate = self:Query("SELECT * FROM sqlite_master WHERE type = \'table\';", SQL_LOCAL);
    if !lCreate then
        MsgErr("[BASH.SQL.ColumnCheck] -> Local column check returned an error!");
    else
		local missing = {};
		for name, sqlTab in pairs(self.Tables) do
            if sqlTab.Type != SQL_LOCAL then continue; end

			missing[name] = {};
			for colName, col in pairs(sqlTab.Struct) do
				missing[name][colName] = col;
			end
		end

        if !table.IsEmpty(missing) then
            local colQuery;
    		for _, tab in pairs(lCreate) do
                colQuery = self:Query(Fmt("PRAGMA table_info(%s);", tab.name), SQL_LOCAL);
                if !colQuery then continue; end

                for _, col in pairs(colQuery) do
        			if missing[tab.name][col.name] then
        				missing[tab.name][col.name] = nil;
        			end
                end
    		end

    		local missingQuery = "";
    		for tabName, tab in pairs(missing) do
    			if table.IsEmpty(tab) then continue end;
    			missingQuery = missingQuery .. Fmt("ALTER TABLE %s ADD(", tabName);
    			for colName, col in pairs(tab) do
    				missingQuery = missingQuery .. Fmt("%s %s, ", colName, col);
    			end
    			missingQuery = string.sub(missingQuery, 1, string.len(missingQuery) - 2) .. "); ";
    		end

    		local _missingQuery = self:Query(missingQuery, SQL_LOCAL);
    		if !_missingQuery then
    			MsgErr("[BASH.SQL.ColumnCheck] -> Local column creation failed!");
    		else
    			MsgCon(color_sql, true, "Missing columns were created in local DB.");
    		end
        else
            MsgCon(color_sql, true, "No missing columns to be made in local DB.");
        end
    end

	local function gCreateCol(resultsTab)
        if resultsTab then
    		for queryNum, results in pairs(resultsTab) do
    			if !results.status then
    				MsgErr("[BASH.SQL.ColumnCheck] -> Global column creation returned an error! The rest of the SQL init process has been stopped.");
    				MsgErr(results.error);
    				return;
    			end
    		end
        end

        if resultsTab then
            MsgCon(color_sql, true, "Missing columns were created in global DB.");
        else
            MsgCon(color_sql, true, "No missing columns to be made in global DB.");
        end

        MsgCon(color_sql, true, "Database initialization complete!");
		hook.Call("PostSQLInit", BASH);
	end

	local missing = {};
	for name, sqlTab in pairs(self.Tables) do
		missing[name] = {};
		for colName, col in pairs(sqlTab.Struct) do
			missing[name][colName] = col;
		end
	end

	local function gCheckCol(results)
        results = results[1];
        if !results.status then
            MsgErr("[BASH.SQL.ColumnCheck] -> Global column check returned an error! The rest of the SQL init process has been stopped.");
            MsgErr(results.error);
            return;
        end

        local tabName, colName;
        for _, result in pairs(results.data) do
            tabName = result["TABLE_NAME"];
            colName = result["COLUMN_NAME"];
            if missing[tabName] then
                missing[tabName][colName] = nil;
            end
        end
		tabName, colName = nil, nil;

		local missingQuery = "";
		for tabName, tab in pairs(missing) do
			if table.IsEmpty(tab) then continue end;
			missingQuery = missingQuery .. Fmt("ALTER TABLE %s ADD(", tabName);
			for colName, col in pairs(tab) do
				missingQuery = missingQuery .. Fmt("%s %s %s, ", colName, col, (BASH.SQL.Tables[tabName].Key == colName and "PRIMARY KEY") or "");
			end
			missingQuery = string.sub(missingQuery, 1, string.len(missingQuery) - 2) .. "); ";
		end

        if missingQuery != "" then
            local _missingQuery = BASH.SQL:Query(missingQuery, SQL_GLOBAL, gCreateCol);
        else
            gCreateCol();
        end
	end

	MsgCon(color_sql, true, "Creating missing columns in global DB...");
	local gCreate = self:Query(Fmt("SELECT TABLE_NAME, COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = \'%s\';", self.Database), SQL_GLOBAL, gCheckCol);
end

function BASH.SQL:TableCleanup()
	if !self.Connected then return; end
end

function BASH.SQL:ColumnCleanup()
	if !self.Connected then return; end
end

function Player:SQLInit()
    if !BASH.SQL.Connected then return end;
    if !checkply(self) then return end;

    local steamID = self:SteamID();
    self.SQLData = nil;

    if !BASH.Registry.Queue then
        BASH.Registry.Queue = Queue:Create();
    end

    local nextPos = BASH.Registry.Queue:first();
    if nextPost and nextPos != steamID then
        BASH.Registry.Queue:enqueue(steamID);
        local queuePack = vnet.CreatePacket("BASH_REGISTRY_QUEUED");
        queuePack:Table({[steamID] = BASH.Registry.Queue:len()});
        queuePack:AddTargets(self);
        queuePack:Send();
        return;
    elseif !nextPos then
        BASH.Registry.Queue:enqueue(steamID);
        vnet.SendString("BASH_REGISTRY_PROGRESS", "Starting SQL process...", self);
    end

    local _self = self;
    local function existsCallback(results)
        results = results[1];
        if !results.status then
            MsgErr("[Player.SQLInit] -> Player SQL existance check returned an error! They're stuck in limbo!");
            MsgErr(results.error);
            return;
        end

        if table.IsEmpty(results.data) then
            _self:SQLCreate();
        else
            _self.SQLData = _self.SQLData or {};
            _self.SQLData["bash_players"] = results.data;
            _self:SQLGather();
        end
    end

    local _sql = BASH.SQL;
    _sql:Query(Fmt("SELECT * FROM bash_players WHERE SteamID = \'%s\';", steamID), SQL_GLOBAL, existsCallback);
end

function Player:SQLCreate()
    if !BASH.SQL.Connected then return end;
    if !checkply(self) then return end;

    local steamName, steamID = self:Name(), self:SteamID();
    local _self = self;
    local function createCallback(results)
        results = results[1];
        if !results.status then
            MsgErr("[Player.SQLInit] -> Player SQL creation returned an error! They're stuck in limbo!");
            MsgErr(results.error);
            // do some error posting here
            return;
        end

        _self.NewPlayer = true;
        _self:SQLGather();
    end

    local _sql = BASH.SQL;
    MsgCon(color_sql, true, "Creating a new player entry for %s (%s).", steamName, steamID);
    vnet.SendString("BASH_REGISTRY_PROGRESS", "Creating a new database entry for you...", self);

    local plyVars = {};
    local plyVals = {};
    for name, var in pairs(BASH.Registry.Vars) do
        if var.SQLTable == "bash_players" then
            plyVars[#plyVars + 1] = name;
            plyVals[#plyVals + 1] = var.Default;
        end
    end

    local query = "INSERT INTO bash_players(SteamName, SteamID";
    local addQuery = "";
    for index = 1, #plyVars do
        addQuery = Fmt("%s, %s", addQuery, plyVars[index]);
    end
    query = Fmt("%s%s) VALUES(\'%s\', \'%s\'", query, addQuery, steamName, steamID);
    addQuery = "";
    for index = 1, #plyVals do
        if type(plyVals[index]) == "function" then
            local val = plyVals[index]();
            if type(val) == "string" then
                addQuery = Fmt("%s, \'%s\'", addQuery, val);
            else
                addQuery = Fmt("%s, %s", addQuery, val);
            end
        elseif type(plyVals[index]) == "string" then
            addQuery = Fmt("%s, \'%s\'", addQuery, plyVals[index]);
        else
            addQuery = Fmt("%s, %s", addQuery, plyVals[index]);
        end
    end
    query = Fmt("%s%s);", query, addQuery);

    _sql:Query(query, SQL_GLOBAL, createCallback);
    hook.Call("SQLCreate", BASH, self);

end

function Player:SQLGather()
    if !BASH.SQL.Connected then return end;
    if !checkply(self) then return end;

    local tabOrder, index = {}, 1;
    for name, sqlTab in pairs(BASH.SQL.Tables) do
        if name == "bash_players" then continue end;
        if sqlTab.Scope != DATA_SERVER then
            tabOrder[index] = name;
            index = index + 1;
        end
    end

    local steamName, steamID = self:Name(), self:SteamID();
    local _self = self;
    local function gatherCallback(resultsTab)
        for queryNum, results in pairs(resultsTab) do
            if !results.status then
                MsgErr("[Player.SQLGather] -> One of the player SQL gathers returned an error!");
                MsgErr(results.error);
                // do some error posting here
                continue;
            end

            _self.SQLData = _self.SQLData or {};
            _self.SQLData[tabOrder[queryNum]] = results.data;
        end

        self:Register();
    end

    local _sql = BASH.SQL;
    MsgCon(color_sql, true, "Gathering existing data for %s (%s).", steamName, steamID);
    local query = "";
    for index, name in ipairs(tabOrder) do
        query = query .. Fmt("SELECT * FROM %s WHERE SteamID = '%s'; ", name, steamID);
    end
    _sql:Query(query, SQL_GLOBAL, gatherCallback);
    hook.Call("SQLGather", BASH, self);
end

BASH:RegisterLib(BASH.SQL);
