local BASH = BASH;
local Player = FindMetaTable("Player");
BASH.Commands = BASH.Commands or {};
BASH.Commands.Name = "Commands";
BASH.Commands.Entries = BASH.Commands.Entries or {};
BASH.Commands.KeywordRef = BASH.Commands.KeywordRef or {};
BASH.Commands.Dependencies = {["Ranks"] = true, ["SQL"] = SERVER};

function BASH.Commands:Init()
    self:AddCommand{
        ID = "initconfig",
        Name = "Initialize Config",
        Desc = "Starts the inital config to be set up by the targeted player.",
        Keywords = {"initconfig"},
        Arguments = {
            {"string", "Player"}
        },
        IsInScope = SERVER,
        Function = function(self, ply, args)
            if ply != NULL then
                MsgErr("[CMD.initconfig(%s)]: Must be called from the server console!", concatArgs(ply, args));
                return;
            end

            if BASH.Config.InitialSet then
                MsgErr("[CMD.initconfig(%s)]: The config has already been initially setup!", concatArgs(ply, args));
                return;
            end

            if BASH.Config.SettingUp then
                MsgErr("[CMD.initconfig(%s)]: The config is already being setup!", concatArgs(ply, args));
                return;
            end

            local target = player.GetByNick(args[1]);
            if !target then
                MsgErr("[CMD.initconfig(%s)]: Cannot find a player by that name!", concatArgs(ply, args));
                return;
            end

            target.SettingConfig = true;
            BASH.Config.SettingUp = true;
            net.Empty("BASH_CONFIG_INIT", target);

            MsgCon(color_green, true, "Commencing config initialization on player %s [%s].", target:Name(), target:SteamID());
        end
    };

    self:AddCommand{
        ID = "setowner",
        Name = "Set Owner",
        Desc = "Add a player to the \'owner\' rank through the server console.",
        Keywords = {"setowner"},
        Arguments = {
            {"string", "Player/Character"}
        },
        IsInScope = SERVER,
        Function = function(self, ply, args)
            if ply != NULL then
                MsgErr("[CMD.setowner(%s)]: Must be called from the server console!", concatArgs(ply, args));
                return;
            end

            if !BASH.SQL.Connected then
                MsgErr("[CMD.setowner(%s)]: The SQL database must be setup before you can set an owner!", concatArgs(ply, args));
                return;
            end

            local target = player.GetByNick(args[1]);
            if !target then
                MsgErr("[CMD.setowner(%s)]: Cannot find a player by that name!", concatArgs(ply, args));
                return;
            end

            if BASH.Config.InitialSet then
                target:SetRank("owner");
                MsgCon(color_green, true, "%s [%s] set to owner rank.", target:Name(), target:SteamID());
            end

            MsgN(target:GetRank());
        end
    };

    self:AddCommand{
        ID = "maxlast",
        Name = "Maximize Last",
        Desc = "Maximize the last window minimized.",
        Keywords = {"maxlast", "lastmax"},
        IsInScope = CLIENT,
        Function = function(self, ply, args)
            if !checkpanel(BASH.GUI.LastMinimized) then
                MsgCon(color_darkred, false, "[CMD.maximizelast()]: No valid panel to maximize!");
                return;
            end

            BASH.GUI:Maximize(BASH.GUI.LastMinimized);
            BASH.GUI.LastMinimized = nil;
        end
    };

    hook.Call("LoadCommands", BASH);
end

function BASH.Commands:AddCommand(commTab)
    if !commTab then return end;
    if !commTab.ID then
        MsgErr("[BASH.Commands.AddCommand] -> Tried adding a command with no ID!");
        return;
    end
    if self.Entries[commTab.ID] then
        MsgErr("[BASH.Commands.AddCommand] -> A command with the ID '%s' already exists!", commTab.ID);
        return;
    end
    if #commTab.Keywords <= 0 then
        MsgErr("[BASH.Commands.AddCommand] -> Tried adding a command '%s' with no keywords!", commTab.ID);
        return;
    end

    commTab.Name = commTab.Name or "Unknown Command";
    commTab.Desc = commTab.Desc or "";
    commTab.Keywords = commTab.Keywords or {};
    commTab.Arguments = commTab.Arguments or {};
    commTab.Prefix = commTab.Prefix or '/';
    commTab.AccessLevel = commTab.AccessLevel or 0;
    commTab.AccessFlag = commTab.AccessFlag or "";
    commTab.IsInScope = commTab.IsInScope or false;
    commTab.Function = commTab.Function or function(_self, ply, args) MsgN(_self.ID .. "(): Executed") end;

    for _, keyword in pairs(commTab.Keywords) do
        self.KeywordRef[keyword] = commTab;
    end
    self.Entries[commTab.ID] = commTab;
end

concommand.Add("bash", function(ply, cmd, args)
    if !args[1] then
        MsgCon(color_green, false, "Valid commands:");
        for id, comm in SortedPairs(BASH.Commands.Entries) do
            if !comm.IsInScope then continue end;
            MsgCon(color_white, false, "\t%s (%s):", comm.Name, comm.Desc);
            MsgCon(color_blue, false, "\t\tKeywords:");
            for _, keyword in pairs(comm.Keywords) do
                MsgCon(color_con, false, "\t\t\t%s", keyword);
            end
            MsgCon(color_cyan, false, "\t\tArguments:");
            if #comm.Arguments > 0 then
                for _, argTab in ipairs(comm.Arguments) do
                    MsgCon(color_con, false, "\t\t\t%s (%s)", argTab[2], argTab[1]);
                end
            else
                MsgCon(color_con, false, "\t\t\tNone.");
            end
        end
        return;
    end

    local comm = BASH.Commands.KeywordRef[args[1]];
    if !comm then
        MsgCon(color_darkred, false, "No command '%s' found!", args[1]);
    else
        if !comm.IsInScope then
            MsgCon(color_darkred, false, "You're not allowed to do that within your current scope!");
            return;
        end
        if ply != NULL then
            if ply:GetAccessLevel() < comm.AccessLevel then
                MsgCon(color_darkred, false, "You're not allowed to do that with your current access level! (%d < %d)", ply:GetAccessLevel(), comm.AccessLevel);
                return;
            elseif comm.AccessFlag != "" && !ply:HasFlag(comm.AccessFlag) then
                MsgCon(color_darkred, false, "You're not allowed to do that with your current flags! (Needed: %s)", comm.AccessFlag);
                return;
            end
        end

        table.remove(args, 1);
        local commType, commDesc;
        local isOptional = false;
        for index, commArg in ipairs(comm.Arguments) do
            commType = commArg[1];
            commDesc = commArg[2];
            if string.EndsWith(commType, '*') then
                isOptional = true;
                commType = string.Replace(commType, '*', '');
            end

            if !args[index] and !isOptional then
                MsgCon(color_darkred, false, "Argument #%d (%s - %s) is required but has not been supplied!", index, commType, commDesc);
                return;
            end
            if type(args[index]) != commType and !isOptional then
                MsgCon(color_darkred, false, "Argument #%d (%s - %s) has incorrect type! Supplied: %s", index, commType, commDesc, type(args[index]));
                return;
            end
            isOptional = false;
        end
        comm:Function(ply, args);
    end
end,
function(cmd, args)
    args = string.Trim(string.lower(args));
    local tab = {};
    local curChar, wrappingString, wrapStart = '', false, 1;
    for index = 1, string.len(args) do
        curChar = string.GetChar(args, index);
        if curChar == ' ' and !wrappingString then
            table.insert(tab, string.sub(args, wrapStart, index - 1));
            wrapStart = index + 1;
        elseif curChar == '\"' and index + 1 <= string.len(args) then
            wrappingString = !wrappingString;
        elseif index + 1 > string.len(args) then
            table.insert(tab, string.sub(args, wrapStart, index));
            break;
        end
    end

    local results = {};
    local curLine;
    if #tab <= 1 then
        for id, comm in pairs(BASH.Commands.Entries) do
            if !comm.IsInScope then continue end;
            for _, keyword in pairs(comm.Keywords) do
                curLine = "bash ";
                if !tab[1] or tab[1] == string.sub(keyword, 1, string.len(tab[1])) then
                    curLine = curLine .. keyword .. " ";
                    if #comm.Arguments > 0 then
                        for index, argTab in ipairs(comm.Arguments) do
                            if argTab[1] == "string" then
                                curLine = curLine .. "\"" .. argTab[2] .. "\" ";
                            else
                                curLine = curLine .. argTab[2] .. " ";
                            end
                        end
                    end
                    table.insert(results, string.Trim(curLine));
                end
            end
        end
    elseif #tab > 1 then
        local comm = BASH.Commands.KeywordRef[tab[1]];
        if comm then
            curLine = "bash " .. tab[1] .. " ";
            if #comm.Arguments > 0 then
                for index, argTab in ipairs(comm.Arguments) do
                    if argTab[1] == "string" then
                        curLine = curLine .. "\"" .. argTab[2] .. "\" ";
                    else
                        curLine = curLine .. argTab[2] .. " ";
                    end
                end
            end
            table.insert(results, string.Trim(curLine));
        end
    end

    return results;
end);

BASH:RegisterLib(BASH.Commands);
