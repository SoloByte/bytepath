ProjectileTrail = GameObject:extend()




function ProjectileTrail:new(area, x, y, opts)
    ProjectileTrail.super.new(self, area, x, y, opts)

    self.alpha = 0.5
    self.timer:tween(random(0.1, 0.3), self, {alpha = 0}, "in-out-cubic", function() self.dead = true end)
end


function ProjectileTrail:update(dt)
    ProjectileTrail.super.update(self, dt)
end

function ProjectileTrail:draw()
    pushRotate(self.x, self.y, self.r)
    local r, g, b = unpack(self.color)
    love.graphics.setColor(r, g, b, self.alpha)
    love.graphics.setLineWidth(2)
    love.graphics.line(self.x - self.s * 2, self.y, self.x + self.s * 2, self.y)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

function ProjectileTrail:destroy()
    ProjectileTrail.super.destroy(self)
end