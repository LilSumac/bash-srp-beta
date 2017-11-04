local BASH = BASH;
BASH.Modules = {};
BASH.Modules.Name = "Modules";
BASH.Modules.Entries = {};
BASH.Modules.Loaded = {};

function BASH.Modules:Init()
    self:LoadFromDir(engine.ActiveGamemode() .. "/gamemode/modules");
    hook.Run("InitModules");
end

function BASH.Modules:Load(modID, modPath, isSingleFile)
    if !file.Exists((isSingleFile and modPath) or modPath .. "/sh_module.lua", "LUA") then
        MsgErr("[BASH.Modules.Load] -> Module '%s' has no base file!", modID);
        return;
    end

    local MODULE = {
        UniqueID = modID,
        Path = modPath,
        Name = "Untitled Module",
        Desc = "No description available.",
        Author = "Anon"
    };

    if self.Loaded[modID] then
        MODULE = self.Loaded[modID];
    end

    _G["MODULE"] = MODULE;
    MODULE.Loading = true;

    if !isSingleFile then
        BASH:ProcessCore(modPath);
        self:LoadEnts(modPath .. "/entities");
    end

    BASH:IncludeFile((isSingleFile and modPath) or modPath .. "/sh_module.lua");
end

function BASH.Modules:LoadEnts(entPath)

end

function BASH.Modules:LoadFromDir(modPath)
    local files, folders = file.Find(modPath .. "/*", "LUA");

    for _, mod in pairs(folders) do
        self:Load(mod, modPath .. "/" .. mod);
    end

    for _, mod in pairs(files) do
        self:Load(string.StripExtension(mod), modPath .. "/" .. mod, true);
    end
end

BASH:RegisterLib(BASH.Modules);
