local BASH = BASH;
BASH.Ranks = BASH.Ranks or {};
BASH.Ranks.Name = "Ranks";
BASH.Ranks.Entries = BASH.Ranks.Entries or {};
BASH.Ranks.StaffCache = BASH.Ranks.StaffCache or {};
BASH.Ranks.Dependencies = BASH.Ranks.Dependencies or {["Registry"] = true};
local Player = FindMetaTable("Player");

function BASH.Ranks:Init()
    /*
    **  Create Default Ranks
    */
    self:AddEntry{
        ID = "owner",
        Name = "Owner",
        AccessLevel = 100,
        IsStaff = true
    };

    self:AddEntry{
        ID = "dev",
        Name = "Developer",
        Desc = "A developer of the server. Has complete control over everything.",
        AccessLevel = 100,
        IsStaff = true
    };

    self:AddEntry{
        ID = "sadmin",
        Name = "Super Admin",
        Desc = "",
        AccessLevel = 90,
        IsStaff = true
    };

    self:AddEntry{
        ID = "admin",
        Name = "Admin",
        Desc = "",
        AccessLevel = 80,
        IsStaff = true
    };

    self:AddEntry{
        ID = "default",
        Name = "",
        Desc = "",
        AccessLevel = 0
    };
end

function BASH.Ranks:AddEntry(rankTab)
    if !rankTab then return end;
    if !rankTab.ID or !rankTab.Name then
        MsgErr("[BASH.Ranks:AddEntry(%s)]: Tried adding a new rank with no ID/Name!", concatArgs(rankTab));
        return;
    end
    if self.Entries[rankTab.ID] then
        MsgErr("[BASH.Ranks:AddEntry(%s)]: A rank with the ID '%s' already exists!", concatArgs(rankTab), rankTab.ID);
        return;
    end

    rankTab.Name = rankTab.Name or "Unknown Rank";
    rankTab.Desc = rankTab.Desc or "";
    rankTab.Color = rankTab.Color or color_con;
    rankTab.AccessLevel = rankTab.AccessLevel or 0;
    rankTab.Whitelists = rankTab.Whitelists or {};
    rankTab.AllowedCMD = rankTab.AllowedCMD or {};
    rankTab.DeniedCMD = rankTab.DeniedCMD or {};
    rankTab.IsStaff = rankTab.IsStaff or false;

    self.Entries[rankTab.ID] = confTab;
    MsgCon(color_green, false, "Registered rank with ID '%s'!", rankTab.ID);
end

function BASH.Ranks:GetStaff()
    //  not sure why i was really trying to optimize this with caching. dont call on GUI drawing.
    local staff = {};
    for _, ply in pairs(player.GetAll()) do
        if ply:IsStaff() then staff[#staff + 1] = ply end;
    end
    return staff;
end

function Player:GetRankName()
    if !self:GetRank() then return "" end;
    return BASH.Ranks.Entries[self:GetRank()].Name;
end

function Player:GetAccessLevel()
    if !self:GetRank() then return -1 end;
	return BASH.Ranks.Entries[self:GetRank()].AccessLevel;
end

function Player:IsStaff()
    return self:GetRank() and BASH.Ranks.Entries[self:GetRank()].IsStaff;
end

/*
**
*/
hook.Add("LoadVariables", "BASH_AddRankVariable", function()
    BASH.Registry:AddVariable{
        Name = "Rank",
        Type = "string",
        Default = "default",
        Public = true,
        SQLTable = "bash_players"
    };
end);

BASH:RegisterLib(BASH.Ranks);
