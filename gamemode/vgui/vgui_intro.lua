local INTRO = {};
INTRO.Stage = INTRO.Stage or "Loading";
INTRO.Message = INTRO.Message or "Loading...";
INTRO.CurStep = INTRO.CurStep or 1;
INTRO.SetupElements = INTRO.SetupElements or {};
INTRO.SetupValues = INTRO.SetupValues or {};

/*
**  Local animation/setup variables.
*/

//  Positions
local w, h = SCRW, SCRH;
local x1, x2, y1, y2 = 0, 0, 0, 0;
local left, right, up, down = (w * 0.125), (w * 0.875), (h * 0.2), (h * 0.8);

//  Colors
local colBG, colAnim = colBG or Color(255, 255, 255), colAnim or Color(255, 255, 255);
local colorL, colorT, colorR, colorB;
local bgSeq = {
    Color(51, 153, 255),
    Color(255, 51, 153),
    Color(153, 255, 51),
    Color(0, 153, 153),
    Color(153, 0, 153),
    Color(153, 153, 0),
    Color(0, 153, 76),
    Color(76, 0, 153),
    Color(153, 76, 0)
};

//  Alphas
local alphaBG, alphaAnim = alphaBG or 255, alphaAnim or 0;

//  Materials
local gradH = getMaterial("gui/gradient");
local gradV = getMaterial("gui/gradient_down");

//  Text Resources
local configHeaders = {
    "Welcome to /bash/",
    "General Information"
};
local configSubHeaders = {
    "Thank you for installing BASH. This short walkthrough will set up the most basic information needed to run the gamemode. You can quit and come back to this at any time, although this should only take a minute. Let's get started!",
    "Name your community, and other basic information for your server.",
    "BASH requires an external database to function. Here is where you provide necessary connection information."
};

function INTRO:Init()
    self:SetSize(0, 0);
    self:SetSize(SCRW, SCRH);
end

/*
function INTRO:Think()
    if self:IsVisible() and gui.IsGameUIVisible() then
        self:SetVisible(false);
    elseif !self:IsVisible() and !gui.IsGameUIVisible() then
        self:SetVisible(true);
    end
end
*/

function INTRO:Paint(w, h)
    //if gui.IsGameUIVisible() then return; end

    if !LP().Initialized and !BASH.Config.SettingUp and !BASH.IntroNewPly then
        alphaAnim = Lerp(0.01, alphaAnim, 255);
        draw.FadeColor(colBG, color_white, 0.01);
    end

    colBG.a = alphaBG;
    colAnim.a = alphaAnim;

    local time = CurTime() * 10;
    colorL = HSVToColor(time % 360, 1, 0.5);
    colorT = HSVToColor((time + 30) % 360, 0.5, 0.5);
    colorR = HSVToColor((time + 60) % 360, 0.5, 0.5);
    colorB = HSVToColor((time + 90) % 360, 0.5, 0.5);
    colorL.a = alphaAnim;
    colorT.a = alphaAnim;
    colorR.a = alphaAnim;
    colorB.a = alphaAnim;

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

    if !BASH.Config.InitialSet then
        draw.SimpleText("The initial BASH config has not been set.", "bash-regular-24", CENTER_X, CENTER_Y - 85, colAnim, TEXT_CENT, TEXT_BOT);
        draw.SimpleText("Please wait for the server owner to do the inital setup.", "bash-regular-24", CENTER_X, CENTER_Y + 85, colAnim, TEXT_CENT, TEXT_TOP);
    else
        draw.SimpleText(self.Message, "bash-regular-24", CENTER_X, CENTER_Y - 85, colAnim, TEXT_CENT, TEXT_BOT);
    end

    if LP().Initialized then
        alphaBG = Lerp(0.05, alphaBG, 0);
        alphaAnim = Lerp(0.05, alphaAnim, 0);
        if alphaBG < 1 and alphaAnim < 1 then
            if BASH.IntroNewPly then
                called = false;
                self.Stage = "Setup";
            else
                self.Stage = "Done";
            end
        end
    elseif BASH.Config.SettingUp or BASH.IntroNewPly then
        alphaAnim = Lerp(0.05, alphaAnim, 0);
        if alphaAnim < 1 then
            called = false;
            self.Stage = "Setup";
        end
    end

    x1 = CENTER_X - (math.cos(SysTime()) * 100);
    y1 = CENTER_Y + (math.sin(SysTime() * 2) * 60);
    x2 = CENTER_X - (math.cos(SysTime() - 0.25) * 100);
    y2 = CENTER_Y + (math.sin((SysTime() * 2) - 0.25) * 60);

    draw.Circle(x1 + (10 * -math.cos(SysTime() * 2)), y1 + (10 * math.sin(SysTime())), 4, 10, colAnim);
    draw.Circle(x1 - (10 * -math.cos(SysTime() * 2)), y1 - (10 * math.sin(SysTime())), 4, 10, colAnim);
    draw.Circle(x2, y2, 4, 10, colAnim);
end

vgui.Register("bash_intro", INTRO, "EditablePanel");
