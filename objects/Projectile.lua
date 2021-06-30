Projectile = GameObject:extend()




function Projectile:new(area, x, y, opts)
    Projectile.super.new(self, area, x, y, opts)
    self.depth = 60
    self.s = opts.s or 2.5
    self.v = opts.v or 200

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
end



function Projectile:update(dt)
    Projectile.super.update(self, dt)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    if self:checkBounds() then
        self:die()
    end
end

function Projectile:draw()
    love.graphics.setColor(default_color)
    love.graphics.circle("line", self.x, self.y, self.s)
end

function Projectile:destroy()
    Projectile.super.destroy(self)
end

function Projectile:die()
    self.dead = true
    self.area:addGameObject("ProjectileDeathEffect", self.x, self.y, {color = hp_color, w = 3 * self.s})
end