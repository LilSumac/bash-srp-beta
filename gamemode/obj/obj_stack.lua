Stack = {};
Stack.meta = {};

function Stack:Create(...)
    local tab = {};
    tab.Entries = {};
    setmetatable(tab, self.meta);

    local args = {...};
    if args and #args > 0 then
        tab:push(...);
    end

    return tab;
end

function Stack.meta:push(...)
    if !(...) then return end;

    local args = {...};
    for _, val in pairs(args) do
        table.insert(self.Entries, val);
    end

    return #self.Entries;
end

function Stack.meta:pop(num)
    num = num or 1;
    local entries = {};
    for index = 1, num do
        if #self.Entries > 0 then
            table.insert(entries, self.Entries[#self.Entries]);
            table.remove(self.Entries);
        else break end;
    end

    return unpack(entries);
end

function Stack.meta:peek()
    return self.Entries[#self.Entries];
end

function Stack.meta:len()
    return #self.Entries;
end

function Stack.meta:print()
    MsgCon(color_green, false, "Stack: %s", tostring(self));
    for index = 0, #self.Entries do
        MsgCon(color_green, false, "\t%d : %s", index + 1, self.Entries[#self.Entries - index]);
    end
end
