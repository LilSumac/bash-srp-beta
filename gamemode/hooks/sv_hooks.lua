local BASH = BASH;

/*
**  GMod Hooks
*/
function BASH:ShutDown() self:Exit() end;

function BASH:PlayerDisconnected(ply)
    if ply.SettingConfig then
        self.Config.SettingUp = false;
    end
end

function BASH:PlayerSpawn(ply)
    if !ply.Initialized then
        ply:Initialize();
        return;
    end
end
