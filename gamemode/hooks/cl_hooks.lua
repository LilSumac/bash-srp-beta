local BASH = BASH;

/*
**  GMod Hooks
*/
function BASH:InitPostEntity()
    MsgN(LocalPlayer():GetClass());
    net.Empty("BASH_PLAYER_INIT");
    BASH.Intro = vgui.Create("bash_intro");
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

//  Debug info to be removed later.
local lastUpdate, fps = 0, 0;
hook.Add("PostRenderVGUI", "BASH_DebugFPS", function()
    if CurTime() - lastUpdate > 0.2 then
        fps = math.Round(1 / FrameTime());
        lastUpdate = CurTime();
    end
    draw.SimpleText(fps, "bash-regular-24", SCRW, 0, color_green, TEXT_RIGHT, TEXT_TOP);
end);
