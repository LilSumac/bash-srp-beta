local BASH = BASH;
BASH.Config = BASH.Config or {};
BASH.Config.Name = "Config";
BASH.Config.IDRef = BASH.Config.IDRef or {};
BASH.Config.Groups = BASH.Config.Groups or {};
BASH.Config.InitialSet = BASH.Config.InitialSet or false;
BASH.Config.SettingUp = BASH.Config.SettingUp or false;
BASH.Config.Dependencies = {["GUI"] = CLIENT};
local color_config = Color(151, 151, 0, 255);

local randumbNames = {
    "Baco 'n Tanana",
    "The Lizard Pee",
    "xxx_ELITE_HACKERS_ANONYMOUS_xxx",
    "Big Gay Retards"
};
function BASH.Config:Init()
    self:AddGroup("Base Config", "cog-alt");
    self:AddGroup("Unsorted", "ellipsis");

    /*
    **  Create Default Config Entries
    **  General Settings
    */
    self:AddEntry{
        ID = "community_name",
        Name = "Community Name",
        Desc = "The name of the community you wish to advertise on this server.",
        Type = "String",
        MenuElement = "BTextEntry",
        Default = table.Random(randumbNames),
        AccessLevel = 100
    };

    self:AddEntry{
        ID = "community_website",
        Name = "Community Website",
        Desc = "The website that your community is hosted on. (Optional)",
        Type = "String",
        MenuElement = "BTextEntry",
        Default = "",
        AccessLevel = 100
    };

    /*
    **  Developer Settings
    */
    self:AddEntry{
        ID = "debug_enabled",
        Name = "Debug Enabled",
        Desc = "Whether or not debug messages will print to the server console. WARNING: This will result in HUGE logs. Only enable if necessary, and disable once you're done.",
        Type = "Boolean",
        MenuElement = "DCheckBox",
        Default = false,
        AccessLevel = 100
    };

    hook.Call("LoadConfig", BASH);
    if CLIENT then return end;
    self:Load();
end

function BASH.Config:AddGroup(name, icon)
	if !name then return end;
	if icon and !ICONS[icon] then
		MsgErr("[BASH.Config.AddGroup] -> Tried creating a group '%s' with a non-existant icon '%s'! Reverting to default cog.", name, icon);
		icon = "cog-alt";
	end

	local tab = {};
	tab.Name = name;
	tab.Icon = ICONS[icon or "cog-alt"];
	tab.Entries = {};
	tab.FileName = string.lower(BASH:GetSafeFilename(name));

    MsgCon(color_config, false, "Creating config group '%s'!", name);
    table.insert(self.Groups, (name != "Unsorted" and #self.Groups > 0 and #self.Groups) or (#self.Groups + 1), tab);
end

function BASH.Config:GetGroup(name)
    for index, groupTab in pairs(self.Groups) do
        if groupTab.Name == name then return groupTab end;
    end
end

function BASH.Config:SetGroupIcon(name, icon)
	if !name then return end;
	local group = self:GetGroup(name);
	if !group then
		MsgErr("[BASH.Config.SetGroupIcon] -> No such group '%s' exists!", name);
		return;
	end
	if icon and !ICONS[icon] then
		MsgErr("[BASH.Config.SetGroupIcon] -> Tried setting the icon of group '%s' to a non-existant icon '%s'! Reverting to default cog.", name, icon);
		icon = "cog-alt";
	end

	MsgCon(color_config, false, "Setting icon of group '%s' to '%s'.", name, icon);
	group.Icon = ICONS[icon or "cog-alt"];
end

function BASH.Config:AddEntry(confTab)
	if !confTab then return end;
	if !confTab.ID then
		MsgErr("[BASH.Config.AddEntry] -> Tried adding a config entry with no ID!");
		return;
	end
	if self.IDRef[confTab.ID] then
		local exists = self.IDRef[confTab.ID];
		MsgErr("[BASH.Config.AddEntry] -> A config entry with the ID '%s' already exists in group '%s'!", confTab.ID, exists.Group);
		return;
	end

    confTab.Name =          confTab.Name or "Unknown Entry";
    confTab.Desc =          confTab.Desc or "";
	confTab.Group =			confTab.Group or "Unsorted";
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

	local group = self:GetGroup(confTab.Group);
	group.Entries[#group.Entries + 1] = confTab;
end

function BASH.Config:GetEntry(id)
	if !id then return end;
    return self.IDRef[id];
end

function BASH.Config:Load()
    BASH:CreateDirectory("bash/config");

    if !file.Exists("bash/config/setup.txt", "DATA") then
        self.InitialSet = false;
        BASH:CreateFile("bash/config/setup.txt");
        BASH:WriteToFile("bash/config/setup.txt", "false", true);
        MsgCon(color_darkred, false, "No config has been set yet. Be sure to do so before continuing server use.");
        return;
    else
        self.InitialSet = tobool(file.Read("bash/config/setup.txt", "DATA"));
        if !self.InitialSet then
            MsgCon(color_darkred, false, "No config has been set yet. Be sure to do so before continuing server use.");
            return;
        end
    end

    local fileName, fileCont;
    for _, groupTab in pairs(self.Groups) do
        fileName = "bash/config/" .. groupTab.FileName;
        if !file.Exists(fileName, "DATA") then
            BASH:CreateFile(fileName);

            fileCont = {};
            for __, confTab in pairs(groupTab.Entries) do
                fileCont[confTab.ID] = confTab.Default;
            end
            BASH:WriteToFile(fileName, pon.encode(fileCont), true);
        else
            fileCont = file.Read(fileName, "DATA");
			fileCont = pon.decode(fileCont);
        end

        MsgCon(color_config, true, "Loaded %n config entries from '%s'.", table.Count(fileCont), groupTab.Name);

        for __, confTab in pairs(groupTab.Entries) do
            confTab.Value = (fileCont[confTab.ID] != nil and detype(fileCont[confTab.ID], string.lower(confTab.Type))) or confTab.Default;
        end
    end
end

function BASH.Config:Get(id)
    if !self.IDRef[id] then
        MsgErr("[BASH.Config:Get(%s)]: Tried to fetch a non-existant config entry!", id);
        return nil;
    end
    return self.IDRef[id].Value;
end

if SERVER then

    function BASH.Config:Save()
        BASH:CreateDirectory("bash/config");
        if !self.InitialSet then return end;

        local fileName, groupCont;
        for _, groupTab in pairs(self.Groups) do
            fileName = "bash/config/" .. groupTab.FileName;

            groupCont = {};
            for __, confTab in pairs(groupTab.Entries) do
                if confTab.Value != nil then
                    groupCont[confTab.ID] = confTab.Value;
                else
					groupCont[confTab.ID] = confTab.Default;
				end
            end

			groupCont = pon.encode(groupCont);
            if !file.Exists(fileName, "DATA") then
                BASH:CreateFile(fileName);
            end
            if BASH:WriteToFile(fileName, groupCont, true) then
                MsgCon(color_config, true, "Saved %n config entries from '%s'.", table.Count(groupCont), groupTab.Name);
            end
        end
    end

    function BASH.Config:Send(recipients)
        if !self.InitialSet then return end;

        local idCont = {};
        for id, confTab in pairs(self.IDRef) do
            idCont[id] = confTab.Value;
        end

        local packet = vnet.CreatePacket("BASH_CONFIG_GET");
        packet:Table(idCont);
        packet:AddTargets(recipients);
        packet:Send();
    end

    function BASH.Config:Set(id, value)
        if !self.IDRef[id] then
            local args = concatArgs(id, value);
            MsgErr("[BASH.Config.Set] -> Tried to set a non-existant config entry!", args);
            return nil;
        end
        self.IDRef[id].Value = value;
    end

    function BASH.Config:Exit()
        MsgCon(color_darkgreen, true, "Saving config...");
        self:Save();
    end

end

if CLIENT then
    /*
    **  Networking
    */
    net.Receive("BASH_CONFIG_INIT", function(len)
        BASH.Config.SettingUp = true;
    end);

    net.Receive("BASH_CONFIG_ISSET", function(len)
        BASH.Config.InitialSet = net.ReadBool();
    end);

    vnet.Watch("BASH_CONFIG_GET", function(data)
        local entries = data:Table();
        for id, confTab in pairs(BASH.Config.IDRef) do
            if entries[id] != nil then
                confTab.Value = entries[id];
            end
        end
    end);

elseif SERVER then
    /*
    **  Misc. Hooks
    */
    hook.Add("PostEntInitialize", "BASH_SetInitialConfig", function(ply)
        net.Start("BASH_CONFIG_ISSET");
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
    util.AddNetworkString("BASH_CONFIG_ISSET");
    util.AddNetworkString("BASH_CONFIG_GET");
    util.AddNetworkString("BASH_CONFIG_SET");

    vnet.Watch("BASH_CONFIG_SET", function(data)
        local ply = data.Source;
        local entry = data:Table();

        if !ply.SettingConfig and (ply:GetAccessLevel() < entry.AccessLevel) then
            // Log attempted entry change.
            return;
        end

        if !BASH.Config.InitialSet then
            MsgCon(color_darkgreen, true, "Getting initial config from %s...", ply:Name());
        end
        for id, value in pairs(entry) do
            BASH.Config:Set(id, value);
        end
    end);

    net.Receive("BASH_CONFIG_INIT_CANCEL", function(len, ply)
        MsgCon(color_darkred, true, "%s has stopped the inital config process early!", ply:Name());
        ply.SettingConfig = false;
        BASH.Config.SettingUp = false;
    end);

end

BASH:RegisterLib(BASH.Config);
