local MENU = {};

function MENU:Init()
    self:SetSize(600, 250);
    self:Center();
    self:SetShowTopBar(true);
    self:SetTopBarButtons(true);
    self:SetDraggable(true);
    self:SetTitle("Initial Config");

    local tabs = {};
    tabs[1] = {Type = TAB_BOTH, Text = "Heyo!", Icon = TEXTURE_ERROR, Default = true, Callback = function() MsgN("HEY!") end};
    tabs[2] = {Type = TAB_TEXT, Text = "Hello!"};
    tabs[3] = {Type = TAB_ICON};
    self:SetTabs(tabs);

    self:SpawnChildren();
end

function MENU:SpawnChildren()
    local text = vgui.Create("BTextEntry", self);
    text:SetPos(40, 40);
    text:SetSize(100, 20);
end

function MENU:DoClose()
    BASH.IntroStage = 1;
    snow.SendToServer("BASH_CONFIG_INIT_CANCEL");
end

vgui.Register("menu_config", MENU, "BPanel");
