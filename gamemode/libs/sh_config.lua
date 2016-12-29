local BASH = BASH;
BASH.Config = BASH.Config or {};
BASH.Config.Name = "Config";
BASH.Config.IDRef = BASH.Config.IDRef or {};
BASH.Config.Entries = BASH.Config.Entries or {};
BASH.Config.InitialSet = BASH.Config.InitialSet or false;
BASH.Config.Dependencies = {["GUI"] = CLIENT};

local randumbNames = {
    "Big Gay Retards",
    "xxX_H4CK3RZ_AN0NYM0U5_Xxx",
    "I'M A FUCKING IDIOT",
    "The Best Server Ever",
    "Big Dicks, No Chicks"
};
function BASH.Config:Init()
    /*
    **  Create Default Config Entries
    */

    /*
    **  General Settings
    */
    self:AddEntry{
        ID = "community_name",
        Group = "Base Config",
        SubGroup = "Information",
        Name = "Community Name",
        Desc = "The name of the community you wish to advertise on this server.",
        Type = "String",
        MenuElement = "BTextEntry",
        Default = table.Random(randumbNames),
        AccessLevel = 100
    };

    self:AddEntry{
        ID = "community_name",
        Group = "Base Config",
        SubGroup = "Information",
        Name = "Community Name",
        Desc = "The name of the community you wish to advertise on this server.",
        Type = "String",
        MenuElement = "BTextEntry",
        Default = table.Random(randumbNames),
        AccessLevel = 100
    };

    /*
    **  SQL Settings
    */
    self:AddEntry{
        ID = "sql_host",
        Group = "Base Config",
        SubGroup = "SQL",
        Name = "SQL Host Address",
        Desc = "The address of your SQL database.",
        Type = "String",
        MenuElement = "BTextEntry",
        Default = "",
        AccessLevel = 100
    };

    self:AddEntry{
        ID = "sql_user",
        Group = "Base Config",
        SubGroup = "SQL",
        Name = "SQL Username",
        Desc = "The username to log into your SQL database.",
        Type = "String",
        MenuElement = "BTextEntry",
        Default = "",
        AccessLevel = 100
    };

    self:AddEntry{
        ID = "sql_pass",
        Group = "Base Config",
        SubGroup = "SQL",
        Name = "SQL Password",
        Desc = "The password to log into your SQL database.",
        Type = "String",
        MenuElement = "BTextEntry",
        Default = "",
        AccessLevel = 100
    };

    self:AddEntry{
        ID = "sql_name",
        Group = "Base Config",
        SubGroup = "SQL",
        Name = "SQL Database Name",
        Desc = "The name of your SQL database.",
        Type = "String",
        MenuElement = "BTextEntry",
        Default = "",
        AccessLevel = 100
    };

    self:AddEntry{
        ID = "sql_port",
        Group = "Base Config",
        SubGroup = "SQL",
        Name = "SQL Port",
        Desc = "The port needed to connect to your SQL database. Use 3306 if you're unsure.",
        Type = "Number",
        MenuElement = "DNumberWang",
        Default = 3306,
        Min = 0,
        Max = 9999,
        AccessLevel = 100
    };

    /*
    **  Developer Settings
    */
    self:AddEntry{
        ID = "debug_enabled",
        Group = "Base Config",
        SubGroup = "Developer",
        Name = "Debug Enabled",
        Desc = "Whether or not debug messages will print to the server console. WARNING: This will result in HUGE logs. Only enable if necessary, and disable once you're done.",
        Type = "Boolean",
        MenuElement = "DCheckBox",
        Default = false,
        AccessLevel = 100
    };

    self:SetGroupIcon("Base Config", "cog-alt");
    self:SetSubGroupIcon("Base Config", "Information", "info");
    self:SetSubGroupIcon("Base Config", "SQL", "database");
    self:SetSubGroupIcon("Base Config", "Developer", "code");

    hook.Call("LoadConfig", BASH);
    if SERVER then self:Load() end;
end

/*
**  BASH.Config.AddEntry
**  Args: {Config Structure Table}
**
**  Note: Config is used for storing settings used exclusively
**  by the server that can be changed by authorized players.
**  They are saved in a text file on the server in a JSON
**  format for ease of use/saving.
*/
function BASH.Config:AddEntry(confTab)
    if !confTab then return end;
    if !confTab.ID then
        MsgErr("[BASH.Config:AddEntry(%s)]: Tried adding a config entry with no ID into group '%s'!", concatArgs(confTab), confTab.Group or "Unsorted");
        return;
    end
    if self.IDRef[confTab.ID] then
        local exists = self.IDRef[confTab.ID];
        MsgErr(color_red, "A config entry with the ID '%s' already exists in group '%s'!", confTab.ID, exists.Group);
        return;
    end

    confTab.Group =         confTab.Group or "Unsorted";
    confTab.SubGroup =      confTab.SubGroup;
    confTab.Name =          confTab.Name or "Unknown Entry";
    confTab.Desc =          confTab.Desc or "";
    confTab.Type =          confTab.Type or "Number";
    confTab.MenuElement =   confTab.MenuElement or "DNumberWang";
    confTab.Default =       confTab.Default or 0;
    confTab.AccessLevel =   confTab.AccessLevel or 100;
    if confTab.Type == "Number" then
        confTab.Min = confTab.Min or 0;
        confTab.Max = confTab.Max or 1;
    end
    if confTab.MenuElement == "DComboBox" then
        confTab.Options = confTab.Options or {"Option 1", "Option 2"};
    end

    self.Entries[confTab.Group] = self.Entries[confTab.Group] or {};
    if confTab.SubGroup then
        self.Entries[confTab.Group][confTab.SubGroup] = self.Entries[confTab.Group][confTab.SubGroup] or {};
        local len = #self.Entries[confTab.Group][confTab.SubGroup];
        self.Entries[confTab.Group][confTab.SubGroup][len + 1] = confTab;
        self.IDRef[confTab.ID] = self.Entries[confTab.Group][confTab.SubGroup][len + 1];
    else
        local len = #self.Entries[confTab.Group];
        self.Entries[confTab.Group][len + 1] = confTab;
        self.IDRef[confTab.ID] = self.Entries[confTab.Group][len + 1];
    end
end

function BASH.Config:SetGroupIcon(group, icon)
    if !self.Entries[group] then
        MsgErr("[BASH.Config:SetGroupIcon(%s, %s)]: Tried setting an icon for a non-existant group '%s'!", group, icon, group);
        return;
    end
    if !ICONS[icon] then
        MsgErr("[BASH.Config:SetGroupIcon(%s, %s)]: Tried setting a non-existant icon '%s' for group '%s'!", group, icon, icon, group);
        return;
    end

    self.Entries[group].Icon = icon;
end

function BASH.Config:SetSubGroupIcon(group, sub, icon)
    if !self.Entries[group] then
        MsgErr("[BASH.Config:SetSubGroupIcon(%s, %s, %s)]: Tried setting an icon for a non-existant group '%s'!", group, sub, icon, group);
        return;
    end
    if !self.Entries[group][sub] then
        MsgErr("[BASH.Config:SetSubGroupIcon(%s, %s, %s)]: Tried adding an icon for a non-existant subgroup '%s'!", group, sub, icon, sub);
        return;
    end
    if !ICONS[icon] then
        MsgErr("[BASH.Config:SetSubGroupIcon(%s, %s, %s)]: Tried setting a non-existant icon '%s' for subgroup '%s->%s'!", group, sub, icon, icon, group, sub);
        return;
    end

    self.Entries[group][sub].Icon = icon;
end

function BASH.Config:Load()
    BASH:CreateDirectory("bash/config");

    local fileName, fileCont;
    for group, groupTab in pairs(self.Entries) do
        fileName = string.lower(BASH:GetSafeFilename(group));
        if !file.Exists("bash/config/" .. fileName, "DATA") then
            BASH:CreateFile("bash/config/" .. fileName);
            fileCont = nil;
            if group == "Base Config" then
                self.InitialSet = false;
            end

            // Fill the empty file for next server load.
            local fillFile = {};
            for index, confEntry in pairs(groupTab) do
                fillFile[confEntry.ID] = detype(confEntry.Default, string.lower(confEntry.Type));
            end
            fillFile.HasBeenSet = false;
            fillFile = detype(fillFile, "string", true);
            BASH:WriteToFile("bash/config/" .. fileName, fillFile, true);
        else
            fileCont = file.Read("bash/config/" .. fileName, "DATA");
            fileCont = detype(fileCont, "table");
            if group == "Base Config" then
                self.InitialSet = fileCont.HasBeenSet;
            end
        end

        if group == "Base Config" and !self.InitialSet then continue end;
        for index, confEntry in pairs(groupTab) do
            confEntry.Value = (fileCont[confEntry.ID] != nil and detype(fileCont[confEntry.ID], string.lower(confEntry.Type))) or confEntry.Default;
        end
    end
end

function BASH.Config:Send(recipients)

end

function BASH.Config:Get(id)
    if !self.IDRef[id] then
        MsgErr("[BASH.Config:Get(%s)]: Tried to fetch a non-existant config entry!", id);
        return nil;
    end
    return self.IDRef[id].Value;
end

function BASH.Config:Set(id, value)
    if CLIENT then return end;
    if !self.IDRef[id] then
        local args = concatArgs(id, value);
        MsgErr("[BASH.Config:Set(%s)]: Tried to set a non-existant config entry!", args);
        return nil;
    end
    self.IDRef[id].Value = value;
end

function BASH.Config:Exit()
    MsgCon(color_green, true, "Saving config...");
end

if CLIENT then
    /*
    **  Networking
    */
    net.Receive("BASH_CONFIG_INIT", function(len)
        BASH.GUI:Open("menu_config");
        BASH.IntroStage = 2;
    end);

    net.Receive("BASH_CONFIG_SET", function(len)
        BASH.ConfigSet = net.ReadBool();
    end);
elseif SERVER then
    /*
    **  Misc. Hooks
    */
    hook.Add("PostEntInitialize", "BASH_SetInitialConfig", function(ply)
        net.Start("BASH_CONFIG_SET");
            net.WriteBool(BASH.Config.InitialSet);
        net.Send(ply);

    	if BASH.Config.InitialSet then
    		BASH.Config:Send(ply);
    	end
    end);

    /*
    **  Networking
    */
    util.AddNetworkString("BASH_CONFIG_INIT");
    util.AddNetworkString("BASH_CONFIG_INIT_CANCEL");
    util.AddNetworkString("BASH_CONFIG_SET");
    util.AddNetworkString("BASH_CONFIG_SET_ENTRY");

    vnet.Watch("BASH_CONFIG_SET_ENTRY", function(data)
        local ply = data.Source;
        local entry = data:Table();

        if !ply.SettingConfig and (ply:GetAccessLevel() < entry.AccessLevel) then
            // Log attempted entry change.
            return;
        end

        if !BASH.Config.InitialSet then
            MsgCon(color_green, true, "Getting initial config from %s...", ply:Name());
        end
        for id, value in pairs(entry) do
            BASH.Config:Set(id, value);
        end
    end);

    net.Receive("BASH_CONFIG_INIT_CANCEL", function(len, ply)
        MsgCon(color_red, true, "%s has stopped the inital config process early!", ply:Name());
        ply.SettingConfig = false;
        BASH.Config.SettingUp = false;
    end);
end

BASH:RegisterLib(BASH.Config);
