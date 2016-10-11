local BASH = BASH;
local Entity = FindMetaTable("Entity");

/*
**  Boolean Functions
*/

local prop_types = {
    ["prop_physics"] = true,
    ["prop_physics_multiplayer"] = true,
    ["prop_physics_override"] = true,
    ["prop_ragdoll"] = true
};
function Entity:IsProp()
    if self and self:IsValid() then
        return prop_types[self:GetClass()];
    end
    return false;
end

local door_types = {
    ["func_door"] = true,
    ["func_door_rotating"] = true,
    ["prop_door_rotating"] = true
};
function Entity:IsDoor()
    if self and self:IsValid() then
        return door_types[self:GetClass()];
    end
    return false;
end

function Entity:IsItem()
    if self and self:IsValid() then
        return self:GetClass() == "bash_item";
    end
    return false;
end
