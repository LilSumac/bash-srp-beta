local BASH = BASH;

function Player:GiveItem(id, data)
    if !checkply(self) then return false end;
    if !id then return false end;

    local inv = self:GetInventory();
    local x, y = self:GetNextSlot();
    if !x or !y then return false end;
    if inv[x][y].ID then return false end;
    inv[x][y].ID = id;
    table.Merge(inv[x][y], data);
    self:PushChanges();
    return true;
end

function Player:TakeItem(id, conditions)
    if !checkply(self) then return false end;
    if !id then return false end;

    local hasItem, x, y = self:HasItem(id, conditions);
    if !hasItem then return false end;
    local inv = self:GetInventory();
    if !inv[x][y].ID then return false end;
    inv[x][y] = {};
    self:PushChanges();
    return true;
end

function Player:RemoveItem(x, y)
    if !checkply(self) then return false end;
    if !x or !y then return false end;

    local inv = self:GetInventory();
    if !inv[x][y].ID then return false end;
    inv[x][y] = {};
    self:PushChanges();
    return true;
end

concommand.Add("bash_pickup", function(ply, cmd, args)
    if !checkply(ply) then return end;
    local entID = args[1];
    if !entID or ent == -1 then return end;
    local ent = Entity(entID);
    if !ent or !ent:IsValid() or !ent:IsItem() then return end;
    if ent:GetTable().LastUser != ply then return end;

    if ply:InventoryFull() then
        ply:PrintChat(CHAT_TYPES[CHAT_UTIL], "Your inventory is full!", true);
    end

    ply:GiveItem(ent:GetTable().ItemID, ent:GetTable().ItemData);
end);

concommand.Add("bash_equip", function(ply, cmd, args)
    if !checkply(ply) then return end;

end);

concommand.Add("bash_inv_move", function(ply, cmd, args)
    if !checkply(ply) then return end;

end);

concommand.Add("bash_inv_equip", function(ply, cmd, args)
    if !checkply(ply) then return end;

end);

concommand.Add("bash_inv_split", function(ply, cmd, args)
    if !checkply(ply) then return end;

end);

concommand.Add("bash_inv_update", function(ply, cmd, args)
    if !checkply(ply) then return end;

end);

concommand.Add("bash_inv_remove", function(ply, cmd, args)
    if !checkply(ply) then return end;

end);

concommand.Add("bash_inv_scrap", function(ply, cmd, args)
    if !checkply(ply) then return end;

end);

concommand.Add("bash_inv_drop", function(ply, cmd, args)
    if !checkply(ply) then return end;

end);
