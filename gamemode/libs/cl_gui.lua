local BASH = BASH;
BASH.GUI = {};
BASH.GUI.Name = "GUI";
BASH.GUI.Entries = BASH.GUI.Entries or {};
BASH.GUI.Opened = BASH.GUI.Opened or {};
BASH.GUI.Minimized = BASH.GUI.Minimized or {};
BASH.GUI.NumOccupying = BASH.GUI.NumOccupying or 0;
BASH.GUI.LastMinimized = BASH.GUI.LastMinimized or nil;

function BASH.GUI:Init()
    /*
    **  Create Default GUI Elements
    */

    self:AddEntry{
        ID = "menu_config",
        Name = "Initial Config",
        Class = "menu_config",
        RequiresMouse = true
    };

    hook.Call("LoadGUI", BASH);
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
    guiTab.RequiresMouse = guiTab.RequiresMouse or false;

    self.Entries[guiTab.ID] = guiTab;
end

function BASH.GUI:Open(id)
    if !self.Entries[id] then return end;

    local entry = self.Entries[id];
    if !entry.AllowMultiple and checkpanel(self.Opened[id]) then return end;

    if entry.RequiresMouse then
        gui.EnableScreenClicker(true);
        self.NumOccupying = self.NumOccupying + 1;
    end
    local panel = vgui.Create(entry.Class, nil, id);
    if !checkpanel(panel) then
        MsgErr("[BASH.GUI:OpenGUI(%s)]: The GUI class for this ID doesn't exist!", id);
        return;
    end
    if entry.AllowMultiple then
        self.Opened[id] = self.Opened[id] or {};
        table.insert(self.Opened[id], panel);
    else
        self.Opened[id] = panel;
    end
    panel:InvalidateLayout();
    MsgDebug("Creating panel %s...", id);
end

function BASH.GUI:Maximize(panel)
    if checkpanel(panel) then
        MsgCon(color_green, false, "Maximizing panel %s...", tostring(panel));
        panel:SetVisible(true);

        local id = panel:GetGUIID();
        if !id then return end;
        local entry = self.Entries[id];
        if !entry then return end;
        if entry.AllowMultiple then
            for index, open in pairs(self.Minimized[id]) do
                if open == panel then
                    self.Minimized[id][index] = nil;
                    break;
                end
            end
            self.Opened[id] = self.Opened[id] or {};
            table.insert(self.Opened[id], panel);
        else
            self.Minimized[id] = nil;
            self.Opened[id] = panel;
        end
    end
end

BASH:RegisterLib(BASH.GUI);
