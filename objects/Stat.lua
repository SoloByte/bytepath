Stat = Object:extend()



function Stat:new(base)
    self.base = base
    self.additive = 0
    self.additives = {}
    self.value = self.base * (1 + self.additive)
end

function Stat:update(dt)
    local count = #self.additives
    for i = 1, count do
        local add = self.additives[i]
        self.additive = self.additive + add
    end

    if self.additive > 0 then
        self.value = self.base * (1 + self.additive)
    else
        self.value = self.base / (1 - self.additive)
    end

    self.additive = 0
    self.additives = {}
end

function Stat:increase(percentage)
    table.insert(self.additives, percentage * 0.01)
end

function Stat:decrease(percentage)
    table.insert(self.additives, -percentage * 0.01)
end