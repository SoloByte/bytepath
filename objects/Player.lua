Player = GameObject:extend()



function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)

    self.w, self.h = 12, 12
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)
    self.collider:setCollisionClass("Player")
    self.r = -math.pi * 0.5 --starting angle (up)
    self.rv = 1.66 * math.pi --angle change on player input
    self.vel = 0
    self.base_max_vel = 100
    self.max_vel = self.base_max_vel
    self.acc = 100

    self.max_hp = 100
    self.hp = self.max_hp

    self.max_ammo = 100
    self.ammo = self.max_ammo

    self.max_boost = 100
    self.boost = self.max_boost
    self.can_boost = true
    self.boost_timer = 0
    self.boost_cooldown = 2


    self.ship_variants = {"Fighter", "Assault", "Hour", "Sonic", "Sentinel", "Bithunter"}
    self.ship = self.ship_variants[1]
    self.polygons = {}

    self.boosting = false
    self.trail_color = skill_point_color
    
    self:changeShip(self.ship)

    self.timer:every(0.24, function () self:shoot() end)
    self.timer:every(5, function () self:tick() end)
    input:bind("f3", function () self:die() end)
    input:bind("f4", function ()
        local index = math.random(#self.ship_variants)
        local ship = self.ship_variants[index]
        self:changeShip(ship)
    end)
end


function Player:shoot()
    local d = self.w * 1.2
    local cos = math.cos(self.r)
    local sin = math.sin(self.r)
    self.area:addGameObject("ShootEffect", self.x + d * cos, self.y + d * sin, {player = self, d = d})

    d = d * 1.5
    self.area:addGameObject("Projectile", self.x + d * cos, self.y + d * sin, {r = self.r})

end

function Player:tick()
    self.area:addGameObject("TickEffect", self.x, self.y, {parent = self})
end

function Player:addAmmo(amount)
    self.ammo = math.min(self.ammo + amount, self.max_ammo)
end

function Player:update(dt)
    Player.super.update(self, dt)


    if self.collider:enter("Collectable") then
        local col_info = self.collider:getEnterCollisionData("Collectable")
        local object = col_info.collider:getObject()
        if object:is(Ammo) then
            object:die()
            self:addAmmo(5)
        end
    end
    self.boost = math.min(self.boost + 10 * dt, self.max_boost)
    if not self.can_boost then
        self.boost_timer = self.boost_timer + dt
        if self.boost_timer > self.boost_cooldown then
            self.can_boost = true
            self.boost_timer = 0
        end
    end


    self.boosting = false
    self.max_vel = self.base_max_vel
    if input:down("up") and self.boost > 1 and self.can_boost then 
        self.boosting = true
        self.max_vel = self.base_max_vel * 1.5 
    end
    if input:down("down") and self.boost > 1 and self.can_boost then 
        self.boosting = true
        self.max_vel = self.base_max_vel * 0.5 
    end

    if self.boosting then
        self.boost = self.boost - 50 * dt
        if self.boost <= 1 then
            self.can_boost = false
            self.boost_timer = 0
            self.boosting = false
        end
    end

    self.trail_color = skill_point_color
    if self.boosting then self.trail_color = boost_color end


    if input:down("left") then self.r = self.r - self.rv * dt end
    if input:down("right") then self.r = self.r + self.rv * dt end

    self.vel = math.min(self.vel + self.acc * dt, self.max_vel)
    self.collider:setLinearVelocity(self.vel * math.cos(self.r), self.vel * math.sin(self.r))

    if self:checkBounds() then
        self:die()
    end

end



function Player:draw()
    pushRotate(self.x, self.y, self.r)
    love.graphics.setColor(default_color)
    local polycount = #self.polygons
    for i = 1, polycount do
        local polygon = self.polygons[i]
        local points = fn.map(polygon, function (v, k)
            if k % 2 == 1 then --x component
                return self.x + v + random(-1, 1)
            else --y component
                return self.y + v + random(-1, 1)
            end
        end)
        love.graphics.polygon("line", points)
    end
    love.graphics.pop()
end




function Player:destroy()
    Player.super.destroy(self)
end

function Player:die()
    self.dead = true

    for i = 1, love.math.random(8, 12) do
        self.area:addGameObject("ExplodeParticle", self.x, self.y)
    end

    flash(6)
    camera:shake(6, 60, 0.4)
    slow(0.15, 1.0)

end



function Player:changeShip(new_ship)
    self.ship = new_ship
    self:createShip(new_ship)
    self:createTrail(new_ship)
end

function Player:createShip(ship)
    self.polygons = {}
    if self.ship == self.ship_variants[1] then
        self.polygons[1] = { --center
            self.w, 0, --1
            self.w / 2, -self.w / 2, --2
            -self.w / 2, -self.w / 2, --3
            -self.w, 0, --4
            -self.w / 2, self.w / 2, --5
            self.w / 2, self.w / 2, --6
        }
        self.polygons[2] = { --top wing
            self.w / 2, -self.w / 2, --1
            0, -self.w, --2
            -self.w - self.w / 2, -self.w, --3
            -self.w * 0.75, -self.w * 0.25, --4
            -self.w / 2, -self.w / 2, --5
        }
        self.polygons[3] = { --bottom wing
            self.w / 2, self.w / 2, --1
            0, self.w, --2
            -self.w - self.w / 2, self.w, --3
            -self.w * 0.75, self.w * 0.25, --4
            -self.w / 2, self.w / 2, --5
        }
    elseif self.ship == self.ship_variants[2] then
        self.polygons[1] = { --wing (big part)
            0, 0, --1
            self.w * 0.5, -self.w * 0.75, --2
            self.w * 1.5, -self.w * 0.5, --3
            self.w * 0.5, -self.w * 1.5, --4
            -self.w, 0, --5
            self.w * 0.5, self.w * 1.5, --6
            self.w * 1.5, self.w * 0.5, --7
            self.w * 0.5, self.w * 0.75, --8
        }
        self.polygons[2] = { -- cockpit (small part)
            0, 0, --1
            self.w * 0.5, -self.w * 0.75, --2
            self.w, 0, --3
            self.w * 0.5, self.w * 0.75, --4
        }
    elseif self.ship == self.ship_variants[3] then
        self.polygons[1] = { --center
            self.w, 0, --1
            0, -self.w * 0.75, --2
            -self.w, 0, --3
            0, self.w * 0.75, --4
        }
        self.polygons[2] = { --top triangle
            self.w * 0.7071, -self.w * 0.7071, --1
            self.w * 1.5, -self.w * 1.5, --2
            -self.w * 1.5, -self.w * 1.5, --3
            -self.w * 0.7071, -self.w * 0.7071, --4
            0, -self.w, --5
        }
        self.polygons[3] = { --bottom triangle
            self.w * 0.7071, self.w * 0.7071, --1
            0, self.w, --2
            -self.w * 0.7071, self.w * 0.7071, --3
            -self.w * 1.5, self.w * 1.5, --4
            self.w * 1.5, self.w * 1.5, --5
        }
    elseif self.ship == self.ship_variants[4] then
        self.polygons[1] = {--center
            0, -self.w * 0.25, --1
            self.w, 0, --2
            0, self.w * 0.25, --3

        }
        self.polygons[2] = {--top wing
            self.w, -self.w * 0.25, --1
            -self.w * 0.5, -self.w, --2
            -self.w, -self.w * 0.75, --3
        }
        self.polygons[3] = {--bottom wing
            self.w, self.w * 0.25, --1
            -self.w, self.w * 0.75, --2
            -self.w * 0.5, self.w, --3
        }
    elseif self.ship == self.ship_variants[5] then
        self.polygons[1] = {
            self.w, 0, --1
            -self.w * 0.5, -self.w, --2
            -self.w, -self.w * 0.5, --3
            -self.w, self.w * 0.5, --4
            -self.w * 0.5, self.w, --5
        }
    elseif self.ship == self.ship_variants[6] then
        self.polygons[1] = {
            self.w, 0, --1
            self.w * 0.5, -self.w * 0.5, --2
            -self.w, -self.w * 0.5, --3
            -self.w, self.w * 0.5, --4
            self.w * 0.5, self.w * 0.5, --5
        }
    end
end

function Player:createTrail(ship)
    if self.ship == self.ship_variants[1] then
    
        self.timer:every("playertrail", 0.025, function ()
            self.area:addGameObject(
                "TrailParticle",
                self.x - 0.9 * self.w * math.cos(self.r) + 0.2 * self.w * math.cos(self.r - math.pi / 2),
                self.y - 0.9 * self.w * math.sin(self.r) + 0.2 * self.w * math.sin(self.r - math.pi / 2),
                {parent = self, d = random(0.15, 0.25), r = random(4, 6), color = self.trail_color}
            )

            self.area:addGameObject(
                "TrailParticle",
                self.x - 0.9 * self.w * math.cos(self.r) + 0.2 * self.w * math.cos(self.r + math.pi / 2),
                self.y - 0.9 * self.w * math.sin(self.r) + 0.2 * self.w * math.sin(self.r + math.pi / 2),
                {parent = self, d = random(0.15, 0.25), r = random(4, 6), color = self.trail_color}
            )
        end)
    
    elseif self.ship == self.ship_variants[2] then
    
        self.timer:every("playertrail", 0.02, function ()
            self.area:addGameObject(
                "TrailParticle",
                self.x - 0.9 * self.w * math.cos(self.r),
                self.y - 0.9 * self.w * math.sin(self.r),
                {parent = self, d = random(0.1, 0.2), r = random(5, 8), color = self.trail_color}
            )
        end)
    
    elseif self.ship == self.ship_variants[3] then
    
        self.timer:every("playertrail", 0.025, function ()
            self.area:addGameObject(
                "TrailParticle",
                self.x - 1.1 * self.w * math.cos(self.r) + 1.1 * self.w * math.cos(self.r - math.pi / 2),
                self.y - 1.1 * self.w * math.sin(self.r) + 1.1 * self.w * math.sin(self.r - math.pi / 2),
                {parent = self, d = random(0.2, 0.3), r = random(2, 4), color = self.trail_color}
            )

            self.area:addGameObject(
                "TrailParticle",
                self.x - 1.1 * self.w * math.cos(self.r) + 1.1 * self.w * math.cos(self.r + math.pi / 2),
                self.y - 1.1 * self.w * math.sin(self.r) + 1.1 * self.w * math.sin(self.r + math.pi / 2),
                {parent = self, d = random(0.2, 0.3), r = random(2, 4), color = self.trail_color}
            )
        end)
    
    elseif self.ship == self.ship_variants[4] then

        self.timer:every("playertrail", 0.02, function ()
            self.area:addGameObject(
                "TrailParticle",
                self.x - 0.9 * self.w * math.cos(self.r),
                self.y - 0.9 * self.w * math.sin(self.r),
                {parent = self, d = random(0.05, 0.15), r = random(6, 9), color = self.trail_color}
            )
        end)
    
    elseif self.ship == self.ship_variants[5] then
    
        self.timer:every("playertrail", 0.02, function ()
            self.area:addGameObject(
                "TrailParticle",
                self.x - 0.9 * self.w * math.cos(self.r),
                self.y - 0.9 * self.w * math.sin(self.r),
                {parent = self, d = random(0.15, 0.3), r = random(3, 5), color = self.trail_color}
            )
        end)
    
    elseif self.ship == self.ship_variants[6] then
    
        self.timer:every("playertrail", 0.02, function ()
            self.area:addGameObject(
                "TrailParticle",
                self.x - 0.9 * self.w * math.cos(self.r),
                self.y - 0.9 * self.w * math.sin(self.r),
                {parent = self, d = random(0.2, 0.25), r = random(2, 3), color = self.trail_color}
            )
        end)

    end
end

