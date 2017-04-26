local BASH = BASH;

if !BASH.Initialized then
    DeriveGamemode("sandbox");
    concommand.Remove("gm_save");
end

if CLIENT then
    include("sh_glob.lua");
    include("sh_util.lua");
elseif SERVER then
    AddCSLuaFile("sh_glob.lua");
    AddCSLuaFile("sh_util.lua");
    include("sh_glob.lua");
    include("sh_util.lua");
end

MsgCon(color_darkgreen, true, "--%s entry point! Base files processed.", BASH.Name);
BASH:ProcessCore();
BASH:Init();
