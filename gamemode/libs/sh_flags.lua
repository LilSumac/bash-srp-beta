local BASH = BASH;
BASH.Flags = BASH.Flags or {};
BASH.Flags.Name = "Flags";
BASH.Flags.Entries = BASH.Flags.Entries or {};
local Player = FindMetaTable("Player");

function BASH.Flags:Init()
    /*
    **  Create Default Flags
    */


end

/*
**  BASH Hooks
*/
hook.Add("LoadVariables", "BASH_AddFlagVariable", function()
    BASH.Registry:AddVariable{
        Name = "PlayerFlags",
        Type = "string",
        Default = "",
        Public = true,
        SQLTable = "bash_players"
    };
end);

BASH:RegisterLib(BASH.Flags);
