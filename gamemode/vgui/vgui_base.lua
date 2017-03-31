local BASH = BASH;
local Panel = FindMetaTable("Panel");

function Panel:GetParentOfType(type)
    local panel = self;
    while checkpanel(panel) do
        if panel.BClassName == type or panel:GetName() == type then return panel end;
        panel = panel:GetParent();
    end
end

function Panel:AlignTo(target, alignType, margin)
    if !target then return end;
    if !alignType then return end;

    if isstring(target) then
        local parent = self:GetParentOfType("BPanel");
        if !checkpanel(parent) then return end;
        target = parent:GetContentByID(target);
        if !target then return end;
    elseif !target:IsValid() then return end;

    margin = margin or 0;
    local newX, newY = self:GetPos();
    local _w, _h = self:GetSize();
    local x, y = target:GetPos();
    local w, h = target:GetSize();
    //  NICE SWITCH STATEMENT IDIOT.
    if alignType == ALIGN_ABOVE then
        newY = y - _h - margin;
    elseif alignType == ALIGN_ABOVELEFT then
        newX = x;
        newY = y - _h - margin;
    elseif alignType == ALIGN_ABOVECENT then
        newX = (x + (w / 2)) - (_w / 2);
        newY = y - _h - margin;
    elseif alignType == ALIGN_ABOVERIGHT then
        newX = (x + w) - _w;
        newY = y - _h - margin;
    elseif alignType == ALIGN_BELOW then
        newY = y + h + margin;
    elseif alignType == ALIGN_BELOWLEFT then
        newX = x;
        newY = y + h + margin;
    elseif alignType == ALIGN_BELOWCENT then
        newX = (x + (w / 2)) - (_w / 2);
        newY = y + h + margin;
    elseif alignType == ALIGN_BELOWRIGHT then
        newX = (x + w) - _w;
        newY = y + h + margin;
    elseif alignType == ALIGN_LEFT then
        newX = x - _w - margin;
    elseif alignType == ALIGN_LEFTTOP then
        newX = x - _w - margin;
        newY = y;
    elseif alignType == ALIGN_LEFTCENT then
        newX = x - _w - margin;
        newY = (y + (h / 2)) - (_h / 2);
    elseif alignType == ALIGN_LEFTBOT then
        newX = x - _w - margin;
        newY = (y + h) - _h;
    elseif alignType == ALIGN_RIGHT then
        newX = x + w + margin;
    elseif alignType == ALIGN_RIGHTTOP then
        newX = x + w + margin;
        newY = y;
    elseif alignType == ALIGN_RIGHTCENT then
        newX = x + w + margin;
        newY = (y + (h / 2)) - (_h / 2);
    elseif alignType == ALIGN_RIGHTBOT then
        newX = x + w + margin;
        newY = (y + h) - _h;
    end

    self:SetPos(newX, newY);
    target.AlignedChildren = target.AlignedChildren or {};
    target.AlignedChildren[self] = {alignType, margin};

    if !target.LayoutFuncChanged then
        local oldFunc = target.PerformLayout;
        target.OldPerformLayout = oldFunc;
        function target:PerformLayout(oldW, oldH)
            if self.OldPerformLayout then
                self:OldPerformLayout(oldW, oldH);
            end

            if !self.AlignedChildren then return end;
            for panel, tab in pairs(self.AlignedChildren) do
                panel:AlignTo(self, tab[1], tab[2]);
            end
        end
        target.LayoutFuncChanged = true;
    end
end

function Panel:RemoveAlign(target)
    if !target or !target.AlignedChildren then return end;
    target.AlignedChildren[self] = nil;
end

function Panel:IsVisibleByDefault()
    if self.VisibleByDefault == nil then return true end;
    return self.VisibleByDefault;
end

function Panel:SetVisibleByDefault(vis)
    self.VisibleByDefault = vis;
end

/*
**  Base Panel
*/
local PANEL = {};

function PANEL:Init()
    self.BClassName = "BPanel";
    self.GUIID = self:GetName();
    self.BTabs = {};
    self.SelectedTab = nil;
    self.Draggable = false;
    self.ShowTopBar = false;
    self.TopBar = nil;
    self.TopBarSize = 40;

    self:CheckContent();
    self:InvalidateChildren();
end

function PANEL:GetGUIID()
    return self.GUIID;
end

function PANEL:SetDraggable(drag)
    self.Draggable = drag;
    if checkpanel(self.TopBar) then
        self.TopBar:SetDraggable(drag);
    end
end

function PANEL:SetShowTopBar(show)
    self.ShowTopBar = show;

    if show then
        if !checkpanel(self.TopBar) then
            self.TopBar = vgui.Create("BTopBar", self);
            self.TopBar:SetPos(0, 0);
            self.TopBar:SetSize(self:GetWide(), self.TopBarSize);
            self.TopBar:SetDraggable(self.Draggable);
            self.TopBar:SetButtons();
        elseif !self.TopBar:Visible() then
            self.TopBar:SetVisible(true);
        end
    else
        if checkpanel(self.TopBar) and self.TopBar:Visible() then
            self.TopBar:SetVisible(false);
        end
    end

    self:InvalidateChildren();
end

function PANEL:SetTopBarSize(size)
    local old = self.TopBarSize;
    self.TopBarSize = size;
    if old != size then
        self:InvalidateChildren();
    end
end

function PANEL:SetTopBarButtons(minim)
    if !checkpanel(self.TopBar) then return end;

    local old = self.TopBar:GetTall();
    self.TopBar:SetButtons(minim);
    if old != self.TopBar:GetTall() then
        self:SetTopBarSize(self.TopBar:GetTall());
    end

    self:InvalidateChildren();
end

function PANEL:GetTopBar()
    return self.TopBar;
end

function PANEL:SetTitle(title)
    if !checkpanel(self.TopBar) then return end;
    self.TopBar:SetTitle(title);
end

function PANEL:SetTabs(tabs)
    //  Handle tabs.
    if tabs and #tabs > 0 then
        self:CheckSidebar();
        self:RemoveTabs();

        local tabPanel = self.Sidebar;
        if !checkpanel(tabPanel) then return end;

        local textX, width, curWidth, margin = 0, self.TopBarSize * 0.125, 0, self.TopBarSize * 0.125;
        for index, tab in pairs(tabs) do
            tab.Type = tab.Type or TAB_TEXT;
            tab.Font = tab.Font or "CenterPrintText";
            tab.Text = tab.Text or "Tab";
            tab.Icon = tab.Icon or "ok";

            if tab.Type == TAB_TEXT or tab.Type == TAB_BOTH then
                surface.SetFont(tab.Font);
                textX = surface.GetTextSize(tab.Text);
                curWidth = textX + margin + ((tab.Type == TAB_BOTH and self.TopBarSize) or 0);
                if curWidth > width then
                    width = curWidth;
                end
            else
                if self.TopBarSize > width then
                    width = self.TopBarSize;
                end
            end
        end
        width = width + 8;

        local curY = 0;
        for index, tab in pairs(tabs) do
            if !isnumber(index) then continue end;
            self.BTabs[index] = vgui.Create("BTab", tabPanel);
            self.BTabs[index]:SetPos(0, curY);
            self.BTabs[index]:SetSize(width, self.TopBarSize);
            self.BTabs[index]:SetIndex(index);
            self.BTabs[index]:SetType(tab.Type);
            self.BTabs[index]:SetText(tab.Text);
            self.BTabs[index]:SetIcon(tab.Icon);
            self.BTabs[index]:SetCallback(tab.Callback);

            if tab.Default then
                self.BTabs[index]:DoClick();
            end

            curY = curY + self.TopBarSize;
        end
        tabPanel:SetTall(curY);
    end

    self:InvalidateChildren();
end

function PANEL:RemoveTabs()
    for index, tab in pairs(self.BTabs) do
        self.BTabs[index]:Remove();
        self.BTabs[index] = nil;
    end
end

function PANEL:DoClose(minim)
    local id = self:GetGUIID();
    local entry = BASH.GUI.Entries[id];
    if !entry then return end;

    MsgCon(color_green, false, "%s panel %s...", ((minim and "Minimizing") or "Closing"), id);

    if !minim and entry.RequiresMouse then
        BASH.GUI.NumOccupying = BASH.GUI.NumOccupying - 1;
        if BASH.GUI.NumOccupying <= 0 then
            gui.EnableScreenClicker(false);
        end
    end

    if entry.AllowMultiple then
        for index, open in pairs(BASH.GUI.Opened[id]) do
            if open == self then
                BASH.GUI.Opened[id][index] = nil;
                break;
            end
        end
        if minim then
            BASH.GUI.Minimized[id] = BASH.GUI.Minimized[id] or {};
            table.insert(BASH.GUI.Minimized[id], self);
            BASH.GUI.LastMinimized = self;
        end
    else
        BASH.GUI.Opened[id] = nil;
        if minim then
            BASH.GUI.Minimized[id] = self;
            BASH.GUI.LastMinimized = self;
        end
    end
    if minim then
        self:SetVisible(false);
    else
        self:Remove();
    end
    if self.AfterClose then
        self:AfterClose(minim);
    end
end

function PANEL:CheckSidebar()
    if !checkpanel(self.SidebarWrapper) then
        self.SidebarWrapper = vgui.Create("BScroll", self);
        self.SidebarWrapper:SetBGColor(Color(65, 78, 97));
        self.SidebarWrapper:RoundCorners(8, false, false, true);
        self.SidebarWrapper.VBar:SetWide(0);
    end
    if !checkpanel(self.Sidebar) then
        self.Sidebar = vgui.Create("EditablePanel", self.SidebarWrapper);
        self.Sidebar.Paint = function() end;
        self.SidebarWrapper:AddItem(self.Sidebar);
    end
end

function PANEL:CheckContent()
    if !checkpanel(self.ContentWrapper) then
        self.ContentWrapper = vgui.Create("BScroll", self);
        self.ContentWrapper:SetBGColor(Color(40, 40, 40));
    end
    if !checkpanel(self.Content) then
        self.Content = vgui.Create("EditablePanel", self.ContentWrapper);
        self.Content.Paint = function() end;
        self.ContentWrapper:AddItem(self.Content);
    end
end

function PANEL:AddContent(class, tabNum, childID)
    local element = vgui.Create(class, self.Content);
    if !checkpanel(element) then
        MsgErr("[PANEL:AddContent(%s, %d)]: No VGUI class named '%s'!", class);
    end

    element:SetVisible(tabNum == self.SelectedTab);
    element.TabIndex = element.TabIndex or tabNum or 0;
    if childID then
        self.Content.ChildrenIDs = self.Content.ChildrenIDs or {};
        self.Content.ChildrenIDs[childID] = element;
    end
    return element;
end

function PANEL:GetContentByID(id)
    self.Content.ChildrenIDs = self.Content.ChildrenIDs or {};
    return self.Content.ChildrenIDs[id] or false;
end

function PANEL:OnChildAdded(child)
    if child.BClassName == "BTopBar" then return end;
    local x, y = child:GetPos();
    x = math.Clamp(x, 0, self:GetWide());
    y = math.Clamp(y, (self.ShowTopBar and self.TopBarSize) or 0, self:GetTall());
    child:SetPos(x, y);
end

function PANEL:PerformLayout(w, h)
    local showSide = false;
    local sideX, sideY, sideW, sideH = 0, self.TopBarSize, 0, 0;
    local contX, contY, contW, contH = 0, 0, 0, 0;
    if self.ShowTopBar and checkpanel(self.TopBar) then
        self.TopBar:SetPos(0, 0);
        self.TopBar:SetSize(w, self.TopBarSize);

        if self.BTabs and #self.BTabs > 0 then
            if !checkpanel(self.BTabs[1]) then return end;
            local widest = 0;
            for _, tab in pairs(self.BTabs) do
                if tab:GetWide() > widest then
                    widest = tab:GetWide();
                end
            end

            showSide = true;
            sideX, sideY = 0, self.TopBarSize;
            sideW, sideH = widest, h - self.TopBarSize;
            contX, contY = widest, self.TopBarSize;
            contW, contH = w - widest, h - self.TopBarSize;
        else
            contX, contY = 0, self.TopBarSize;
            contW, contH = w, h - self.TopBarSize;
        end
    else
        contX, contY = 0, 0;
        contW, contH = w, h;
    end

    if checkpanel(self.SidebarWrapper) then
        self.SidebarWrapper:SetVisible(showSide);
        self.SidebarWrapper:SetPos(sideX, sideY);
        self.SidebarWrapper:SetSize(sideW, sideH);
    end
    if checkpanel(self.Sidebar) then
        self.Sidebar:SetWide(self.SidebarWrapper:GetWide());
    end

    self.ContentWrapper:SetVisible(true);
    self.ContentWrapper:SetPos(contX, contY);
    self.ContentWrapper:SetSize(contW, contH);

    local tallest, y, curSize = 0, 0, 0;
    for _, child in pairs(self.Content:GetChildren()) do
        if !child:IsVisible() then continue end;
        _, y = child:GetPos();
        curSize = child:GetTall() + y;
        if curSize > tallest then
            tallest = curSize;
        end
    end
    self.Content:SetVisible(true);
    self.Content:SetPos(0, 0);
    self.Content:SetSize(self.ContentWrapper:GetWide() - self.ContentWrapper.VBar:GetWide(), tallest + 6);
end

function PANEL:Paint() end;

vgui.Register("BPanel", PANEL, "EditablePanel");

/*
**  TopBar
*/
local TOPBAR = {};

function TOPBAR:Init()
    self.BClassName = "BTopBar";
    self.Draggable = false;
    self.Dragging = false;
    self.ShowMinimize = false;
    self.Title = "";
    self.BDrag = nil;
    self.BMinim = nil;
    self.BClose = nil;

    self:SetSmoothDrag(BASH.Cookies:Get("smooth_dragging"));
end

function TOPBAR:SetDraggable(drag)
    self.Draggable = drag;
    if drag then
        if !checkpanel(self.BDrag) then
            self.BDrag = vgui.Create("BDrag", self);
            self.BDrag:SetPos(0, 0);
            self.BDrag:SetSize(self:GetTall(), self:GetTall());
        else
            self.BDrag:SetVisible(true);
        end
    else
        if checkpanel(self.BDrag) then
            self.BDrag:SetVisible(false);
        end
    end
end

function TOPBAR:SetSmoothDrag(smooth)
    self.SmoothDrag = smooth;
    local parent = self:GetParentOfType("BPanel");
    if checkpanel(parent) then
        if smooth then
            parent:LerpPositions(2, true);
        else
            parent:DisableLerp();
            parent:Stop();
            parent.SetPosReal = nil;
        end
    end
end

function TOPBAR:SetButtons(minim)
    //  Handle close button.
    if !checkpanel(self.BClose) then
        self.BClose = vgui.Create("BClose", self);
        local w, h = self:GetWide(), self:GetTall();
        self.BClose:SetSize(h / 2, h / 2);
        self.BClose:SetPos(w - (h / 2) - 8, (h / 2) - 8);
    end

    //  Handle minimize button.
    if minim then
        if !checkpanel(self.BMinim) then
            self.BMinim = vgui.Create("BMinim", self);
            local w, h = self:GetWide() - self.BClose:GetWide() - 8, self:GetTall();
            self.BMinim:SetSize(h / 2, h / 2);
            self.BMinim:SetPos(w - (h / 2) - 8, (h / 2) - 8);
        end
    end
end

function TOPBAR:SetTitle(title)
    self.Title = title;
end

function TOPBAR:Think()
    if self.Draggable and self.Dragging then
        if !input.IsMouseDown(MOUSE_LEFT) then
            self.Dragging = false;
            return;
        end

        local parent = self:GetParent();
        if checkpanel(parent) then
            local curX, curY = parent:GetPos();
            local curCursorX, curCursorY = gui.MousePos();
            local diffX = curCursorX - (curX + self.DragStartX);
            local diffY = curCursorY - (curY + self.DragStartY);
            parent:SetPos(curX + diffX, curY + diffY);
        end
    end
end

function TOPBAR:Paint(w, h)
    draw.RoundedBoxEx(8, 0, 0, w, h, Color(53, 64, 82), true, true);
    if self.Draggable then
        surface.SetDrawColor(Color(65, 78, 97));
        surface.DrawLine(h + 1, 0, h + 1, h);
    end
    if self.Title != "" then
        draw.SimpleText(self.Title, "Default", w / 2, h / 2, color_white, TEXT_CENT, TEXT_CENT);
    end
end

vgui.Register("BTopBar", TOPBAR, "Panel");

/*
**  Drag Button
*/
local DRAG = {};

function DRAG:Init()
    self.BClassName = "BDrag";
    self.Entered = false;
    self:SetCursor("hand");
end

function DRAG:OnCursorEntered()
    self.Entered = true;
end

function DRAG:OnCursorExited()
    self.Entered = false;
end

function DRAG:OnMousePressed(code)
    if code == MOUSE_LEFT then
        local parent = self:GetParent();
        if checkpanel(parent) then
            parent.Dragging = true;
            local x, y = self:CursorPos();
            parent.DragStartX = x;
            parent.DragStartY = y;
        end
    end
end

function DRAG:OnMouseReleased(code)
    if code == MOUSE_LEFT then
        local parent = self:GetParent();
        if checkpanel(parent) then
            if parent.Draggable then
                parent.Dragging = false;
                parent.LastCursorX = nil
                parent.LastCursorY = nil;
            end
        end
    end
end

local mc = math.ceil;
local dragPaintParent = nil;
function DRAG:Paint(w, h)
    draw.RoundedBoxEx(8, 0, 0, h, h, Color(65, 78, 97), true);
    surface.SetDrawColor(color_black);
    surface.DrawLine(mc(w * 0.3), mc(h * 0.4), mc(w * 0.7), mc(h * 0.4));
    surface.DrawLine(mc(w * 0.3), mc(h * 0.5), mc(w * 0.7), mc(h * 0.5));
    surface.DrawLine(mc(w * 0.3), mc(h * 0.6), mc(w * 0.7), mc(h * 0.6));

    if !dragPaintParent == nil then
        dragPaintParent = self:GetParentOfType("BPanel");
    end
    if checkpanel(dragPaintParent) then
        if dragPaintParent.BTabs and #dragPaintParent.BTabs > 0 then
            surface.SetDrawColor(Color(53, 64, 82));
            surface.DrawLine(0, h - 1, w, h - 1);
        end
    end
end

vgui.Register("BDrag", DRAG, "Panel");

/*
**  Minimize Button
*/
local MINIM = {};

function MINIM:Init()
    self.BClassName = "BMinim";
    self.Entered = false;

    self:SetFont("marlett");
    self:SetText("0");
    self:SetCursor("hand");
end

function MINIM:OnCursorEntered()
    self.Entered = true;
end

function MINIM:OnCursorExited()
    self.Entered = false;
end

function MINIM:DoClick()
    local parent = self:GetParentOfType("BPanel");
    if checkpanel(parent) then
        parent:DoClose(true);
    end
end

function MINIM:Think()
    if self.Entered and self:GetTextColor() != Color(100, 179, 103) then
        self:SetTextColor(Color(100, 179, 103));
    elseif !self.Entered and self:GetTextColor() != Color(60, 139, 63) then
        self:SetTextColor(Color(60, 139, 63));
    end
end

function MINIM:Paint() end;

vgui.Register("BMinim", MINIM, "DButton");

/*
**  Close Button
*/
local CLOSE = {};

function CLOSE:Init()
    self.BClassName = "BClose";
    self.Entered = false;

    self:SetFont("marlett");
    self:SetText("r");
    self:SetCursor("hand");
end

function CLOSE:OnCursorEntered()
    self.Entered = true;
end

function CLOSE:OnCursorExited()
    self.Entered = false;
end

function CLOSE:DoClick()
    local parent = self:GetParentOfType("BPanel");
    if checkpanel(parent) then
        parent:DoClose();
    end
end

function CLOSE:Think()
    if self.Entered and self:GetTextColor() != Color(179, 100, 103) then
        self:SetTextColor(Color(179, 100, 103));
    elseif !self.Entered and self:GetTextColor() != Color(139, 60, 63) then
        self:SetTextColor(Color(139, 60, 63));
    end
end

function CLOSE:Paint() end;

vgui.Register("BClose", CLOSE, "DButton");

/*
**  Tab Button
*/
local TAB = {};

function TAB:Init()
    self.BClassName = "BTab";
    self.Index = nil;
    self.Selected = false;
    self.HoverColor = Color(28, 29, 34, 0);
    self.Entered = false;
    self.EnteredFlag = 0;
    self.Callback = nil;
    self.Type = TAB_TEXT;
    self.Text = "";
    self.Icon = {};
    self:SetText("");
    self:SetTextColor(color_trans);
end

function TAB:SetIndex(ind)
    self.Index = ind;
end

function TAB:SetType(type)
    self.Type = type;
end

function TAB:SetText(text)
    self.Text = text;
end

function TAB:SetIcon(iconID)
    if self.IsSpacer then return end;
    if !ICONS[iconID] then
        MsgErr("[TAB:SetIcon(%s)]: No icon found with that ID!", iconID);
        return;
    end

    self.Icon = ICONS[iconID];
end

function TAB:SetSelected(selected)
    self.Selected = selected;
end

function TAB:SetCallback(callback)
    self.Callback = callback;
end

function TAB:OnCursorEntered()
    self.Entered = true;
end

function TAB:OnCursorExited()
    self.Entered = false;
end

function TAB:DoClick()
    local parent = self:GetParentOfType("BPanel");
    if checkpanel(parent) then
        local index = self.Index;

        if checkpanel(parent.Content) then
            for _, panel in pairs(parent.Content:GetChildren()) do
                if checkpanel(panel) then
                    panel:SetVisible(panel.TabIndex == index and panel:IsVisibleByDefault());
                end
            end
        end

        if parent.BTabs then
            for index, tab in pairs(parent.BTabs) do
                tab.Selected = false;
            end
            self.Selected = true;
            parent.SelectedTab = index;
        end
        if self.Callback then
            self.Callback();
        end
    end

    parent:InvalidateLayout();
end

function TAB:Think()
    if (self.Entered or self.Selected) and self.HoverColor.a != 255 then
        draw.FadeColorAlpha(self.HoverColor, color_black, 0.05);

        local w = self:GetWide();
        local flagSize = math.Round(w * 0.05);
        if self.Selected and self.EnteredFlag != flagSize then
            self.EnteredFlag = math.lerp(0.05, self.EnteredFlag, flagSize);
        end
    elseif !(self.Entered or self.Selected) and self.HoverColor.a != 0 then
        draw.FadeColorAlpha(self.HoverColor, color_trans, 0.05);

        if !self.Selected and self.EnteredFlag != 0 then
            self.EnteredFlag = math.lerp(0.05, self.EnteredFlag, 0);
        end
    end
end

function TAB:Paint(w, h)
    if self.Entered or self.Selected then
        surface.SetDrawColor(self.HoverColor);
        surface.DrawRect(0, 0, w, h);
        if self.Selected then
            surface.SetDrawColor(60, 139, 63);
            surface.DrawRect(0, 0, self.EnteredFlag, h);
        end
    end

    local x = h * 0.125;
    if self.Type == TAB_ICON or self.Type == TAB_BOTH then
        if self.Icon.Font and self.Icon.Value then
            local size = h * 0.75;
            draw.SimpleText(string.char(self.Icon.Value), "bash-icons-" .. self.Icon.Font, x + (size / 2), x + (size / 2), Color(200, 200, 200), TEXT_CENT, TEXT_CENT);
            x = x + size + (h * 0.125);
        end
    end

    if self.Type == TAB_TEXT or self.Type == TAB_BOTH then
        x = (self.Type == TAB_TEXT and w / 2) or x;
        draw.SimpleText(
            self.Text, "CenterPrintText", x, h / 2,
            Color(110, 110, 110),
            (self.Type == TAB_TEXT and TEXT_CENT) or TEXT_LEFT, TEXT_CENT
        );
    end
end

vgui.Register("BTab", TAB, "DButton");

/*
**  Scroll Panel
*/
local SCROLL = {};

function SCROLL:Init()
    self.ScrollingSet = false;
    self.BGColor = color_black;
    self.CornerRadius = 0;
    self.Corners = {};

    self:SetBarWide(10);
    self.VBar.Paint = function() end;
    self.VBar.btnUp.Paint = function(self, w, h)
        surface.SetDrawColor(200, 200, 200);
        surface.DrawRect(1, 1, w - 2, h - 2);
        surface.SetDrawColor(53, 64, 82);
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2);
    end
    self.VBar.btnDown.Paint = function(self, w, h)
        surface.SetDrawColor(200, 200, 200);
        surface.DrawRect(1, 1, w - 2, h - 2);
        surface.SetDrawColor(53, 64, 82);
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2);
    end
    self.VBar.btnGrip.Paint = function(self, w, h)
        surface.SetDrawColor(200, 200, 200);
        surface.DrawRect(1, 1, w - 2, h - 2);
        surface.SetDrawColor(53, 64, 82);
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2);
    end
end

function SCROLL:SetBarWide(wide)
    self.VBar:SetWide(wide);
end

function SCROLL:SetBGColor(color)
    self.BGColor = color;
end

function SCROLL:OnVScroll(offset)
    local canvas = self:GetCanvas();
    if checkpanel(canvas) then
        if !self.ScrollingSet and BASH.Cookies:Get("smooth_dragging") then
            canvas:LerpPositions(10, false);
            self.ScrollingSet = true;
        end
        canvas:SetPos(0, offset);
    end
end

function SCROLL:RoundCorners(rad, ...)
    self.CornerRadius = rad or 0;
    local args = {...};
    if !args then self.Corners = {} return end;
    for index, round in pairs(args) do
        self.Corners[index] = (round == true);
    end
end

local arrowCol, points = Color(20, 20, 20), nil;
function SCROLL:Paint(w, h)
    local c = self.Corners;
    draw.RoundedBoxEx(self.CornerRadius, 0, 0, w, h, self.BGColor, c[1], c[2], c[3], c[4]);
end

vgui.Register("BScroll", SCROLL, "DScrollPanel");

/*
**  Text Entry
*/
local TENTRY = {};

function TENTRY:Init()
    self.BClassName = "BTextEntry";
    self.EntryChild = self.EntryChild or nil;

    local parent = self:GetParentOfType("BPanel");
    local x, y = parent:GetPos();
    parent:MakePopup();
    parent:SetPos(x, y);
    self:SpawnChildren();
end

function TENTRY:SpawnChildren()
    if !checkpanel(self.EntryChild) then
        self.EntryChild = vgui.Create("BTextEntry_Child", self);
        self.EntryChild:SetPos(0, 0);
        self.EntryChild:SetSize(w, h);
    end
end

function TENTRY:SetText(text)
    if checkpanel(self.EntryChild) then
        self.EntryChild:SetText(text);
    end
end

function TENTRY:GetValue()
    if checkpanel(self.EntryChild) then
        return self.EntryChild:GetValue();
    end
end

function TENTRY:SetDefaultText(text)
    if checkpanel(self.EntryChild) then
        self.EntryChild:SetDefaultText(text);
    end
end

function TENTRY:GetElement()
    return self.EntryChild;
end

function TENTRY:PerformLayout(w, h)
    if checkpanel(self.EntryChild) then
        self.EntryChild:SetSize(w, h);
    end
end

function TENTRY:Paint(w, h) end;

vgui.Register("BTextEntry", TENTRY, "EditablePanel");

/*
**  Text Entry Child
*/
local TENTRY_CHILD = {};

function TENTRY_CHILD:Init()
    self.BClassName = "BTextEntry_Child";
    self.Entered = false;
    self.DefaultText = "Enter text...";
end

function TENTRY_CHILD:SetDefaultText(text)
    self.DefaultText = text;
end

function TENTRY_CHILD:OnCursorEntered()
    self.Entered = true;
end

function TENTRY_CHILD:OnCursorExited()
    self.Entered = false;
end

function TENTRY_CHILD:OnFocusChanged(focus)
    if focus then
        if self:GetText() == self.DefaultText then
            self:SetText("");
        end
    else
        if string.Trim(self:GetText()) == "" then
            self:SetText(self.DefaultText);
        end
    end
end

vgui.Register("BTextEntry_Child", TENTRY_CHILD, "DTextEntry");

/*
**  Long Text Label
*/
local LONG_TEXT = {};

function LONG_TEXT:Init()
    self.LongText = "";
    self.TextCol = color_white;
    self.Font = "CenterPrintText";
end

function LONG_TEXT:SetText(text, width)
    self.LongText = string.wrap(text, self.Font, width or 10000);
    self:SizeToContents();
end

function LONG_TEXT:GetText()
    return self.LongText;
end

function LONG_TEXT:SetTextColor(col)
    self.TextCol = col;
end

function LONG_TEXT:GetTextColor()
    return self.TextCol;
end

function LONG_TEXT:SetFont(font)
    self.Font = font;
    self:SizeToContents();
end

function LONG_TEXT:GetFont()
    return self.Font;
end

function LONG_TEXT:SizeToContents()
    surface.SetFont(self.Font);
    local x, y = surface.GetTextSize(self.LongText);
    self:SetSize(x, y);
end

function LONG_TEXT:Paint(w, h)
    draw.DrawText(self.LongText, self.Font, 0, 0, self.TextCol);
end

vgui.Register("BLongText", LONG_TEXT, "Panel");
