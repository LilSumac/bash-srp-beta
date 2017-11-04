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
    Color(0, 153, 76),
    Color(153, 153, 0)
};

//  Alphas
local alphaBG, alphaAnim = alphaBG or 255, alphaAnim or 0;

//  Materials
local gradH = Material("gui/gradient");
local gradV = Material("gui/gradient_down");

//  Element Resources
local called = false;
local confHeaders = {
    "Welcome to BASH",
    "General Information",
    "Database Credentials"
};
local confSubheaders = {
    "Thank you for installing BASH. This short walkthrough will set up the most basic information needed to run the gamemode. You can quit and come back to this at any time, although this should only take a minute. Let's get started!",
    "Name your community, and other basic information for your server.",
    "BASH requires an external database to function. Here is where you provide necessary connection information."
};
local confElements = {
    {},
    {"community_name", "community_website"},
    {"sql_host", "sql_user", "sql_pass", "sql_name", "sql_port"}
};
local newHeaders = {
    "Welcome!",
    "What is #!/BASH?",
    "How do you play?",
    "Header3"
};
local newSubheaders = {
    "Hello and welcome to the #!/BASH public beta. You're in for an exclusive look at a roleplay gamemode many years in the making. Please keep these things in mind:<br><br>* All features and content are subject to change.<br>* Any bugs or instabilities are being worked on, and we appreciate your patience.<br>* Staff are waiting and ready to assist you should you need it.<br><br>By proceeding, you agree to abide by the server rules.",
    "BASH is a gamemode developed by LilSumac over the course of several years. In early 2016, an alpha version was released as a public server, to mild success. However, the gamemode itself was not ready for the demands of a populated server, and thus the project was scrapped. Source code for the alpha can be found at github.com/LilSumac/bash-srp-alpha.<br><br>Now, after completely gutting the initial version and starting anew, the BASH beta aims to deliver a smooth, streamlined experience to you, the player. We hope that you find the gamemode to be responsive, immersive, and visually appealing.",
    "Like many other popular gamemodes such as Clockwork, NutScript, and TacoScript, BASH is a serious roleplay framework. This is not a DarkRP, PERP, or any other 'lite' RP gamemode, and should not be played as one. BASH relies heavily on character creation, development, and interaction with your fellow players rather than just shooting and looting. In addition, the gamemode itself is usually based within some kind of universe, ranging from popular video games such as S.T.A.L.K.E.R. and Half-life 2 to more realistic scenarios like real-world military conflicts and apocalyptic settings.<br><br>If you are unfamiliar with the concept described here, feel free to reach out to a staff member and they will assist you in getting oriented.",
    "Sub 3"
};
local newElements = {};

/*
**
*/

function BASH.Intro:DrawLoading()
    if gui.IsGameUIVisible() then return end;

    if !LP().Initialized and !BASH.SettingConfig and !BASH.IntroNewPly then
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
                called = false;
                self.Stage = "Setup";
            else
                self.Stage = "Done";
            end
        end
    elseif BASH.SettingConfig or BASH.IntroNewPly then
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
    local elements = (BASH.SettingConfig and confElements) or newElements;
    local headers = (BASH.SettingConfig and confHeaders) or newHeaders;
    local subheaders = (BASH.SettingConfig and confSubheaders) or newSubheaders;
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
        elem.SubCache = string.Explode('\n', string.wrap(subheaders[1], "bash-light-24", w * 0.4));
        elem.StepChildren = {};
        elem.SetStep = function(_self, step)
            BASH.Intro.CurStep = step;
            for _step, children in pairs(_self.StepChildren) do
                for _, child in pairs(children) do
                    child:SetVisible(_step == step);
                end
            end

            local sub = string.wrap(subheaders[step], "bash-light-24", w * 0.4);
            _self.SubCache = string.Explode('\n', sub);

            if step == 1 then
                if BASH.SettingConfig then
                    _self.BackButton.DrawText = "Cancel";
                else
                    _self.BackButton.DrawText = "Disconnect";
                end
                _self.NextButton.DrawText = "Begin";
            elseif step == #headers then
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
                if BASH.IntroNewPly or (BASH.SettingConfig and BASH.Intro.CurStep == 1) then
                    local boxH = 24 * #_self.SubCache;
                    //  Center the new player intro text.
                    draw.SimpleText(line, "bash-light-24", _w / 2, (_h / 2) - (boxH / 2) + ((index - 1) * 24), colAnim, TEXT_CENT, TEXT_TOP);
                elseif BASH.SettingConfig then
                    //  Offset the config setup text.
                    draw.SimpleText(line, "bash-light-24", _w / 2, (h * 0.2) + 40 + ((index - 1) * 24), colAnim, TEXT_CENT, TEXT_TOP);
                end
            end

            local wid = (32 * #headers) - 24;
            for index = 1, #headers do
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
        bk.DrawText = (BASH.SettingConfig and "Cancel") or "Disconnect";
        bk.DoClick = function(_self)
            if _self.DrawText == "Disconnect" then
                RunConsoleCommand("disconnect");
                return;
            end

            if BASH.Intro.CurStep == 1 then
                if BASH.SettingConfig then
                    net.Empty("BASH_CONFIG_INIT_CANCEL");
                    BASH.SettingConfig = false;
                end

                BASH.Intro.Stage = "Loading";
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
            if BASH.Intro.CurStep == #headers then

                return;
            end
            _self:GetParent():SetStep(BASH.Intro.CurStep + 1);
        end
        nx.Paint = function(_self, _w, _h)
            draw.SimpleText(_self.DrawText, "bash-regular-36", _w / 2, 0, colAnim, TEXT_CENT, TEXT_TOP);
        end

        elem.ContentWrapper = vgui.Create("BScroll", elem);
        local contWrap = elem.ContentWrapper;
        contWrap:SetPos(0, up + 60);
        contWrap:CenterHorizontal();
        contWrap:SetSize(w * 0.4, down - up - 96);
        contWrap:SetBGColor(color_trans);

        elem.Content = vgui.Create("EditablePanel", elem.ContentWrapper);
        local cont = elem.Content;
        cont.Paint = function() end
        contWrap:AddItem(cont);
    end

    local step = self.CurStep;
    if elements[step] then
        elem.StepChildren[step] = {};
        local len = #elements[step];
        local height = (96 * len) - 24;
        local curY = 0;
        local curConf, cTitle, cDesc, cEntry;
        for index, element in ipairs(elements[step]) do
            curConf = BASH.Config.IDRef[element];
            if !curConf then continue end;

            cTitle = vgui.Create("DLabel", elem.Content);
            cTitle:SetPos(0, curY);
            cTitle:SetFont("bash-regular-24");
            cTitle:SetText(curConf.Name);
            cTitle:SizeToContents();
            cTitle:SetVisible(BASH.Intro.CurStep);
            elem.StepChildren[step][index] = cTitle;
            curY = curY + cTitle:GetTall();

            cDesc = vgui.Create("BLongText", elem);
            cDesc:AlignTo(cTitle, ALIGN_BELOWLEFT);
            cDesc:SetFont("bash-light-24");
            cDesc:SetText(curConf.Desc);
            //elem.StepChildren[step][index]
        end
        local x, y = cEntry:GetPos();
        elem.Content:SetTall(y + cEntry:GetTall());
    end

    called = true;
end

//  Local function for handling hook callback.
local function introLogic()
    if BASH.Intro["Draw" .. BASH.Intro.Stage] then
        BASH.Intro["Draw" .. BASH.Intro.Stage](BASH.Intro);
    end
end
//hook.Add("PostRenderVGUI", "BASH_DrawIntro", introLogic);
