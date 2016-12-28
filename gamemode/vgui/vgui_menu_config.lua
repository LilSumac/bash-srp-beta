local MENU = {};
MENU.Settings = {};
MENU.WelcomeText = [[
Thank you for installing the BASH Public Beta! This dialogue will guide you through
 the process of setting up the essential features for this gamemode. This will involve
 entering information like your community name, SQL database credentials, and other
 basic configuration entries.
]]

function MENU:Init()
    self:SetSize(600, 250);
    self:Center();
    self:SetShowTopBar(true);
    self:SetTopBarButtons();
    self:SetDraggable(true);
    self:SetTitle("Initial Config");

    self:SpawnChildren();
end

function MENU:SpawnChildren()
    //  Shoddy way of ordering it the way I like. :^)
    local orderedConfig = {"Information", "SQL", "Developer"};
    local conf, subConf, tabs = BASH.Config.Entries["Base Config"], {}, {};
    local index = 2;
    tabs[1] = {Type = TAB_BOTH, Text = "Welcome", Icon = "heart-empty", Default = true};
    for _, sub in pairs(orderedConfig) do
        subConf = conf[sub];
        if !istable(subConf) then continue end;
        tabs[index] = {Type = (subConf.Icon and TAB_BOTH) or TAB_TEXT, Text = sub, Icon = (subConf.Icon or nil)};
        index = index + 1;
    end
    tabs[index] = {Type = TAB_BOTH, Text = "Submit", Icon = "ok"};
    self:SetTabs(tabs);

    //  Positional variables.
    local w, h = self.Content:GetSize();
    w = w - self.ContentWrapper.VBar:GetWide(); //  Stuff can't go behind the scroll bar.
    local x, y = 6, 6;

    //  Base config.
    index = 2;
    for _, sub in pairs(orderedConfig) do
        subConf = conf[sub];
        if !istable(subConf) then continue end;

        local cTitle, cDesc, cEntry;
        for _, confTab in pairs(subConf) do
            if !istable(confTab) then continue end;
            if !confTab.Name or !confTab.Desc or !confTab.MenuElement then continue end;

            cTitle = self:AddContent("DLabel", index);
            if cEntry then
                cTitle:AlignTo(cEntry, ALIGN_BELOWLEFT, 6);
            else
                cTitle:SetPos(x, y);
            end
            cTitle:SetFont("DermaDefaultBold");
            cTitle:SetText(confTab.Name);
            cTitle:SizeToContents();

            cDesc = self:AddContent("BLongText", index);
            cDesc:AlignTo(cTitle, ALIGN_BELOWLEFT, 2);
            cDesc:SetFont("DermaDefault");
            cDesc:SetText(confTab.Desc, w - 6);

            cEntry = self:AddContent(confTab.MenuElement, index, "entry_" .. confTab.ID);
            cEntry:AlignTo(cDesc, ALIGN_BELOWLEFT, 2);
            if confTab.MenuElement == "BTextEntry" then
                cEntry:SetWide(w * 0.5);
                cEntry:SetText(confTab.Default);
            elseif confTab.MenuElement == "DNumberWang" then
                cEntry:SetMinMax(confTab.Min, confTab.Max);
                cEntry:SetValue(confTab.Default);
            elseif confTab.MenuElement == "DCheckBox" then
                cEntry:SetValue(confTab.Default);
            end
        end

        index = index + 1;
    end

    //  Welcome panel.
    local tempPanel = self:AddContent("DLabel", 1, "welcome_title");
    tempPanel:SetPos(0, y);
    tempPanel:SetFont("Trebuchet24");
    tempPanel:SetText("Welcome to the Public BASH Beta!");
    tempPanel:SizeToContents();
    tempPanel:CenterHorizontal();

    tempPanel = self:AddContent("BLongText", 1);
    tempPanel:SetPos(x, y);
    tempPanel:AlignTo("welcome_title", ALIGN_BELOW, 6);
    tempPanel:SetFont("DermaDefault");
    tempPanel:SetText(self.WelcomeText, w - 6);

    //  Submit panel.
    tempPanel = self:AddContent("BLongText", index, "submit_title");
    tempPanel:SetPos(x, y);
    tempPanel:SetText("All done? Click the button below to submit your settings!", w - 6);

    tempPanel = self:AddContent("DButton", index, "submit_button");
    tempPanel:AlignTo("submit_title", ALIGN_BELOWLEFT, 6);
    tempPanel:SetText("Submit");
    function tempPanel:DoClick()
        local parent = self:GetParentOfType("BPanel");
        parent.Settings = parent.Settings or {};

        local conf = BASH.Config.Entries["Base Config"];
        local curElem, curVal;
        for _, subConf in pairs(conf) do
            if !istable(subConf) then continue end;

            for _, confTab in pairs(subConf) do
                if !istable(confTab) then continue end;
                if !confTab.MenuElement then continue end;

                curElem = parent:GetContentByID("entry_" .. confTab.ID);
                if !checkpanel(curElem) then continue end;

                if confTab.MenuElement == "BTextEntry" or confTab.MenuElement == "DNumberWang" then
                    parent.Settings[confTab.ID] = curElem:GetValue();
                elseif confTab.MenuElement == "DCheckBox" then
                    parent.Settings[confTab.ID] = curElem:GetChecked();
                end
            end
        end

        local errMsg = parent:GetContentByID("submit_error");
        errMsg:SetVisible(true);
        errMsg:SetVisibleByDefault(true);
    end

    tempPanel = self:AddContent("BLongText", index, "submit_error");
    tempPanel:SetFont("DermaDefault");
    tempPanel:SetTextColor(color_red);
    tempPanel:AlignTo("submit_button", ALIGN_RIGHTCENT, 6);
    tempPanel:SetText("Not all required config values have been set! Please go back and make sure all required fields are filled out and valid.", w - tempPanel:GetPos() - 6);
    tempPanel:SetVisible(false);
    tempPanel:SetVisibleByDefault(false);
end

function MENU:VerifyConfig()

end

function MENU:AfterClose(minim)
    if minim then return end;
    BASH.IntroStage = 1;
    net.Empty("BASH_CONFIG_INIT_CANCEL");
end

vgui.Register("menu_config", MENU, "BPanel");
