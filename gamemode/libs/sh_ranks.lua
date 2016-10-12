local BASH = BASH;
BASH.Ranks = BASH.Ranks or {};
BASH.Ranks.Name = "Ranks";
BASH.Ranks.Entries = BASH.Ranks.Entries or {};
BASH.Ranks.StaffCache = BASH.Ranks.StaffCache or {};
local Player = FindMetaTable("Player");

function BASH.Ranks:Init()
    /*
    **  Create Default Ranks
    */

    local rank = {
        ID = "owner",
        Name = "Owner",
        AccessLevel = 100
    };
    self:NewRank(rank);

    rank = {
        ID = "dev",
        Name = "Developer",
        Desc = "A developer of the server. Has complete control over everything.",
        AccessLevel = 100
    };
    self:NewRank(rank);

    rank = {
        ID = "sadmin",
        Name = "Super Admin",
        Desc = "",
        AccessLevel = 90
    };
    self:NewRank(rank);

    rank = {
        ID = "admin",
        Name = "Admin",
        Desc = "",
        AccessLevel = 80
    };
    self:NewRank(rank);

    rank = {
        ID = "default",
        Name = "",
        Desc = "",
        AccessLevel = 0
    };
    self:NewRank(rank);
end

function BASH.Ranks:NewRank(rankTab)
    if !rankTab then return end;
    if !rankTab.ID or !rankTab.Name then
        MsgErr("[BASH.Ranks:NewRank(%s)]: Tried adding a new rank with no ID/Name!", concatArgs(rankTab));
        return;
    end
    if self.Entries[rankTab.ID] then
        MsgErr("[BASH.Ranks:NewRank(%s)]: A rank with the ID '%s' already exists!", concatArgs(rankTab), rankTab.ID);
        return;
    end

    rankTab.Name = rankTab.Name or "Unknown Rank";
    rankTab.Desc = rankTab.Desc or "";
    rankTab.AccessLevel = rankTab.AccessLevel or 0;
    rankTab.Whitelists = rankTab.Whitelists or {};
    rankTab.AllowedCMD = rankTab.AllowedCMD or {};
    rankTab.DeniedCMD = rankTab.DeniedCMD or {};

    self.Entries[rankTab.ID] = confTab;
    MsgCon(color_green, false, "Registered rank with ID '%s'!", rankTab.ID);
end

function BASH.Ranks:GetStaff()
    if self.StaffCache then return self.StaffCache end;

    self.StaffCache = {};
    local index = {};
    for _, ply in pairs(player.GetAll()) do
        if ply:IsStaff() then
            index = index + 1;
            self.StaffCache[ply] = ply:GetChar() or "Loading...";
        end
    end
    return self.StaffCache, index - 1;
end

function Player:GetAccessLevel()
	return BASH.Ranks.Entries[self:GetRank()].AccessLevel;
end

BASH:RegisterLib(BASH.Ranks);
