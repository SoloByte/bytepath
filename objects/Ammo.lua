Ammo = GameObject:extend()



function Ammo:new(area, x, y, opts)
    Ammo.super.new(self, area, x, y, opts)
    self.depth = 75
end


function Ammo:update(dt)
    Ammo.super.update(self, dt)
end

function Ammo:draw()
    
end

function Ammo:destroy()
    Ammo.super.destroy(self)
end