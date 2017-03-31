Conf_Group = {};
Conf_Group.meta = {};
Conf_Group.meta.__index = Conf_Group.meta;

function Conf_Group:Create(name, icon)
    if !name then
        MsgErr("[Conf_Group.Create] -> Tried creating a config group with no name!");
        return;
    end
    if icon and !ICONS[icon] then
        MsgErr("[Conf_Group.Create] -> Tried creating a group '%s' with a non-existant icon '%s'! Setting to cog icon default.", name, icon);
        icon = "cog-alt";
    end

    local tab = {};
    tab.Name = name;
    tab.Icon = ICONS[icon or "cog-alt"];
    tab.Entries = {};
    tab.FileName = string.lower(BASH:GetSafeFilename(name));
    setmetatable(tab, self.meta);

    return tab;
end

function Conf_Group.meta:AddEntry(confTab)
    if !confTab then return end;
    if !confTab.ID then
        MsgErr("[Conf_Group.AddEntry] -> Tried adding a config entry with no ID into group '%s'!", self.Name);
        return false;
    end
    if BASH.Config.IDRef[confTab.ID] then
        local exists = self.IDRef[confTab.ID];
        MsgErr("[Conf_Group.AddEntry] -> A config entry with the ID '%s' already exists in group '%s'!", confTab.ID, exists.Group);
        return false;
    end

    confTab.Group =         self.Name
    confTab.Name =          confTab.Name or "Unknown Entry";
    confTab.Desc =          confTab.Desc or "";
    confTab.Type =          confTab.Type or "Number";
    confTab.MenuElement =   confTab.MenuElement or "DNumberWang";
    confTab.Default =       confTab.Default or 0;
    confTab.AccessLevel =   confTab.AccessLevel or 100;
    if confTab.MenuElement == "DNumberWang" then
        confTab.Min = confTab.Min or 0;
        confTab.Max = confTab.Max or 1;
    end
    if confTab.MenuElement == "DComboBox" then
        confTab.Options = confTab.Options or {"Option 1", "Option 2"};
    end

    self.Entries[#self.Entries + 1] = confTab;
    return true;
end

function Conf_Group.meta:SetIcon(icon)
    if icon and !ICONS[icon] then
        MsgErr("[Conf_Group.SetIcon] -> Tried setting the icon for '%s' to a non-existant icon '%s'!", self.Name, icon);
        return;
    end

    self.Icon = ICONS[icon];
end
