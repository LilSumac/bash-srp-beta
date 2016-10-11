local BASH = BASH;
local Player = FindMetaTable("Player");

function Player:GetInventory()
    return detype(BASH.Players[self:SteamID()]["Inventory"], "table");
end

function Player:GetGear()
    return detype(BASH.Players[self:SteamID()]["Gear"], "table");
end

function Player:GetNextSlot()
    local inv = self:GetInventory();
    for invY = 1, #inv[1] do
        for invX = 1, #inv do
            if !inv[invX][invY].ID then return invX, invY end;
        end
    end
end

function Player:HasItem(id, conditions)
    local inv, gear, itemTab, itemMatch = self:GetInventory(), self:GetGear(), nil, false;
    for invY = 1, #inv[1] do
        for invX = 1, #inv do
            if !inv[invX][invY].ID then continue end;
            itemTab, itemMatch = getItem(inv[invX][invY].ID), false;
            if item.ID == id then
                if conditions then
                    for condition, val in pairs(conditions) do
                        if !item[condition] then
                            itemMatch = false;
                            break;
                        end
                        if isOperation(val) then
                            itemMatch = doOperation(item[condition], val);
                        else
                            itemMatch = item[condition] == val;
                        end
                    end
                    if itemMatch then
                        return true, invX, invY;
                    end
                else return true, invX, invY end;
            end
        end
    end
    return false;
end

function Player:InventoryFull()
    local inv = self:GetInventory();
    for invY = 1, #inv[1] do
        for invX = 1, #inv do
            if !inv[invX][invY].ID then return false end;
        end
    end
    return true;
end

function Player:InventoryWeight()
    local inv, gear, weight = self:GetInventory(), self:GetGear(), 0;
    for invY = 1, #inv[1] do
        for invX = 1, #inv do
            if !inv[invX][invY].ID then continue end;
            local item = getItem(inv[invX][invY].ID);
            weight = weight + item.Weight or 0;
        end
    end
    for slot, _gear in pairs(gear) do
        if !_gear.ID then continue end;
        local item = getItem(_gear.ID);
        weight = weight + item.Weight or 0;
    end
    return weight;
end
