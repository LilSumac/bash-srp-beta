local BASH = BASH;
BASH.SQL = BASH.SQL or {};
BASH.SQL.Name = "SQL";
BASH.SQL.DB = BASH.SQL.DB or nil;
BASH.SQL.Connected = BASH.SQL.Connected or false;
BASH.SQL.Tables = BASH.SQL.Tables or {};
BASH.SQL.ServerData = BASH.SQL.ServerData or {};
local Player = FindMetaTable("Player");

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
function BASH:GatherSQLTables()
    //  Construct the characters table.
    local chars = {
        "`CharName` TEXT NOT NULL",
        "`CharDesc` TEXT NOT NULL",
        "`Model` TEXT NOT NULL",
        "`Weapons` TEXT NOT NULL",
        "`Equipment` TEXT NOT NULL"
    };
    self.SQL:NewTable("bash_characters", SQL_GLOBAL, DATA_CHAR, "#!/BASH", chars);

    //  Construct the bans table.
    local bans = {
        "`VictimName` TEXT NOT NULL",
        "`VictimSteamID` TEXT NOT NULL",
        "`BannerName` TEXT NOT NULL",
        "`BannerSteamID` TEXT NOT NULL",
        "`BanTime` INT(10) NOT NULL",
        "`BanLength` INT(10) NOT NULL",
        "`BanReason` TEXT NOT NULL"
    };
    self.SQL:NewTable("bash_bans", SQL_GLOBAL, DATA_SERVER, "#!/BASH", bans);
end

function BASH:EditSQLTables() end;

/*
**  Default SQL Structure [Do Not Edit]
**
**  Note: 'bash_players' is the default table; it
**  must always exist as long as SQL is used to
**  store player data.
*/
BASH.SQL.Tables["bash_players"] = {};
BASH.SQL.Tables["bash_players"].SQLScope = SQL_GLOBAL;
BASH.SQL.Tables["bash_players"].DataScope = DATA_PLY;
BASH.SQL.Tables["bash_players"].Origin = "#!/BASH";
BASH.SQL.Tables["bash_players"].Struct = {};
BASH.SQL.Tables["bash_players"].Struct[1] = "`PlayerNum` INT(10) UNSIGNED NOT NULL";
BASH.SQL.Tables["bash_players"].Struct[2] = "`BASHID` TEXT NOT NULL";
BASH.SQL.Tables["bash_players"].Struct[3] = "`SteamName` TEXT NOT NULL";
BASH.SQL.Tables["bash_players"].Struct[4] = "`SteamID` TEXT NOT NULL";
BASH.SQL.Tables["bash_players"].Struct[5] = "`PlayerFlags` TEXT NOT NULL";
BASH.SQL.Tables["bash_players"].PrimaryKey = "PlayerNum";

function BASH.SQL:Init()
    if self.DB then return end;

    hook.Call("GatherSQLTables", BASH);
	hook.Call("EditSQLTables", BASH);

    if !tmysql then
        MsgErr("[BASH:SQLInit()]: tmysql doesn't exist!");
        return;
    end

    if !BASH.Config.InitialSet then
        MsgErr("[BASH.SQL:Init()]: Cannot setup the database until config has been initially set!");
        return;
    end

    self.DB = tmysql.Connect(
        BASH.Config:Get("sql_host"), BASH.Config:Get("sql_user"),
        BASH.Config:Get("sql_pass"), BASH.Config:Get("sql_name"),
        BASH.Config:Get("sql_port"), nil, CLIENT_MULTI_STATEMENTS
    );
    local status, err = self.DB:Connect();

    if !status then
        MsgErr("[BASH:SQLInit()]: Unable to connect to database!");
        MsgErr(err);
        self.Connected = false;
    else
        MsgCon(color_sql, "Database connected successfully!");
        self.Connected = true;
        self:TableCheck();
    end
end

function BASH.SQL:Query(query, sqlType, callback, obj)
    if !query or query == "" then return end;
    if !sqlType or sqlType == 0 then return end;
    if sqlType == SQL_GLOBAL and !callback then
        MsgErr("[BASH.SQL:Query()]: Tried to make a global SQL query without a callback function!");
        MsgErr("[BASH.SQL:Query()]: %s", query);
        return;
    end

    local _query;
    if sqlType == SQL_LOCAL then
        _query = sql.Query(query);
        if _query == false then
            MsgErr("[BASH.SQL:Query()]: Local SQL query failed!");
            MsgErr(query);
            return nil;
        else return _query end;
    elseif sqlType == SQL_GLOBAL then
        _query = self.DB:Query(query, callback, obj);
    end
end

function BASH.SQL:QueryAnalysis(query)

end

function BASH.SQL:NewTable(name, sqlScope, dataScope, origin, struct, primaryKey)
    if !name or !sqlType or !dataScope then return end;
    /*
    **  Origin strings are used in order to keep
    **  track of what modules are creating what
    **  SQL tables and to avoid database conflicts.
    **  (See second if statement.)
    */
    if !origin then
        local args = concatArgs(name, sqlScope, dataScope, origin, struct, primaryKey, multRows);
        MsgErr("[BASH.SQL:NewTable(%s)]: No origin for new table given!", args);
        return;
    end
    if self.Tables[name] then
        local args = concatArgs(name, sqlScope, dataScope, origin, struct, primaryKey, multRows);
        MsgErr("[BASH.SQL:NewTable(%s)]: A table with the name '%s' already exists! Origin: '%s'", args, name, self.Tables[name].Origin);
        return;
    end

    local newTable = {};
    newTable.Struct = {};
    newTable.PrimaryKey = primaryKey;

    if dataScope == DATA_PLY then
        newTable.Struct[1] = "`PlayerNum` INT(10) UNSIGNED NOT NULL";
        newTable.Struct[2] = "`BASHID` TEXT NOT NULL";
        newTable.PrimaryKey = "PlayerNum";
    elseif dataScope == DATA_CHAR then
        newTable.Struct[1] = "`CharNum` INT(10) UNSIGNED NOT NULL";
        newTable.Struct[2] = "`BASHID` TEXT NOT NULL";
        newTable.Struct[3] = "`CharID` TEXT NOT NULL";
        newTable.PrimaryKey = "CharNum";
    elseif dataScope == DATA_SERVER then
        newTable.Struct[1] = "`EntryNum` INT(10) UNSIGNED NOT NULL";
        newTable.PrimaryKey = "EntryNum";
    end

    local index, len = 1, nil;
    for _, row in pairs(struct) do
        len = #newTable.Struct;
        newTable.Struct[len + 1] = struct[index];
    end

    newTable.SQLScope = sqlScope;
    newTable.DataScope = dataScope;
    newTable.Origin = origin;

    self.Tables[name] = newTable;
    MsgCon(color_sql, true, "Table registered with name '%s'. Origin: '%s'", name, origin);
end

function BASH.SQL:AddColumn(tableName, colName, colType)
    if !tableName or !colName or !colType then return end;
    if !self.Tables[tableName] then
        local args = concatArgs(tableName, colName, colType);
        MsgErr("[BASH.SQL:AddColumn(%s)]: A table with that name doesn't exist!", args);
        return;
    end
    if !SQL_TYPE[colType] then
        local args = concatArgs(tableName, colName, colType);
        MsgErr("[BASH.SQL:AddColumn(%s)]: A default SQL structure of that type doesn't exist!", args);
        return;
    end

    local len = #self.Tables[tableName].Struct;
    self.Tables[tableName].Struct[len + 1] = '`' .. colName .. '` ' .. SQL_TYPE[colType];
    MsgCon(color_sql, true, "Appended row '%s' of %s type onto table '%s'.", colName, tableName);
end

function BASH.SQL:TableCheck()
    if !self.Connected then return end;

    local received, total = 0, 0;
    local function tableCallback(results)
        received = received + 1;
        results = results[1];

        if !results.status then
            MsgErr("[BASH.SQL:TableCheck()]: Table query returned an empty set!");
            MsgErr(results.error);
            return;
        end

        PrintTable(results.data);

        if received >= total then
            MsgN("COLUMN CHECK");
            //BASH.SQL:ColumnCheck();
        end
    end

    MsgCon(color_sql, true, "Checking tables...");
    local existsPre, existsQuery = "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '%s';", nil;
    for table, structTable in pairs(self.Tables) do
        existsQuery = Format(existsPre, table);
        self:SQLQuery(existsQuery, structTable.SQLScope, results);
        total = total + 1;
    end
end

function BASH.SQL:ColumnCheck()
    if !self.Connected then return end;

    local create = {};
    local columns, varName, exists, createStr;
    for table, structTable in pairs(self.Tables) do
        columns = self:Query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = \'" .. table .. "\';", structTable.SQLScope);
        if !columns then
            MsgErr("[BASH.SQL:ColumnCheck()]: Column query returned an empty set!");
            continue;
        end

        for _, entry in pairs(structTable.Struct) do
            varName = string.Explode("`", entry)[2];
            if !varName or varName == "" then continue end;

            for __, row in pairs(columns) do
                if varName == row["COLUMN_NAME"] then
                    exists = true;
                    break;
                end
            end

            if !exists then
                create[varName] = entry;
            end
            exists = false;
        end

        if table.Count(create) > 0 then
            createStr = "ALERT TABLE " .. table .. " ADD ";
            for var, struct in pairs(create) do
                createStr = createStr .. struct .. ", ";
            end
            createStr = string.sub(createStr, 1, #createStr - 2) .. ";";

            local tabID = BASH:RandomString(4);
            if !timer.Start(tabID .. "_push_col") then
                timer.Create(tabID .. "_push_col", 30, 1, function()
                    local createQuery = self:Query(createStr, structTable.SQLScope);
                    if createQuery then
                        MsgCon(color_red, true, "New columns pushed to table '%s' (%s)!", table, tabID);
                    end
                end);
            end

            MsgCon(color_red, true, "New columns ready to be pushed to '%s' (%s) in 15 seconds. Run \'bash_nopush %s\' to kill this operation.", table, tabID, tabID);
        end
    end

    self:ColumnCleanup();
end

function BASH.SQL:ColumnCleanup()
    if !self.SQLConnected then return end;

    local dump = {};
    local columns, varName, exists, dumpStr;
    for table, structTable in pairs(self.Tables) do
        columns = self:Query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = \'" .. table .. "\';");
        if !columns then
            MsgErr("[BASH.SQL:ColumnCleanup()]: Columns query returned an empty set!");
            continue;
        end

        for _, row in pairs(columns) do
            for __, entry in pairs(structTable.Struct) do
                varName = string.Explode("`", entry)[2];
                if varName == row["COLUMN_NAME"] then
                    exists = true;
                    break;
                end
            end
            if !exists then
                dump[row["COLUMN_NAME"]] = true;
            end
            exists = false;
        end

        if table.Count(dump) > 0 then
            dumpStr = "ALERT TABLE " .. table .. " DROP COLUMN ";
            for var, struct in pairs(dump) do
                dumpStr = dumpStr .. struct .. ", ";
            end
            dumpStr = string.sub(dumpStr, 1, #dumpStr - 2) .. ";";

            local tabID = BASH:RandomString(4);
            if !timer.Start(tabID .. "_drop_col") then
                timer.Create(tabID .. "_drop_col", 30, 1, function()
                    local dumpQuery = self:Query(dumpStr, structTable.SQLScope);
                    if dumpQuery then
                        MsgCon(color_red, true, "Old columns dropped from table '%s' (%s)!", table, tabID);
                    end
                end);
            end

            MsgCon(color_red, true, "Old columns ready to be dropped from '%s' (%s) in 15 seconds. Run \'bash_nodrop %s\' to kill this operation.", table, tabID, tabID);
        end
    end

    MsgCon(color_sql, true, "Database initialization complete!");
    self:GatherServerData();
end

function BASH.SQL:GatherServerData()
    if !BASH.SQl.Connected then return end;

    local data, tableQuery = {}, nil;
    for table, tableStruct in pairs(BASH.SQL.Tables) do
        if tableStruct.DataScope == DATA_SERVER then
            tableQuery = self:Query("SELECT * FROM " .. table .. ";");
            if tableQuery then
                //  There is no reason for there to be more than
                //  one result row. Logically, the data should
                //  be stored in different columns all in one
                //  row for the independent server.
                data[table] = tableQuery[1];
            end
        end
    end

    MsgCon(color_sql, true, "Gathered server data from %d tables!", table.Count(data));
    self.ServerData = data;
end

function Player:SQLInit()
    if !BASH.SQL.Connected then return end;
    if !CheckPly(self) then return end;

    local sql, steamID, data = BASH.SQL, self:SteamID(), {};
    local exists = sql:Query("SELECT * FROM bash_players WHERE SteamID = \'" .. steamID .. "\';");
    if !exists[1] then
        local bashID, steamName = BASH:RandomString(16), self:Name();
        local args = concatArgs(bashID, steamName, steamID, "");
        local insert = sql:Query("INSERT INTO bash_players(BASHID, SteamName, SteamID, PlayerFlags) VALUES(" .. args .. ");");
        if insert != false then
            MsgCon(color_sql, true, "New row created for player %s.", steamName);

            data["bash_players"] = {
                ["BASHID"] = bashID,
                ["SteamName"] = steamName,
                ["SteamID"] = steamID,
                ["PlayerFlags"] = "[]"
            };
        end
    else
        MsgCon(color_sql, true, "Row found for player %s.", self:Name());
        data["bash_players"] = exists[1];
    end

    local tableQuery;
    for table, tableStruct in pairs(BASH.SQL.Tables) do
        if table == "bash_players" then continue end;
        if tableStruct.DataScope != DATA_SERVER then
            tableQuery = sql:Query("SELECT * FROM " .. table .. " WHERE BASHID = " .. concatArgs(bashID) .. ";");
            if tableQuery then
                if #tableQuery > 1 then
                    data[table] = tableQuery;
                else
                    data[table] = tableQuery[1];
                end
            end
        end
    end

    self:Register(data);
end

concommand.Add("bash_nopush", function(ply, cmd, args)
    if ply != NULL then
        MsgCon(color_red, false, "\'bash_nopush\' must be called from the dedicated server console!");
        return;
    end
    if !args[1] then
        MsgCon(color_red, false, "\'bash_nopush\' must be called with a table ID!");
        return;
    end

    local tabID = args[1];
    if !timer.Stop(tabID .. "_push_col") then
        MsgCon(color_red, false, "No table with that ID is being pushed to, or the operation has already been halted!");
    else
        MsgCon(color_sql, true, "New columns will not be pushed to table with ID '%s'.", tabID);
    end
end);

concommand.Add("bash_nodrop", function(ply, cmd, args)
    if ply != NULL then
        MsgCon(color_red, false, "\'bash_nodrop\' must be called from the dedicated server console!");
        return;
    end
    if !args[1] then
        MsgCon(color_red, false, "\'bash_nodrop\' must be called with a table ID!");
        return;
    end

    local tabID = args[1];
    if !timer.Stop(tabID .. "_drop_col") then
        MsgCon(color_red, false, "No table with that ID is being dropped from, or the operation has already been halted!");
    else
        MsgCon(color_sql, true, "Old columns will not be dropped from table with ID '%s'.", tabID);
    end
end);

BASH:RegisterLib(BASH.SQL);
