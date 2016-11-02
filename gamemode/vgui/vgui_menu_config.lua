local MENU = {};
MENU.Settings = {};

function MENU:Init()
    self:SetSize(600, 250);
    self:Center();
    self:SetShowTopBar(true);
    self:SetTopBarButtons(true);
    self:SetDraggable(true);
    self:SetTitle("Initial Config");

    local tabs = {};
    tabs[1] = {Type = TAB_BOTH, Text = "Welcome", Icon = TEXTURE_ERROR, Default = true};
    tabs[2] = {Type = TAB_BOTH, Text = "General", Icon = TEXTURE_ERROR};
    for i = 3, 11 do
        tabs[i] = {Type = TAB_BOTH, Text = "SQL", Icon = TEXTURE_ERROR};
    end
    self:SetTabs(tabs);

    self:SpawnChildren();
end

function MENU:SpawnChildren()
    local y = 6;
    for i = 1, 16 do
        local text = self:AddContent("BTextEntry", 1)
        text:SetPos(6, y);
        text:SetSize(100, 24);
        y = y + 30;
    end
    //text:StretchToParent(6, 6, 6);

    local meme = self:AddContent("DLabel", 2);
    meme:SetPos(5, 5);
    meme:SetText("Fuck you!");
    meme:SizeToContents();
end

function MENU:PostDoClose(minim)
    if minim then return end;
    BASH.IntroStage = 1;
    snow.SendToServer("BASH_CONFIG_INIT_CANCEL");
end

vgui.Register("menu_config", MENU, "BPanel");
