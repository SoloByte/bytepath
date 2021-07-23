LightningLine = GameObject:extend()



function LightningLine:new(area, x, y, opts)
    LightningLine.super.new(self, area, x, y, opts)
    self.depth = 75


    self:generate()
end

function LightningLine:generate()
    
end
function LightningLine:update(dt)
    LightningLine.super.update(self, dt)
end

function LightningLine:draw()
end

function LightningLine:destroy()
    LightningLine.super.destroy(self)
end