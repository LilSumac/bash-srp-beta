local BASH = BASH;
BASH.Cookies = {};
BASH.Cookies.Name = "Cookies";
BASH.Cookies.Entries = BASH.Cookies.Entries or {};
cookie.GetBoolean = cookie.GetBoolean or cookie.GetNumber;

function BASH.Cookies:Init()
    /*
    **  Create Default Cookies
    */

    local cook = {
        ID = "text_size",
        Name = "Text Size",
        Type = "String",
        Desc = "The size of the GUI text.",
        Default = "Standard",
        MenuElement = "DComboBox",
        Options = {"Tiny", "Standard", "Large"}
    };
    self:AddCookie(cook);

    cook = {
        ID = "gui_theme",
        Name = "GUI Theme",
        Type = "String",
        Desc = "The theme of the GUI features.",
        Default = "",
        MenuElement = "DComboBox",
        Options = {}
    };
    //  The defaults and options for themes are handled in the theme library.
    self:AddCookie(cook);

    cook = {
        ID = "logging_enabled",
        Name = "Logging Enabled",
        Type = "Boolean",
        Desc = "Whether or not chat logging is enabled.",
        Default = 1,
        MenuElement = "DCheckBox"
    };
    self:AddCookie(cook);

    cook = {
        ID = "filter_steamjet",
        Name = "Filter \'steamjet\'",
        Type = "Boolean",
        Desc = "Whether or not any \'steam_\' particle errors are automatically filtered out in console.",
        Default = 0,
        MenuElement = "DCheckBox"
    };
    self:AddCookie(cook);

    cook = {
        ID = "debug_enabled",
        Name = "Enable Debug",
        Type = "Boolean",
        Desc = "Whether or not debug messages will be printed to console. (Admin Only)",
        Default = 0,
        AccessLevel = 80,
        MenuElement = "DCheckBox"
    };
    self:AddCookie(cook);

    cook = {
        ID = "smooth_dragging",
        Name = "Smooth Dragging",
        Type = "Boolean",
        Desc = "Whether or not GUI elements drag smoothly. Disabling this will increase performance.",
        Default = 1,
        MenuElement = "DCheckBox"
    };
    self:AddCookie(cook);

    hook.Call("LoadCookies", BASH);
end

/*
**  BASH.Cookies.AddCookie
**  Args: {Cookie Structure Table}
**
**  Note: Cookies are like registry variables, only they are
**  exclusively stored client-side. They persist the same way
**  and are much less of an expense, due to the fact that they
**  are stored and changed only on the client. Try using
**  cookies for client settings that don't need to be known by
**  the server, such as GUI themes, logging preferences, or
**  other miscellaneous settings.
**
**  Note: The 'Type' table key must either be "String",
**  "Number", or "Boolean". "Boolean"-type cookies will be
**  stored as a number in the cl.db file, but will be de-typed
**  when retrieved or stored.
*/
function BASH.Cookies:AddCookie(cook)
    if !cook.ID or !cook.Type then return end;

    if self.Entries[cook.ID] then
        MsgErr("[BASH.Cookies:NewCookie(%s)]: A cookie with that ID already exists!", detype(cook, "string"));
        return;
    end

    cook.Name =         cook.Name or "Unknown Cookie";
    cook.Desc =         cook.Desc or "";
    cook.Default =      cook.Default or 0;
    cook.Hidden =       cook.Hidden or false;
    cook.AccessLevel =  cook.AccessLevel or 0;
    cook.MenuElement =  cook.MenuElement or (cook.Type == "Number" and "DNumberWang") or (cook.Type == "String" and "BTextEntry") or "DCheckBox";
    if cook.Type != "Boolean" then
        cook.Min = cook.Min or 0;
        cook.Max = cook.Max or 1;
    end
    if cook.MenuElement == "DComboBox" then
        cook.Options = cook.Options or {"Option 1", "Option 2"};
    end
    self.Entries[cook.ID] =  cook;

    if self:Get(cook.ID) == nil then
        self:Set(cook.ID, cook.Default);
    end

    MsgDebug(color_cookie, false, "Cookie '%s' created with value '%s'!", cook.ID, detype(self:Get(cook.ID), "string"));
end

function BASH.Cookies:Get(id)
    if !self.Entries[id] then return nil end;
    local _cookie = BASH.Cookies.Entries[id];
    return detype(cookie["Get" .. _cookie.Type](id), string.lower(_cookie.Type));
end

function BASH.Cookies:Set(id, value)
    if !self.Entries[id] then
        local args = concatArgs(id, value);
        MsgErr("[BASH:SetCookie(%s)]: Cookie '%s' does not exist!", args, id);
        return nil;
    end

    cookie.Set(id, detype(value, "string"));
    MsgDebug(color_cookie, true, "Cookie '%s' set to '%s'.", id, detype(value, "string"));
end

BASH:RegisterLib(BASH.Cookies);
