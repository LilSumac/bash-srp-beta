local BASH = BASH;

/*
**  GMod Hooks
*/
function BASH:InitPostEntity()
    net.Empty("BASH_PLAYER_INIT");
end

BASH.IntroStage = BASH.IntroStage or 1;
BASH.ConfigSet = BASH.ConfigSet or false;
local colBG, colAnim = colBG or Color(0, 0, 0), colAnim or Color(0, 0, 0);
local colError = Color(153, 0, 0);
local alphaBG, alphaAnim = alphaBG or 255, alphaAnim or 0;
local x1, x2, y1, y2 = 0, 0, 0, 0;
//local animVal, animDir = animVal or 1, animDir or 1;
local gradH = Material("gui/gradient");
local gradV = Material("gui/gradient_down");
local colorL, colorT, colorR, colorB;
function BASH:PostRenderVGUI()
    if gui.IsGameUIVisible() or self.IntroStage > 1 then return end;

    if !LocalPlayer().Initialized then
        alphaAnim = Lerp(0.01, alphaAnim, 255);
        draw.FadeColor(colBG, color_black, 0.01);
        draw.FadeColor(colAnim, color_white, 0.01);
    end

    colBG.a = alphaBG;
    colAnim.a = alphaAnim;

    //draw.RoundedBox(0, 0, 0, SCRW, SCRH, colBG);

    local time = CurTime() * 10;
    colorL = HSVToColor(time % 360, 1, 0.5);
    colorT = HSVToColor((time + 30) % 360, 0.5, 0.5);
    colorR = HSVToColor((time + 60) % 360, 0.5, 0.5);
    colorB = HSVToColor((time + 90) % 360, 0.5, 0.5);
    colorL.a = alphaAnim;
    colorT.a = alphaAnim;
    colorR.a = alphaAnim;
    colorB.a = alphaAnim;

    local w, h = SCRW, SCRH;
    surface.SetDrawColor(colBG);
    surface.DrawRect(0, 0, w, h);

    surface.SetMaterial(gradH);
    surface.SetDrawColor(colorL);
    surface.DrawTexturedRect(0, 0, w, h);

    surface.SetMaterial(gradH);
    surface.SetDrawColor(colorR);
    surface.DrawTexturedRectUV(0, 0, w, h, 1, 0, 0, 1);

    surface.SetMaterial(gradV);
    surface.SetDrawColor(colorT);
    surface.DrawTexturedRect(0, 0, w, h);

    surface.SetMaterial(gradV);
    surface.SetDrawColor(colorB);
    surface.DrawTexturedRectUV(0, 0, w, h, 0, 1, 1, 0);

    if !self.ConfigSet then
        draw.SimpleText("The initial BASH config has not been set.", "ChatFont", CENTER_X, CENTER_Y - 85, colAnim, TEXT_CENT, TEXT_BOT);
        draw.SimpleText("Please wait for the server owner to do the inital setup.", "ChatFont", CENTER_X, CENTER_Y + 85, colAnim, TEXT_CENT, TEXT_TOP);
    end

    /*  Old Anim
    if !LocalPlayer().Initialized then
        if animVal < 0.01 then
            animDir = 1;
            animVal = 0.01;
        elseif animVal > 0.99 then
            animDir = 0;
            animVal = 0.98;
        end
    else
        animDir = 1.0035;
        if animVal >= 1.003 then
            if !self.ConfigSet then
                draw.FadeColor(colAnim, colError, 0.05);
            else
                draw.FadeColor(colBG, color_black, 0.05);
                alphaBG = Lerp(0.05, alphaBG, 0);
                alphaAnim = Lerp(0.05, alphaAnim, 0);
            end
        end
    end

    animVal = Lerp(0.025, animVal, animDir);
    draw.Radial(CENTER_X, CENTER_Y, 75, 360 * animVal, (360 * animVal) + 90, colAnim);
    */

    if LocalPlayer().Initialized then
        draw.FadeColor(colBG, color_black, 0.05);
        alphaBG = Lerp(0.05, alphaBG, 0);
        alphaAnim = Lerp(0.05, alphaAnim, 0);

        if alphaBG == 0 and alphaAnim == 0 then
            self.IntroStage = 2;
        end
    elseif !self.ConfigSet then
        draw.FadeColor(colAnim, color_white, 0.05);
    end

    x1 = CENTER_X - (math.cos(SysTime()) * 100);
    y1 = CENTER_Y + (math.sin(SysTime() * 2) * 60);
    x2 = CENTER_X - (math.cos(SysTime() - 0.25) * 100);
    y2 = CENTER_Y + (math.sin((SysTime() * 2) - 0.25) * 60);

    draw.Circle(x1 + (10 * -math.cos(SysTime() * 2)), y1 + (10 * math.sin(SysTime())), 4, 10, colAnim);
    draw.Circle(x1 - (10 * -math.cos(SysTime() * 2)), y1 - (10 * math.sin(SysTime())), 4, 10, colAnim);
    draw.Circle(x2, y2, 4, 10, colAnim);
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
