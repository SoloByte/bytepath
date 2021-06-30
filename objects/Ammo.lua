Ammo = GameObject:extend()



function Ammo:new(area, x, y, opts)
    Ammo.super.new(self, area, x, y, opts)
    self.depth = 75

    self.w, self.h = 8,8
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    --self.collider:setFixedRotation(false)
    self.r = random(0, 2*math.pi)
    self.v = random(10, 20)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.collider:applyAngularImpulse(random(-24, 24))
end


function Ammo:update(dt)
    Ammo.super.update(self, dt)
end

function Ammo:draw()
    love.graphics.setColor(ammo_color)
    love.graphics.print(self.collider:getAngle(), self.x + 4, self.y)
    --pushRotate(self.x, self.r, self.collider:getAngle())
    draft:rhombus(self.x, self.y, self.w, self.h, "line")
    --love.graphics.pop()
    love.graphics.setColor(default_color)
end

function Ammo:destroy()
    Ammo.super.destroy(self)
end