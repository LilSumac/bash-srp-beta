Queue = {};
Queue.meta = {};
Queue.meta.__index = Queue.meta;

function Queue:Create(...)
    local tab = {};
    tab.Entries = {};
    setmetatable(tab, self.meta);

    local args = {...};
    if args and #args > 0 then
        tab:enqueue(...);
    end
    
    return tab;
end

function Queue.meta:enqueue(...)
    if !(...) then return end;

    local args = {...};
    for _, val in pairs(args) do
        table.insert(self.Entries, val);
    end

    return #self.Entries;
end

function Queue.meta:dequeue(num)
    num = num or 1;
    local entries = {};
    for index = 1, num do
        if #self.Entries > 0 then
            table.insert(entries, self.Entries[#self.Entries]);
            table.remove(self.Entries, 1);
        else break end;
    end

    return unpack(entries);
end

function Queue.meta:elem()
    return self.Entries;
end

function Queue.meta:first()
    return self.Entries[1];
end

function Queue.meta:len()
    return #self.Entries;
end

function Queue.meta:print()
    MsgCon(color_green, false, "Queue: %s", tostring(self));
    for index, val in pairs(self.Entries) do
        MsgCon(color_green, false, "\t%d : %s", index, val);
    end
end
