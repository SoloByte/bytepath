EnemyProjectile = GameObject:extend()




function EnemyProjectile:new(area, x, y, opts)
    EnemyProjectile.super.new(self, area, x, y, opts)
    self.depth = 65
    self.s = opts.s or 2.5
    self.v = opts.v or 200
    self.damage = opts.damage or 10
    --self.color = attacks[self.attack].color
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    self.collider:setCollisionClass("EnemyProjectile")
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
end



function EnemyProjectile:update(dt)
    EnemyProjectile.super.update(self, dt)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    if self:checkBounds() then
        self:die()
    end

    if self.collider:enter("Player") then
        local col_info = self.collider:getEnterCollisionData("Player")
        local object = col_info.collider:getObject()
        object:hit(self.damage, self.x, self.y)
        self:die()
    elseif self.collider:enter("Projectile") then
        local col_info = self.collider:getEnterCollisionData("Projectile")
        local object = col_info.collider:getObject()
        if object.attack ~="Sniper" then
            object:die()
        end
        self:die()
    end
end

function EnemyProjectile:draw()
    pushRotate(self.x, self.y, Vector(self.collider:getLinearVelocity()):angleTo())
    love.graphics.setLineWidth(self.s - self.s * 0.25)
    
    love.graphics.setColor(hp_color)
    love.graphics.line(self.x - 2 * self.s, self.y, self.x + 2 * self.s, self.y)
    
    love.graphics.setLineWidth(1)
    love.graphics.pop()
    love.graphics.setColor(default_color)
end

function EnemyProjectile:destroy()
    EnemyProjectile.super.destroy(self)
end

function EnemyProjectile:die()
    self.dead = true
    self.area:addGameObject("ProjectileDeathEffect", self.x, self.y, {color = hp_color, w = 3 * self.s})
end