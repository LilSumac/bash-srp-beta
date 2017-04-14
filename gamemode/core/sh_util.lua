local BASH = BASH;
BASH.LastLog = BASH.LastLog or 0;
local net = net;
local math = math;
local player = player;
local string = string;

/*
**  'net' Library Functions
*/
function net.Empty(id, recip)
    if !id or util.NetworkStringToID(id) == 0 then
        MsgErr("[net.Empty(%s)]: The supplied ID is not a valid network string!", id or "");
        return;
    end

    net.Start(id);
    if CLIENT then
        net.SendToServer();
    else
        if recip == true then
            recip = player.GetAll();
        else
            recip = recip or {};
        end
        net.Send(recip);
    end
end

/*
**  'math' Library Functions
*/
function math.lerp(frac, from, to)
    local val = Lerp(frac, from, to);
    if (to / math.abs(val - to)) < frac then
        val = to;
    end
    return val;
end

/*
**  'player' Library Functions
*/
function player.GetByNick(nick)
    for _, ply in pairs(player.GetAll()) do
        if string.find(string.lower(ply:Name()), string.lower(nick)) then return ply end;
    end
end

function player.GetBySteamID(steamID)
    for _, ply in pairs(player.GetAll()) do
        if steamID == ply:SteamID() then return ply end;
    end
end

function player.GetByBASHID(bashID)
    for _, ply in pairs(player.GetAll()) do
        if bashID == ply:GetBASHID() then return ply end;
    end
end

/*
**  'string' Library Functions
*/
function string.wrap(str, font, size)
	if string.len(str) == 1 then return str, 0 end;
    str = string.Replace(str, '\n', '');
    str = string.Replace(str, "<br>", '\n');

    surface.SetFont(font);
	local start, c, n, lastspace, lastspacemade = 1, 1, 0, 0, 0;
	local endstr = "";
	while string.len(str or "") > c do
		local sub = string.sub(str, start, c);

		if str[c] == " " then
			lastspace = c;
		end

		if surface.GetTextSize(sub) >= size and lastspace != lastspacemade then
			local sub2;
			if lastspace == 0 then
				lastspace = c;
				lastspacemade = c;
			end

			if lastspace > 1 then
				sub2 = string.sub(str, start, lastspace - 1);
				c = lastspace;
			else
				sub2 = string.sub(str, start, c);
			end

			endstr = endstr .. sub2 .. "\n";
			lastspace = c + 1;
			lastspacemade = lastspace;
			start = c + 1;
			n = n + 1;
		end

		c = c + 1;
	end

	if start < string.len(str or "") then
		endstr = endstr .. string.sub(str or "", start);
	end

	return endstr, n;
end

/*
**  BASH Util Functions
*/
function MsgCon(color, log, text, ...)
    local text = Format(text, ...);
    MsgC(color, text .. '\n');

	if log then
		BASH:WriteToLog(text, LOG_ALL)
	end
end

function MsgErr(text, ...)
    local text = Format(text, ...);
    MsgCon(color_red, true, text);
    BASH:WriteToLog(text, LOG_ERR);
end

function MsgDebug(text, ...)
    if BASH:DebugEnabled() then
        local text = Format(text, ...);
        MsgCon(Color(192, 192, 192), true, text .. '\n');
    end
end

function checkply(ent)
    if !ent then return false end;
    return ent:IsValid() and ent:IsPlayer();
end

function detype(var, typeStr)
    if var == nil then return var end;
    if !typeStr then return end;
    if type(var) == typeStr then return var end;
    if type(var) == "table" and typeStr == "string" then
        return von.serialize(var or {});
    elseif type(var) == "string" and typeStr == "table" then
        return von.deserialize(var or "");
    elseif type(var) == "string" and typeStr == "number" then
        return tonumber(var) or 0;
    elseif type(var) == "number" and typeStr == "string" then
        return tostring(var) or "";
    elseif type(var) == "number" and typeStr == "boolean" then
        return var >= 1;
    elseif type(var) == "boolean" and typeStr == "number" then
        return (var and 1) or 0;
    elseif type(var) == "boolean" and typeStr == "string" then
        return tostring(var) or "false";
    elseif typeStr == "string" then
        return tostring(var) or "";
    end
end

function isOperation(oper)
    return isfunction(OPERATIONS[string.sub(oper, 1, 2)]);
end

function doOperation(oper, val)
    return OPERATIONS[string.sub(oper, 1, 2)](detype(val, "number"), detype(string.sub(oper, 3), "number"));
end

function concatArgs(...)
    local str = "";
    local items = {...};
    for _, item in pairs(items) do
        if str != "" then
            str = str .. ", ";
        end
        if type(item) == "string" then
            str = str .. '\'' .. item .. '\'';
        else
            str = str .. (detype(item, "string") or "nil");
        end
    end

    if #items > 1 then str = string.sub(str, 1, #str - 2) end;
    return str;
end

local randStr;
function randomString(length)
	randStr = "";
	for index = 1, length do
		randStr = randStr .. CHARACTERS_RANDOM[math.random(1, #CHARACTERS_RANDOM)];
	end
	return randStr;
end

function secondsToTime(secs, daytime)
	local hours = math.floor(secs / 3600);
	local minutes = math.floor((secs - (hours * 3600)) / 60);
	local seconds = secs - (hours * 3600) - (minutes * 60);

	if hours < 10 then hours = "0" .. tostring(hours) end;
	if minutes < 10 then minutes = "0" .. tostring(minutes) end;
	if seconds < 10 then seconds = "0" .. tostring(seconds) end;
	if daytime then
		hours = hours % 24;
	end
	return Format("%d:%d:%d", hours, minutes, seconds);
end

function BASH:IncludeFile(name, print)
	local fileName = string.GetFileFromFilename(name);
    if CORE_EXCLUDED[string.StripExtension(fileName)] then return end;
	local filePrefix = string.sub(fileName, 1, string.find(fileName, '_', 1));

	if table.HasValue(PREFIXES_CLIENT, filePrefix) then
		if CLIENT then include(name)
		else AddCSLuaFile(name) end;
	elseif table.HasValue(PREFIXES_SHARED, filePrefix) then
		if CLIENT then include(name)
		else AddCSLuaFile(name) include(name) end;
	elseif table.HasValue(PREFIXES_SERVER, filePrefix) then
		if SERVER then include(name) end;
	end

	if SERVER and print then
		MsgCon(color_green, false, "Processed file '%s'.", fileName);
	end
end

function BASH:IncludeDirectory(directory, print)
	MsgCon(color_green, false, "Processing directory '%s'...", directory);

	local files, dirs = file.Find(directory .. "/*", "LUA", nameasc);
	for _, file in pairs(files) do
		file = directory .. "/" .. file;
		self:IncludeFile(file, print);
	end

	if dirs then
		for _, dir in pairs(dirs) do
			dir = directory .. "/" .. dir;
			self:IncludeDirectory(dir, print);
		end
	end
end

function BASH:ProcessCore(directory)
	if !directory then
		MsgCon(color_green, true, "Processing #!/BASH core...");
	else
		MsgCon(color_green, true, "Processing '%s' core...", directory);
	end

    local fullDir = self.FolderName .. "/gamemode/";
    local files, dirs = file.Find(fullDir .. ((directory and directory .. "/*") or "*"), "LUA", nameasc);
	if dirs then
		for _, dir in pairs(dirs) do
			if CORE_DIRS[dir] then
				dir = fullDir .. ((directory and directory .. "/") or "") .. dir;
				self:IncludeDirectory(dir, !directory);
			end
		end
	end
end

function BASH:RegisterLib(lib)
    if !lib then return end;

    self.Libraries = self.Libraries or {};
    lib.Name = lib.Name or "Unnamed Library$" .. randomString(8);
    self.Libraries[lib.Name] = lib;
    MsgCon(color_green, true, "Registered '%s' library.", lib.Name);
end

function BASH:LibInit()
    if !self.Libraries then return end;

    for name, lib in pairs(self.Libraries) do
        if !self:LibDepMet(self) then continue end;
        if !lib.Init then continue end;
        MsgCon(color_green, true, "Initializing '%s' library...", lib.Name);
        lib:Init();
        MsgCon(color_green, true, "'%s' initialization complete!", lib.Name);
    end
end

function BASH:LibDepMet(lib)
    if !lib.Dependencies or table.Count(lib.Dependencies) == 0 then return true end;

    local metDep = true;
    for dep, scope in pairs(lib.Dependencies) do
        if !scope then continue end;
        if !self[dep] then
            MsgErr("You're missing the '%s' library, required by the '%s' library! Please install it before continuing.", dep, lib.Name);
            metDep = false
        end
    end

    if !metDep then
        MsgCon(color_red, true, "'%s' library not initialized due to dependency errors.", lib.Name);
    end
    return metDep;
end

function BASH:CreateFile(name)
	if file.Exists(name, "DATA") then return end;
	file.Write(name, "");
end

function BASH:CreateDirectory(name)
	if file.Exists(name, "DATA") then return end;
	file.CreateDir(name);
end

function BASH:GetSafeFilename(name)
	return string.gsub(string.gsub(string.gsub(name, "%.[^%.]*$", ""), "[^\32-\126]", ""), "[^%w-_/]", "") .. ".txt";
end

function BASH:WriteToFile(name, text, overwrite)
	name = self:GetSafeFilename(name);
	self:CreateDirectory(string.GetPathFromFilename(name));
	self:CreateFile(name);

	local logFile = file.Open(name, (overwrite and 'w') or 'a', "DATA");
	if !logFile then
        local args = concatArgs(name, text, overwrite);
		MsgErr("[BASH:WriteToFile(%s)]: Couldn't write/append to file '%s'!", args, name);
		return;
	end

	if overwrite then
		logFile:Write(text);
	else
		logFile:Write((logFile:Size() > 0 and "\n" or "") .. text);
	end
	logFile:Close();
end

function BASH:WriteToLog(text, logType)
	if !self:LoggingEnabled() then return end;

    local file = self:GetLoggingFile(logType);
	local time = os.date("%X");
    file:Write(Format("[%s] %s\n", time, text));
    file:Flush();
end

function BASH:GetLoggingFile(logType)
    local fileDir = (logType == LOG_ALL and "all/") or (logType == LOG_IC and "ic/") or (logType == LOG_ERR and "error/") or "misc/";
    local tabPre = (logType == LOG_ALL and "Log") or (logType == LOG_IC and "IC") or (logType == LOG_ERR and "Error") or "Misc";
    local fileName = "bash/logs/" .. fileDir .. os.date("%Y-%m-%d", os.time()) .. ".txt";
    local tabFile = tabPre .. "File";
    local tabFileName = tabFile .. "Name";

    if !file.Exists("bash/logs/" .. fileDir, "DATA") then
        file.CreateDir("bash/logs/" .. fileDir);
    end

    if !self[tabFile] then
        MsgN("Opening initial " .. tabFile .. "...");
        self[tabFile] = file.Open(fileName, "a", "DATA");
        self[tabFileName] = fileName;
    elseif self[tabFileName] != fileName then
        MsgN("Swapping over to next day's " .. tabFile .. ".");
        self[tabFile]:Close();
        self[tabFile] = file.Open(fileName, "a", "DATA");
        self[tabFileName] = fileName;
    end
    return self[tabFile];
end

function BASH:LoggingEnabled()
	if CLIENT then
        if !self.Cookies then return false end;
		return self.Cookies:Get("logging_enabled");
	end
	return true;
end

function BASH:DebugEnabled()
    if CLIENT then
        if !self.Cookies then return false end;
        return self.Cookies:Get("debug_enabled");
    else
        return self.Config:Get("debug_enabled") or false;
    end
end
