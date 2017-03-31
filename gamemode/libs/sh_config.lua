local BASH = BASH;
BASH.Config = BASH.Config or {};
BASH.Config.Name = "Config";
BASH.Config.IDRef = BASH.Config.IDRef or {};
BASH.Config.Groups = BASH.Config.Groups or {};
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
    self:AddGroup("Base Config", "cog-alt");
    self:AddGroup("Unsorted", "ellipsis");

    /*
    **  Create Default Config Entries
    **  General Settings
    */
    self:AddEntry({
        ID = "community_name",
        Name = "Community Name",
        Desc = "The name of the community you wish to advertise on this server.",
        Type = "String",
        MenuElement = "BTextEntry",
        Default = table.Random(randumbNames),
        AccessLevel = 100
    }, "Base Config");

    self:AddEntry({
        ID = "community_website",
        Name = "Community Website",
        Desc = "The website that your community is hosted on. (Optional)",
        Type = "String",
        MenuElement = "BTextEntry",
        Default = "",
        AccessLevel = 100
    }, "Base Config");

    /*
    **  SQL Settings
    */
    self:AddEntry({
        ID = "sql_host",
        Name = "SQL Host Address",
        Desc = "The address of your SQL database.",
        Type = "String",
        MenuElement = "BTextEntry",
        Default = "",
        AccessLevel = 100
    }, "Base Config");

    self:AddEntry({
        ID = "sql_user",
        Name = "SQL Username",
        Desc = "The username to log into your SQL database.",
        Type = "String",
        MenuElement = "BTextEntry",
        Default = "",
        AccessLevel = 100
    }, "Base Config");

    self:AddEntry({
        ID = "sql_pass",
        Name = "SQL Password",
        Desc = "The password to log into your SQL database.",
        Type = "String",
        MenuElement = "BTextEntry",
        Default = "",
        AccessLevel = 100
    }, "Base Config");

    self:AddEntry({
        ID = "sql_name",
        Name = "SQL Database Name",
        Desc = "The name of your SQL database.",
        Type = "String",
        MenuElement = "BTextEntry",
        Default = "",
        AccessLevel = 100
    }, "Base Config");

    self:AddEntry({
        ID = "sql_port",
        Name = "SQL Port",
        Desc = "The port needed to connect to your SQL database. Use 3306 if you're unsure.",
        Type = "Number",
        MenuElement = "DNumberWang",
        Default = 3306,
        Min = 0,
        Max = 9999,
        AccessLevel = 100
    }, "Base Config");

    /*
    **  Developer Settings
    */
    self:AddEntry({
        ID = "debug_enabled",
        Name = "Debug Enabled",
        Desc = "Whether or not debug messages will print to the server console. WARNING: This will result in HUGE logs. Only enable if necessary, and disable once you're done.",
        Type = "Boolean",
        MenuElement = "DCheckBox",
        Default = false,
        AccessLevel = 100
    }, "Base Config");

    hook.Call("LoadConfig", BASH);
    if CLIENT then return end;
    self:Load();
end

function BASH.Config:AddGroup(name, icon)
    local tab = Conf_Group:Create(name, icon);
    if !tab then return end;
    MsgCon(color_green, false, "Creating config group '%s'!", name);
    table.insert(self.Groups, (name != "Unsorted" and #self.Groups > 0 and #self.Groups) or (#self.Groups + 1), tab);
end

function BASH.Config:GetGroup(name)
    for index, groupTab in pairs(self.Groups) do
        if groupTab.Name == name then return groupTab end;
    end
end

/*
**  BASH.Config.AddEntry
**  Args: {Config Structure Table}, "Group Name"
**
**  Note: Config is used for storing settings used exclusively
**  by the server that can be changed by authorized players.
**  They are saved in a text file on the server in a JSON
**  format for ease of use/saving.
*/
function BASH.Config:AddEntry(confTab, group)
    if !confTab then return end;
    if !group then group = "Unsorted" end;
    local groupTab = self:GetGroup(group);
    if !groupTab then
        MsgErr("[BASH.Config.AddEntry] -> Tried adding a config entry to a non-existant group '%s'!", group);
        return;
    end

    if groupTab:AddEntry(confTab) then
        self.IDRef[confTab.ID] = confTab;
    end
end

function BASH.Config:GetEntry(id)
    return self.IDRef[id or ""];
end

function BASH.Config:Load()
    BASH:CreateDirectory("bash/config");

    if !file.Exists("bash/config/setup.txt", "DATA") then
        self.InitialSet = false;
        BASH:CreateFile("bash/config/setup.txt");
        BASH:WriteToFile("bash/config/setup.txt", "false", true);
        MsgCon(color_red, false, "No config has been set yet. Be sure to do so before continuing server use.");
        return;
    else
        self.InitialSet = tobool(file.Read("bash/config/setup.txt", "DATA"));
        if !self.InitialSet then
            MsgCon(color_red, false, "No config has been set yet. Be sure to do so before continuing server use.");
            return;
        end
    end

    local fileName, fileCont;
    for _, groupTab in pairs(self.Groups) do
        fileName = "bash/config/" .. string.lower(BASH:GetSafeFilename(groupTab.Name));
        if !file.Exists(fileName, "DATA") then
            BASH:CreateFile(fileName);

            fileCont = {};
            for __, confTab in pairs(groupTab.Entries) do
                fileCont[confTab.ID] = confTab.Default;
            end
            fileCont = detype(fileCont, "string");
            BASH:WriteToFile(fileName, fileCont, true);
        else
            fileCont = file.Read(fileName, "DATA");
            fileCont = detype(fileCont, "table");
        end

        for __, confTab in pairs(groupTab.Entries) do
            confTab.Value = (fileCont[confTab.ID] != nil and detype(fileCont[confTab.ID], string.lower(confTab.Type))) or confTab.Default;
        end
    end
end

function BASH.Config:Save()

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
    self:Save();
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
