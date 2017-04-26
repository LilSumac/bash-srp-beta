local BASH = BASH;

/*
**  GMod Hooks
*/
function BASH:InitPostEntity()
    net.Empty("BASH_PLAYER_INIT");
end

/*
**  #!/BASH Hooks
*/
local resChanged = false;
hook.Add("HUDPaint", "BASH_HandleResChange", function()
    //  Handling mid-game resolution changes.
    if SCRW != ScrW() then
        SCRW = ScrW();
        resChanged = true;
    end
    if SCRH != ScrH() then
        SCRH = ScrH();
        resChanged = true;
    end
    if resChanged then
        CENTER_X = SCRW / 2;
        CENTER_Y = SCRH / 2;
        resChanged = false;
    end
end);
