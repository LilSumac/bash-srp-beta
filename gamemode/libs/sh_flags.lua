local BASH = BASH;
BASH.Flags = BASH.Flags or {};
BASH.Flags.Name = "Flags";
BASH.Flags.Entries = BASH.Flags.Entries or {};
local Player = FindMetaTable("Player");

function BASH.Flags:Init()
    /*
    **  Create Default Flags
    */

    MsgCon(color_green, true, "Initializing flags...");
    if !BASH:LibDepMet(self) then return end;

    MsgCon(color_green, true, "Initializing flags complete!");
end
