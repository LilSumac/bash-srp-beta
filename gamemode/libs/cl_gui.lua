local BASH = BASH;
BASH.GUI = {};
BASH.GUI.Name = "GUI";
BASH.GUI.Entries = {};
BASH.GUI.Opened = {};
BASH.GUI.Minimized = {};

function BASH.GUI:Init()
    MsgCon(color_green, true, "Initializing GUI...");
    if !BASH:LibDepMet(self) then return end;

    local gui = {
        ID = "menu_config",
        Name = "Initial Config",
        Class = "menu_config"
    };
    self:AddEntry(gui);

    MsgCon(color_green, true, "GUI initialization complete!");
end

function BASH.GUI:AddEntry(guiTab)
    if !guiTab then return end;
    if !guiTab.ID then
        MsgErr("[BASH.GUI:AddEntry(%s)]: Tried adding a GUI with no ID!", concatArgs(guiTab));
        return;
    end
    if self.Entries[guiTab.ID] then
        MsgErr("[BASH.GUI:AddEntry(%s)]: A GUI with the ID '%s' already exists!", concatArgs(guiTab), guiTab.ID);
        return;
    end

    guiTab.Name = guiTab.Name or "Unknown GUI";
    guiTab.Class = guiTab.Class or "BPanel";
    guiTab.AllowMultiple = guiTab.AllowMultiple or false;

    self.Entries[guiTab.ID] = guiTab;
end

function BASH.GUI:Open(id)
    if !self.Entries[id] then return end;

    local entry = self.Entries[id];
    if self.Opened[id] and self.Opened[id]:IsValid() and !entry.AllowMultiple then return end;
    if self.Minimized[id] and self.Minimized[id]:IsValid() then
        local panel = self.Minimized[id];
        panel:SetVisible(true);
        self.Opened[id] = panel;
        self.Minimized[id] = nil;
        return;
    end

    gui.EnableScreenClicker(true);
    self.Opened[id] = vgui.Create(entry.Class, nil, id);
    if !self.Opened[id] or !self.Opened[id]:IsValid() then
        self.Opened[id] = nil;
        MsgErr("[BASH.GUI:OpenGUI(%s)]: The GUI class for this ID doesn't exist!", id);
        return;
    end
    self.Opened[id]:InvalidateLayout();
    MsgDebug("Creating panel %s...", id);
end

function BASH.GUI:Minimize(id)
    if !self.Entries[id] then return end;
    if !self.Opened[id] then return end;
    if self.Opened[id] and self.Opened[id]:IsValid() then
        MsgDebug("Minimizing panel %s...", id);
        local panel = self.Opened[id];
        panel:SetVisible(false);
        self.Opened[id] = nil;
        self.Minimized[id] = panel;
        return;
    end
end
