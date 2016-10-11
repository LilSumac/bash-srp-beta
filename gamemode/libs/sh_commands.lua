local BASH = BASH;
local Player = FindMetaTable("Player");
BASH.Commands = BASH.Commands or {};
BASH.Commands.Name = "Commands";
BASH.Commands.Entries = BASH.Commands.sEntries or {};
BASH.Commands.Dependencies = {["Ranks"] = true, ["SQL"] = SERVER};

function BASH.Commands:Init()
    MsgCon(color_green, true, "Initializing commands...");
    if !BASH:LibDepMet(self) then return end;

    local comm = {
        ID = "initconfig",
        Name = "Initialize Config",
        Desc = "Starts the inital config to be set up by the targeted player.",
        Keywords = {"initconfig"},
        Arguments = {
            {"string", "Player"}
        },
        AccessLevel = -1,
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
            snow.Send(target, "BASH_CONFIG_INIT");
            MsgCon(color_green, true, "Commencing config initialization on player %s [%s].", target:Name(), target:SteamID());
        end
    };
    self:AddEntry(comm);

    comm = {
        ID = "setowner",
        Name = "Set Owner",
        Desc = "Add a player to the \'owner\' rank through the server console.",
        Keywords = {"setowner"},
        Arguments = {
            {"string", "Player"}
        },
        AccessLevel = -1,
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
    self:AddEntry(comm);

    hook.Call("LoadCommands", BASH);

    MsgCon(color_green, true, "Command initialization complete!");
end

function BASH.Commands:AddEntry(commTab)
    if !commTab then return end;
    if !commTab.ID then
        MsgErr("[BASH.Commands:AddEntry(%s)]: Tried adding a command with no ID!", concatArgs(commTab));
        return;
    end
    if self.Entries[commTab.ID] then
        MsgErr("[BASH.Commands:AddEntry(%s)]: A command with the ID '%s' already exists!", concatArgs(commTab), commTab.ID);
        return;
    end

    commTab.Name = commTab.Name or "Unknown Command";
    commTab.Desc = commTab.Desc or "";
    commTab.Keywords = commTab.Keywords or {};
    commTab.Arguments = commTab.Arguments or {};
    commTab.Prefix = commTab.Prefix or '/';
    commTab.AccessLevel = commTab.AccessLevel or -1;
    commTab.AccessFlag = commTab.AccessFlag or "";
    commTab.IsInScope = commTab.IsInScope or false;
    commTab.Function = commTab.Function or function(_self, ply, args) MsgN(_self.ID .. "(): Executed") end;

    self.Entries[commTab.ID] = commTab;
end

function Player:CanExecute(cmd)
    if isstring(cmd) then
        cmd = BASH.Commands.Entries[cmd];
    end
    if !cmd then return false end;
    return cmd.IsInScope and
           (ply:GetAccessLevel() >= cmd.AccessLevel);
end

concommand.Add("bash", function(ply, cmd, args)
    if !args[1] then
        MsgCon(color_green, false, "Valid commands:");
        for id, comm in pairs(BASH.Commands.Entries) do
            if !comm.IsInScope then continue end;
            MsgCon(color_con, false, "\t%s", com);
        end
    end
    local comm = BASH.Commands.Entries[args[1]];

    if !comm then
        MsgCon(color_red, false, "No command '%s' found!", args[1]);
    else
        if !comm.IsInScope then
            MsgCon(color_red, false, "You're not allowed to do that within your current scope!");
            return;
        end
        if ply != NULL then
            /*
            if ply:GetAccessLevel() < comm.AccessLevel then
                MsgCon(color_red, false, "You're not allowed to do that with your current access level! (%d -> %d)", ply:GetAccessLevel(), comm.AccessLevel);
                return;
            elseif comm.AccessFlag != "" && !ply:HasFlag(comm.AccessFlag) then
                MsgCon(color_red, false, "You're not allowed to do that with your current flags! (Needed: %s)", comm.AccessFlag);
                return;
            end
            */
        end

        table.remove(args, 1);
        local commType, commDesc;
        local isOptional = false;
        for index, commArg in pairs(comm.Arguments) do
            commType = commArg[1];
            commDesc = commArg[2];
            if string.EndsWith(commType, '*') then
                isOptional = true;
                commType = string.Replace(commType, '*', '');
            end

            if !args[index] and !isOptional then
                MsgCon(color_red, false, "Argument #%d (%s - %s) is required but has not been supplied!", index, commType, commDesc);
                return;
            end
            if type(args[index]) != commType and !isOptional then
                MsgCon(color_red, false, "Argument #%d (%s - %s) has incorrect type! Supplied: %s", index, commType, commDesc, type(args[index]));
                return;
            end
            isOptional = false;
        end
        comm:Function(ply, args);
    end
end,
function(cmd, args)
    args = string.Trim(args);
    args = string.lower(args);
    local tab = string.Explode(" ", args);
    local results = {};
    local curLine, curArg;

    if tab[1] and tab[1] != "" then
        for id, comm in pairs(BASH.Commands.Entries) do
            for _, keyword in pairs(comm.Keywords) do
                curLine = "bash ";
                if string.sub(keyword, 1, string.len(tab[1])) then
                    curLine = curLine .. keyword;
                    table.insert(results, curLine);
                    break;
                end
            end
        end
    end

    return results;
end);
