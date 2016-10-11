local BASH = BASH;
snow = snow or {};

if SERVER then
    function snow.Broadcast(nwStr, ...)
        snow.Write(nwStr, {...});
        net.Broadcast();
    end
    function snow.Send(rec, nwStr, ...)
        snow.Write(nwStr, {...});
        net.Send(rec);
    end
    function snow.SendOmit(omit, nwStr, ...)
        if !omit then
            MsgErr("[snow.SendOmit(%s)]: Tried to send an omit net message without a filter!", nwStr);
            return;
        end

        snow.Write(nwStr, {...});
        net.SendOmit(omit);
    end
    function snow.SendPVS(pos, nwStr, ...)
        if !pos or !isvector(pos) then
            MsgErr("[snow.SendOmit(%s)]: Tried to send a PVS net message without a valid position!", nwStr);
            return;
        end

        snow.Write(nwStr, {...});
        net.SendPVS(pos);
    end
    function snow.SendPAS(pos, nwStr, ...)
        if !pos or !isvector(pos) then
            MsgErr("[snow.SendOmit(%s)]: Tried to send a PAS net message without a valid position!", nwStr);
            return;
        end

        snow.Write(nwStr, {...});
        net.SendPAS(pos);
    end
elseif CLIENT then
    function snow.SendToServer(nwStr, ...)
        snow.Write(nwStr, {...});
        net.SendToServer();
    end
end

local netWrite = {
    number = net.WriteFloat,
    string = net.WriteString,
    boolean = net.WriteBool,
    table = function(tab)
        if IsColor(tab) then net.WriteColor(tab)
        else net.WriteTable(tab) end
    end,
    Vector = net.WriteVector,
    Entity = net.WriteEntity,
    Weapon = net.WriteEntity,
    Player = net.WriteEntity,
    NPC = net.WriteEntity,
    Vehicle = net.WriteEntity
};
local authedNetSrc = {
    ["gamemodes/bash-srp-beta/"] = true,
    ["lua/"] = true
};

function snow.Write(nwStr, args)
    if !nwStr then
        MsgErr("[snow] Tried to send a net message without a network string!");
        return;
    end

    /*  Work on this.
    local stackReach = 1;
    while true do
        if !debug.getinfo(stackReach + 1) then break;
        else stackReach = stackReach + 1 end;
    end
    if !authedNetSrc[string.sub(debug.getinfo(stackReach).short_src, 1, 33)] then
        MsgErr("[snow] UNAUTHORIZED NET MESSAGE: %s", nwStr);
        PrintTable(debug.getinfo(stackReack));
        return;
    end
    */

    if util.NetworkStringToID(nwStr) == 0 then
        if SERVER then
            util.AddNetworkString(nwStr);
            MsgCon(color_green, true, "[snow] Adding string '%s' to network pool and resending.", nwStr);
        elseif CLIENT then
            MsgErr("[snow] Tried to send a net message with an unpooled network string! (%s)", nwStr);
            return;
        end
    end

    net.Start(nwStr);
    local valType;
    for index, val in pairs(args) do
        valType = type(val);
        if !netWrite[valType] then
            MsgErr("[snow] Tried to send a net message with an unhandled data type! (%s)", valType);
            return;
        end
        netWrite[valType](val, 32);
    end
end
