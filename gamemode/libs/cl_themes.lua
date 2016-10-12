local BASH = BASH;
BASH.Themes = {};
BASH.Themes.Name = "Themes";
BASH.Themes.Entries = {};
BASH.Themes.PushOnInit = BASH.Themes.PushOnInit or false;
BASH.Themes.Dependencies = {["Cookies"] = CLIENT};

function BASH.Themes:Init()
    local theme = {
        ID = "bash_dusk",
        Name = "BASH Dusk Theme",
        Colors = {
            Primary = {
                Light = Color(44, 80, 115),
                Medium = Color(8, 52, 94),
                Dark = Color(0, 37, 73),
                Highlight = Color(94, 115, 136)
            },
            Secondary = {
                Light = Color(40, 119, 91),
                Medium = Color(1, 98, 64),
                Dark = Color(0, 75, 49),
                Highlight = Color(94, 140, 124)
            },
            Tertiary = {
                Light = Color(57, 53, 123),
                Medium = Color(20, 15, 101),
                Dark = Color(4, 0, 78),
                Highlight = Color(107, 104, 146)
            },
            Neutral = Color(160, 160, 160)
        },
        Default = true
    };
    self:AddEntry(theme);

    hook.Call("LoadThemes", BASH);
end

function BASH.Themes:AddEntry(theme)
    if !theme then return end;
    if !theme.ID then
        MsgErr("[BASH.Themes:AddEntry(%s)]: Tried adding a theme with no ID!", concatArgs(theme));
        return;
    end
    if self.Entries[theme.ID] then
        MsgErr("[BASH.Themes:AddEntry(%s)]: A theme with the ID '%s' already exists!", concatArgs(theme), theme.ID);
        return;
    end

    theme.Name = theme.Name or "Unknown Theme";
    theme.Colors = theme.Colors or {};
    theme.Disabled = theme.Disabled or false;
    theme.Default = theme.Default or false;

    if !BASH.Cookies then
        self.PushOnInit = true;
    else
        local defaultTheme = BASH.Cookies.Entries["gui_theme"];
        if !defaultTheme then
            self.PushOnInit = true;
        else
            if !theme.Disabled then
                table.insert(defaultTheme.Options, theme.ID);
                if theme.Default then
                    defaultTheme.Default = theme.ID;
                end
            end
        end
    end

    self.Entries[theme.ID] = theme;
end

function BASH.Themes:Get(id, attribute)
    local theme = self.Entries[id];
    if !theme then
        MsgErr("[BASH.Themes:Get(%s)]: There is no theme with that ID!", id);
        return;
    end

    if attribute then
        return theme.Colors[attribute] or {};
    else
        return theme.Colors or {};
    end
end

hook.Add("OnInit", "PushThemesOnInit", function()
    if !BASH.Themes.PushOnInit then return end;
    if !BASH.Cookies then
        MsgErr("[BASH.Themes -> PushThemesOnInit]: Cookie library not found!");
        return;
    end

    local defaultTheme = BASH.Cookies.Entries["gui_theme"];
    if !defaultTheme then
        MsgErr("[BASH.Themes -> PushThemesOnInit]: No cookie entry found for default theme!");
        return;
    else
        for id, theme in pairs(BASH.Themes.Entries) do
            if !theme.Disabled then
                table.insert(defaultTheme.Options, theme.ID);
                if theme.Default then
                    defaultTheme.Default = theme.ID;
                end
            end
        end
    end

    BASH.Themes.PushOnInit = false;
end);

BASH:RegisterLib(BASH.Themes);
