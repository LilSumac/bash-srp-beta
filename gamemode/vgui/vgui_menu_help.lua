local MENU = {};

function MENU:Init()
    self:SetSize(500, 200);
    self:Center();
    self:SetShowTopBar(true);
    self:SetTopBarButtons(true);
    self:SetDraggable(true);
    self:SetTitle("Help Center");
end

function MENU:DoClose()

end

vgui.Register("menu_help", MENU, "BPanel");
