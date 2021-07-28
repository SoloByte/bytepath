EnemyProjectile = GameObject:extend()




function EnemyProjectile:new(area, x, y, opts)
    EnemyProjectile.super.new(self, area, x, y, opts)
    self.depth = 65
    self.s = opts.s or 2.5
    self.v = opts.v or 200
    self.damage = opts.damage or 10
    self.explosion_radius = opts.explosion_radius or 64
    self.barrage_explosion = opts.barrage_explosion or false
    self.explode_on_expiration = false
    self.mine = opts.mine or false
    if self.mine then
        self.explode_on_expiration = true
        self.rv = table.random({random(-12*math.pi, -10 * math.pi), random(10 * math.pi, math.pi * 12)})
        self.timer:after(random(8, 10), function() self:expire() end)
    end

    --self.color = attacks[self.attack].color
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    self.collider:setCollisionClass("EnemyProjectile")
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
end



function EnemyProjectile:update(dt)
    EnemyProjectile.super.update(self, dt)

    if self.mine then
        self.r = self.r + self.rv * dt
    end

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

function EnemyProjectile:explode()
    --if self.barrage_explosion then
        --[[
        local barrage_count = 5 + (self.barrage_count or 0)
        local start_angle = self.r
        local angle_step = (math.pi * 2) / barrage_count
        local current_angle = start_angle
        local d = self.s
        for i = 1, barrage_count do
            self:spawnSplitProjectile(current_angle, d, "Neutral")
            current_angle = current_angle + angle_step
        end
        --]]
    --else
        self.area:addGameObject("ProjectileDeathEffect", self.x, self.y, {color = hp_color, w = self.explosion_radius})
        for i = 1, love.math.random(4, 8) do 
            self.area:addGameObject("ExplodeParticle", self.x, self.y, {color = self.color, s = random(5, 10), v = random(150, 200)}) 
        end
        local targets = self.area:getGameObjectsInCircle(self.x, self.y, self.explosion_radius, "projectiles", "all")
        if current_room.player then
            local dis_sq = distanceSquared(self.x, self.y, current_room.player.x, current_room.player.y)
            if dis_sq <= self.explosion_radius * self.explosion_radius then
                table.insert(targets, current_room.player)
            end
        end
        for i = 1, #targets do
            local target = targets[i]
            target:hit()
        end
    --end
   
end


function EnemyProjectile:expire()
    if self.explode_on_expiration then
        self:explode()
    end
    self:die()
end

function EnemyProjectile:destroy()
    EnemyProjectile.super.destroy(self)
end

function EnemyProjectile:die()
    self.dead = true
    if self.mine then
        self:explode()
    else
        self.area:addGameObject("ProjectileDeathEffect", self.x, self.y, {color = hp_color, w = 3 * self.s})
    end
end