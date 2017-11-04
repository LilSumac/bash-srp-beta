local BASH = BASH;
BASH.Persist = {};
BASH.Persist.Stored = BASH.Persist.Stored or {};

-- Registry data is saved in text files.
file.CreateDir("bash");

function BASH.Persist:Set(key, val, global, ignoreMap)
    local path = "bash/" .. (global and "" or "srp/") .. (ignoreMap and "" or game.GetMap() .. "/");

    if !global then
        file.CreateDir("bash/srp/");
    end

    file.CreateDir(path);
    file.Write(path .. key .. ".txt", pon.encode({val}));
    self.Stored[key] = value;
end

function BASH.Persist:Get(key, default, global, ignoreMap, refresh)
    if !refresh then
        if self.Stored[key] != nil then
            return self.Stored[key];
        end
    end

    local path = "bash/" .. (global and "" or "srp/") .. (ignoreMap and "" or game.GetMap() .. "/");
    local contents = file.Read(path .. key .. ".txt", "DATA");
    if content and contents != "" then
        local status, decoded = pcall(pon.decode, contents);
        if status and decoded then
            if decoded[1] != nil then
                return decoded[1];
            else
                return default;
            end
        else
            return default;
        end
    else
        return default;
    end
end

function BASH.Persist:Delete(key, global, ignoreMap)
    local path = "bash/" .. (global and "" or "srp/") .. (ignoreMap and "" or game.GetMap() .. "/");
    local contents = file.Read(path .. key .. ".txt", "DATA");
    if contents and contents != "" then
        file.Delete(path .. key .. ".txt");
        self.Stored[key] = nil;
    end
end
