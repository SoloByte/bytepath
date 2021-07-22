Projectile = GameObject:extend()




function Projectile:new(area, x, y, opts)
    Projectile.super.new(self, area, x, y, opts)
    self.depth = 60
    self.s = opts.s or 2.5
    self.s = self.s * (opts.multipliers.size or 1)
    self.v = opts.v or 200
    self.v = self.v * (opts.multipliers.speed or 1)
    self.damage = opts.damage or 100
    self.color = attacks[self.attack].color
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    self.collider:setCollisionClass("Projectile")
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    self.target = nil

    if self.passives.shield then
        self.orbit_distance = random(32, 64)
        self.orbit_speed = random(-6, 6)
        self.orbit_offset = random(0, 2 * math.pi)

        self.invisible = true
        self.timer:after(0.05, function () self.invisible = false end)
        self.timer:after(6  * self.multipliers.duration_multiplier, function () self:die() end)
    end

    if self.attack == "Blast" then
        self.damage = 75
        self.color = table.random(negative_colors)
        if not self.passives.shield then
            self.timer:tween(random(0.4, 0.6) * self.multipliers.duration_multiplier, self, {v = 0}, "linear", function() self:die() end)
        end
    end

    if self.attack == "Homing" or self.attack == "Swarm" then
        self.timer:every(0.02, function ()
            self.area:addGameObject(
                "TrailParticle",
                self.x - self.s * math.cos(self.r),
                self.y - self.s * math.sin(self.r),
                {parent = self, d = random(0.1, 0.15), r = random(1, 3), color = skill_point_color}
            )
        end)
    end

    if self.passives.degree_change_90 then
        self.timer:after(0.2 / self.multipliers.angle_change_frequency, function ()
            self.ninety_degree_direction = table.random({-1, 1})
            self.r = self.r + self.ninety_degree_direction * math.pi * 0.5
            self.timer:every("ninety_degree_first", 0.25 / self.multipliers.angle_change_frequency, function ()
                self.r = self.r - self.ninety_degree_direction * math.pi * 0.5
                self.timer:after("ninety_degree_second", 0.1 / self.multipliers.angle_change_frequency, function ()
                    self.r = self.r - self.ninety_degree_direction * math.pi * 0.5
                    self.ninety_degree_direction = -1 * self.ninety_degree_direction
                end)
            end)
        end)
    elseif self.passives.random_degree_change then
        self.timer:every(0.25 / self.multipliers.angle_change_frequency, function ()
            self.r = self.r + random(-math.pi * 0.5, math.pi * 0.5)
        end)
    elseif self.passives.wavy then
        local direction = table.random({-1, 1})
        self.timer:tween(0.25, self, {r = self.r + direction * (math.pi / 8) * self.multipliers.wavy_amplitude}, "linear", function ()
            self.timer:tween(0.25, self, {r = self.r - direction * (math.pi / 4) * self.multipliers.wavy_amplitude}, "linear")
        end)
        self.timer:every(0.75, function ()
            local angle = math.pi * 0.25 * self.multipliers.wavy_amplitude * direction
            self.timer:tween(0.25, self, {r = self.r + angle}, "linear", function ()
                self.timer:tween(0.5, self, {r = self.r - angle}, "linear")
            end)
        end)
    
        -- use "self.multipliers.duration_multiplier" here too ?
        elseif self.passives.slow_to_fast then
            local initial_v = self.v
            self.timer:tween("slow_fast_first", 0.15, self, {v = initial_v / (2 * self.multipliers.deceleration_multiplier)}, "in-out-cubic", function ()
                self.timer:tween("slow_fast_second", 0.3, self, {v = initial_v * 2 * self.multipliers.acceleration_multiplier}, "in-out-cubic")
            end)
        elseif self.passives.fast_to_slow then
            local initial_v = self.v
            self.timer:tween("fast_slow_first", 0.15, self, {v = initial_v * 2 * self.multipliers.acceleration_multiplier}, "in-out-cubic", function ()
                self.timer:tween("fast_slow_second", 0.3, self, {v = initial_v / (2 * self.multipliers.deceleration_multiplier)}, "in-out-cubic")
            end)
    end


    self.previous_x, self.previous_y = self.collider:getPosition()
end



function Projectile:update(dt)
    Projectile.super.update(self, dt)

    

    if self.attack == "Homing" or self.attack == "Swarm" then
        --aquire target
        if not self.target then
            local targets = self.area:getAllGameObjectsThat(function (e)
                return e.group == "enemy" and distanceSquared(e.x, e.y, self.x, self.y) < 16000
            end)
            self.target = table.remove(targets, love.math.random(1, #targets))
        end

        if self.target and self.target.dead then self.target = nil end

        --move towards target
        if self.target then
            local heading = Vector(self.collider:getLinearVelocity()):normalized()
            local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
            local to_target_heading = Vector(math.cos(angle), math.sin(angle)):normalized()
            local final_heading = (heading + 0.1 * to_target_heading):normalized()
            self.collider:setLinearVelocity(self.v * final_heading.x, self.v * final_heading.y)
            self.r = angle--math.atan2(self.v * final_heading.y, self.v * final_heading.x)
        else
            self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
        end
    else 
        self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    end


    if self.passives.shield then
        local player = current_room.player
        if player then
            self.collider:setPosition(
                player.x + self.orbit_distance * math.cos(time * self.orbit_speed + self.orbit_offset),
                player.y + self.orbit_distance * math.sin(time * self.orbit_speed + self.orbit_offset)
            )

            local x, y = self.collider:getPosition()
            local dx, dy = x - self.previous_x, y - self.previous_y
            self.r = math.atan2(dy, dx)
        end
    end

    if self:checkBounds() then
        self:die()
    end

    if self.collider:enter("Enemy") then
        local col_info = self.collider:getEnterCollisionData("Enemy")
        local object = col_info.collider:getObject()
        object:hit(self.damage)
        if object.dead then current_room.player:onKill() end
        if self.attack ~= "Sniper" then
            self:die()
        end
    end

    self.previous_x, self.previous_y = self.collider:getPosition()
end

function Projectile:draw()
    if self.invisible then return end
    pushRotate(self.x, self.y, self.r)--Vector(self.collider:getLinearVelocity()):angleTo()

    if self.attack == "Homing" or self.attack == "Swarm" then
        love.graphics.setColor(self.color)
        love.graphics.polygon("fill", self.x - 2.0 * self.s, self.y, self.x, self.y + 1.5 * self.s, self.x, self.y - 1.5 * self.s)

        love.graphics.setColor(default_color)
        love.graphics.polygon("fill", self.x + 2.0 *self.s, self.y, self.x, self.y - 1.5 * self.s, self.x, self.y + 1.5 * self.s)
    else
        love.graphics.setLineWidth(self.s - self.s * 0.25)
        
        love.graphics.setColor(self.color)
        love.graphics.line(self.x, self.y, self.x + 2 * self.s, self.y)
        
        love.graphics.setColor(default_color)
        love.graphics.line(self.x - 2 * self.s, self.y, self.x, self.y)

        love.graphics.setLineWidth(1)
    end
    love.graphics.pop()
end

function Projectile:destroy()
    Projectile.super.destroy(self)
end

function Projectile:die()
    self.dead = true
    self.area:addGameObject("ProjectileDeathEffect", self.x, self.y, {color = hp_color, w = 3 * self.s})
end