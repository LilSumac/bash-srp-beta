local BASH = BASH;
BASH.Config = BASH.Config or {};
BASH.Config.Name = "Config";
BASH.Config.IDRef = BASH.Config.IDRef or {};
BASH.Config.Entries = BASH.Config.Entries or {};
BASH.Config.InitialSet = BASH.Config.InitialSet or false;
BASH.Config.Dependencies = {["GUI"] = CLIENT};

function BASH.Config:Init()
    /*
    **  Create Default Config Entries
    */

    /*
    **  General Settings
    */
    local conf = {
        ID = "community_name",
        Group = "Base Config",
        Name = "Community Name",
        Desc = "The name of the community you wish to advertise on this server.",
        Type = "String",
        MenuElement = "DTextEntry",
        Default = "",
        AccessLevel = 100
    };
    self:AddEntry(conf);

    /*
    **  SQL Settings
    */
    conf = {
        ID = "sql_host",
        Group = "Base Config",
        Name = "SQL Host Address",
        Desc = "The address of your SQL database.",
        Type = "String",
        MenuElement = "DTextEntry",
        Default = "",
        AccessLevel = 100
    };
    self:AddEntry(conf);

    conf = {
        ID = "sql_user",
        Group = "Base Config",
        Name = "SQL Username",
        Desc = "The username to log into your SQL database.",
        Type = "String",
        MenuElement = "DTextEntry",
        Default = "",
        AccessLevel = 100
    };
    self:AddEntry(conf);

    conf = {
        ID = "sql_pass",
        Group = "Base Config",
        Name = "SQL Password",
        Desc = "The password to log into your SQL database.",
        Type = "String",
        MenuElement = "DTextEntry",
        Default = "",
        AccessLevel = 100
    };
    self:AddEntry(conf);

    conf = {
        ID = "sql_name",
        Group = "Base Config",
        Name = "SQL Database Name",
        Desc = "The name of your SQL database.",
        Type = "String",
        MenuElement = "DTextEntry",
        Default = "",
        AccessLevel = 100
    };
    self:AddEntry(conf);

    conf = {
        ID = "sql_port",
        Group = "Base Config",
        Name = "SQL Port",
        Desc = "The port needed to connect to your SQL database. Use 3306 if you're unsure.",
        Type = "Number",
        MenuElement = "DNumberWang",
        Default = 3306,
        Min = 0,
        Max = 9999
    };
    self:AddEntry(conf);

    /*
    **  Developer Settings
    */
    conf = {
        ID = "debug_enabled",
        Group = "Developer",
        Name = "Debug Enabled",
        Desc = "Whether or not debug messages will print to the server console. WARNING: This will result in HUGE logs. Only enable if necessary, and disable once you're done.",
        Type = "Boolean",
        MenuElement = "DCheckBox",
        Default = false,
        AccessLevel = 100
    };
    self:AddEntry(conf);

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
    local len = #self.Entries[confTab.Group];
    self.Entries[confTab.Group][len + 1] = confTab;
    self.IDRef[confTab.ID] = self.Entries[confTab.Group][len + 1];
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
        snow.Send(ply, "BASH_CONFIG_SET", BASH.Config.InitialSet);
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

    net.Receive("BASH_CONFIG_SET_ENTRY", function(len, ply)
        // Read entry data.
        local entry = net.ReadTable();

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
