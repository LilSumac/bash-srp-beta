/*
**  this is the ugliest file in the entire project
**  just move along, please
*/

local BASH = BASH;
BASH.Intro = BASH.Intro or {};
BASH.Intro.Stage = BASH.Intro.Stage or "Loading";
BASH.Intro.Message = BASH.Intro.Message or "Loading...";
BASH.Intro.CurStep = BASH.Intro.CurStep or 1;
BASH.Intro.SetupElement = BASH.Intro.SetupElement or nil;
BASH.Intro.EnteredVals = BASH.Intro.EnteredVals or {};
BASH.ConfigSet = BASH.ConfigSet or false;
BASH.SettingConfig = BASH.SettingConfig or false;
BASH.IntroNewPly = BASH.IntroNewPly or false;

/*
**  Local animation/setup variables here!
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
    Color(0, 153, 153),
    Color(102, 0, 204)
};

//  Alphas
local alphaBG, alphaAnim = alphaBG or 255, alphaAnim or 0;

//  Materials
local gradH = Material("gui/gradient");
local gradV = Material("gui/gradient_down");

//  Element Resources
local called = false;
local headers = {
    "Welcome to BASH",
    "General Information",
    "Database Credentials"
};
local subheaders = {
    "Thank you for installing BASH. This short walkthrough will set up the most basic information needed to run the gamemode. You can quit and come back to this at any time, although this should only take a minute. Let's get started!",
    "Name your community, and other basic information for your server.",
    "BASH requires an external database to function. Here is where you provide necessary connection information."
};
local elements = {
    {},
    {"community_name", "community_website"},
    {"sql_host", "sql_user", "sql_pass", "sql_name", "sql_port"}
};

/*
**
*/

function BASH.Intro:DrawLoading()
    if gui.IsGameUIVisible() then return end;

    if !LP().Initialized and !BASH.SettingConfig then
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

    if !BASH.ConfigSet then
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
                self.Stage = "NewPly";
            else
                self.Stage = "Done";
            end
        end
    elseif BASH.SettingConfig then
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

function BASH.Intro:DrawSetup()
    if called then return end;
    local elem, bk, nx = self.SetupElement;
    if !checkpanel(elem) then
        //  Just to prevent an empty frame with the awkward background.
        surface.SetDrawColor(colBG);
        surface.DrawRect(0, 0, w, h);

        elem = vgui.Create("DFrame");
        elem:SetSize(w, h);
        elem:SetPos(0, 0);
        elem:SetTitle("");
        elem:ShowCloseButton(false);
        elem:SetDraggable(false);
        elem:MakePopup();
        elem.SubCache = string.Explode('\n', string.wrap(subheaders[1], "bash-light-24", w * 0.33));
        elem.StepChildren = {};
        elem.SetStep = function(_self, step)
            BASH.Intro.CurStep = step;
            for _step, children in pairs(_self.StepChildren) do
                for _, child in pairs(children) do
                    child:SetVisible(_step == step);
                end
            end

            local sub = string.wrap(subheaders[step], "bash-light-24", w * 0.33);
            _self.SubCache = string.Explode('\n', sub);

            if step == 1 then
                _self.BackButton.DrawText = "Cancel";
                _self.NextButton.DrawText = "Begin";
            elseif step == #elements then
                _self.BackButton.DrawText = "Back";
                _self.NextButton.DrawText = "Finish";
            else
                _self.BackButton.DrawText = "Back";
                _self.NextButton.DrawText = "Next";
            end
        end
        elem.Think = function(_self)
            //  Stop popup from being annoying in GMod menu.
            if gui.IsGameUIVisible() then
                _self:SetPos(0, h + 1);
            else
                _self:SetPos(0, 0);
            end
        end
        elem.Paint = function(_self, _w, _h)
            if alphaAnim < 254 then
                alphaAnim = Lerp(0.01, alphaAnim, 255);
            end

            draw.FadeColor(colBG, bgSeq[BASH.Intro.CurStep], 0.025);
            colBG.a = alphaBG;
            colAnim.a = alphaAnim;

            surface.SetDrawColor(colBG);
            surface.DrawRect(0, 0, _w, _h);

            draw.SimpleText(headers[BASH.Intro.CurStep], "bash-regular-36", _w / 2, (h * 0.2), colAnim, TEXT_CENT, TEXT_TOP);
            //  Cache the subheader lines for efficiency.
            for index, line in pairs(_self.SubCache) do
                draw.SimpleText(line, "bash-light-24", _w / 2, (h * 0.2) + 40 + ((index - 1) * 24) + ((BASH.Intro.CurStep == 1 and 100) or 0), colAnim, TEXT_CENT, TEXT_TOP);
            end

            local wid = (8 * #elements) + (24 * (#elements - 1));
            for index = 1, #elements do
                draw.Circle(
                    (CENTER_X - (wid / 2)) + (24 * (index - 1)) + 4,
                    (h * 0.8) - 16,
                    4, 10, (BASH.Intro.CurStep == index and Color(128, 128, 128, alphaAnim)) or colAnim
                );
            end
        end

        elem.BackButton = vgui.Create("DButton", elem);
        bk = elem.BackButton;
        bk:SetSize(150, 36);
        bk:SetPos(left, down - 36);
        bk:SetText("");
        bk.DrawText = "Cancel";
        bk.DoClick = function(_self)
            if BASH.Intro.CurStep == 1 then
                net.Empty("BASH_CONFIG_INIT_CANCEL");
                BASH.Intro.Stage = "Loading";
                BASH.SettingConfig = false;
                alphaAnim = 0;

                local parent = _self:GetParent();
                parent:Remove();
                parent = nil;
                return;
            end
            _self:GetParent():SetStep(BASH.Intro.CurStep - 1);
        end
        bk.Paint = function(_self, _w, _h)
            draw.SimpleText(_self.DrawText, "bash-regular-36", _w / 2, 0, colAnim, TEXT_CENT, TEXT_TOP);
        end

        elem.NextButton = vgui.Create("DButton", elem);
        nx = elem.NextButton;
        nx:SetSize(150, 36);
        nx:SetPos(right - 150, down - 36);
        nx:SetText("");
        nx.DrawText = "Begin";
        nx.DoClick = function(_self)
            if BASH.Intro.CurStep == #elements then

                return;
            end
            _self:GetParent():SetStep(BASH.Intro.CurStep + 1);
        end
        nx.Paint = function(_self, _w, _h)
            draw.SimpleText(_self.DrawText, "bash-regular-36", _w / 2, 0, colAnim, TEXT_CENT, TEXT_TOP);
        end
    end

    called = true;
end

//  Local function for handling hook callback.
local function introLogic()
    if BASH.Intro["Draw" .. BASH.Intro.Stage] then
        BASH.Intro["Draw" .. BASH.Intro.Stage](BASH.Intro);
    end
end
hook.Add("PostRenderVGUI", "BASH_DrawIntro", introLogic);
