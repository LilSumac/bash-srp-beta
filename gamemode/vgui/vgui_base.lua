local BASH = BASH;
local Panel = FindMetaTable("Panel");

function Panel:GetParentOfType(type)
    local panel = self;
    while checkpanel(panel) do
        if panel.BClassName == type or panel:GetName() == type then return panel end;
        panel = panel:GetParent();
    end
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
            tab.Icon = tab.Icon or TEXTURE_ERROR;

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
            self.BTabs[index]:SetBText(tab.Text);
            self.BTabs[index]:SetBIcon(tab.Icon);
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
    if self.PostDoClose then
        self:PostDoClose(minim);
    end
end

function PANEL:CheckSidebar()
    if !checkpanel(self.SidebarWrapper) then
        self.SidebarWrapper = vgui.Create("BScroll", self);
        self.SidebarWrapper:SetBGColor(Color(65, 78, 97));
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

function PANEL:AddContent(class, tabNum)
    local element = vgui.Create(class, self.Content);
    if !checkpanel(element) then
        MsgErr("[PANEL:AddContent(%s, %d)]: No VGUI class named '%s'!", class);
    end

    element:SetVisible(tabNum == self.SelectedTab);
    element.TabIndex = element.TabIndex or tabNum or 0;
    return element;
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
        _, y = child:GetPos();
        curSize = child:GetTall() + y;
        if curSize > tallest then
            tallest = curSize;
        end
    end
    self.Content:SetVisible(true);
    self.Content:SetPos(0, 0);
    self.Content:SetSize(self.ContentWrapper:GetWide() - 24, tallest);
end

function PANEL:Paint(w, h)
    /*
    if self.ShowTopBar then
        surface.SetDrawColor(Color(43, 54, 72));
        surface.DrawRect(0, self.TopBarSize, w, h - self.TopBarSize);
    else
        surface.SetDrawColor(Color(43, 54, 72));
        surface.DrawRect(0, 0, w, h);
    end
    */
end

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
        MsgN(parent);
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
    self.Callback = nil;
    self.Type = TAB_TEXT;
    self.Text = "";
    self.Icon = TEXTURE_ERROR;
    self:SetText("");
end

function TAB:SetIndex(ind)
    self.Index = ind;
end

function TAB:SetType(type)
    self.Type = type;
end

function TAB:SetBText(text)
    self.Text = text;
end

function TAB:SetBIcon(icon)
    self.Icon = icon;
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
                    panel:SetVisible(panel.TabIndex == index);
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
end

function TAB:Think()
    if (self.Entered or self.Selected) and self.HoverColor.a != 255 then
        draw.FadeColorAlpha(self.HoverColor, color_black, 0.05);
    elseif !(self.Entered or self.Selected) and self.HoverColor.a != 0 then
        draw.FadeColorAlpha(self.HoverColor, color_trans, 0.05);
    end
end

function TAB:Paint(w, h)
    if self.Entered or self.Selected then
        surface.SetDrawColor(self.HoverColor);
        surface.DrawRect(0, 0, w, h);
        if self.Selected then
            surface.SetDrawColor(Color(34, 125, 170));
            surface.DrawRect(0, 0, w * 0.05, h);
        end
    end

    local x = h * 0.125;
    if self.Type != TAB_TEXT then
        local size = h * 0.75;
        surface.SetDrawColor(color_white);
        surface.SetMaterial(self.Icon);
        surface.DrawTexturedRect(x, h * 0.125, size, size);
        x = x + size + (h * 0.125);
    end

    if self.Type != TAB_ICON then
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

    self.VBar:SetWide(8);
    self.VBar.Paint = function() end;
    self.VBar.btnUp.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 100));
    end
    self.VBar.btnDown.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 100));
    end
    self.VBar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 100));
    end
end

function SCROLL:SetBGColor(color)
    self.BGColor = color;
end

function SCROLL:OnVScroll(offset)
    local canvas = self:GetCanvas();
    if checkpanel(canvas) then
        if !self.ScrollingSet and BASH.Cookies:Get("smooth_dragging") then
            canvas:LerpPositions(7, false);
            self.ScrollingSet = true;
        end
        canvas:SetPos(0, offset);
    end
end

local arrowCol, points = Color(20, 20, 20), nil;
function SCROLL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, self.BGColor);
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

/*
function TENTRY_CHILD:Paint(w, h)
    surface.SetDrawColor((self.Entered and color_con) or (self:HasFocus() and color_red) or color_black);
    surface.DrawRect(0, 0, w, h);
    surface.SetDrawColor(color_con);
    surface.DrawOutlinedRect(0, 0, w, h);
end
*/

vgui.Register("BTextEntry_Child", TENTRY_CHILD, "DTextEntry");
