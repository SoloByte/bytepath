Player = GameObject:extend()


SP = 0


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

    self.invincible = false
    self.invisible = false

    self.max_boost = 100
    self.boost = self.max_boost
    self.can_boost = true
    self.boost_timer = 0
    self.boost_cooldown = 2

    self.cycle_timer = 0
    self.cycle_cooldown = 5


    self.inside_haste_area = false

    --multipliers
    self.hp_multiplier = 1
    self.ammo_multiplier = 1
    self.boost_multiplier = 1
    self.attack_speed_multiplier = 1
    self.pre_haste_attack_speed_multiplier = 1

    --flats
    self.flat_hp = 0
    self.flat_ammo = 0
    self.flat_boost = 0

    --chances
    self.launch_homing_projectile_on_ammo_pickup_chance = 0
    self.regain_hp_on_ammo_pickup_chance = 0
    self.regain_hp_on_sp_pickup_chance = 0
    self.spawn_haste_area_on_hp_pickup_chance = 0
    self.spawn_haste_area_on_sp_pickup_chance = 0

    self.ammo_gain = 0

    self.ship_variants = {"Fighter", "Assault", "Hour", "Sonic", "Sentinel", "Bithunter"}
    self.ship = self.ship_variants[1]
    self.polygons = {}

    self.boosting = false
    self.trail_color = skill_point_color
    
    self:changeShip(self.ship)

    input:bind("f3", function () self:die() end)
    input:bind("f4", function ()
        local index = math.random(#self.ship_variants)
        local ship = self.ship_variants[index]
        self:changeShip(ship)
    end)

    self:setAttack("Neutral")


    --treeToPlayer(self)
    self:setStats()
    self:generateChances()
end

function Player:setStats()
    --hp
    self.max_hp = (self.max_hp + self.flat_hp) * self.hp_multiplier
    self.hp = self.max_hp

    --ammo
    self.max_ammo = (self.max_ammo + self.flat_ammo) * self.ammo_multiplier
    self.ammo = self.max_ammo

    --boost
    self.max_boost = (self.max_boost + self.flat_boost) * self.boost_multiplier
    self.boost = self.max_boost
end

function Player:generateChances()
    self.chances = {}
    for key, value in pairs(self) do
        if key:find("_chance") and type(value) == "number" then
            self.chances[key] = chanceList({true, math.ceil(value)}, {false, 100 - math.ceil(value)})
        end
    end
end

function Player:shoot()
    local d = self.w * 1.2

    self.area:addGameObject("ShootEffect", 
    self.x + d * math.cos(self.r), 
    self.y + d * math.sin(self.r), 
    {player = self, d = d})

    d = d * 1.5
    if self.attack == "Neutral" then
        self.area:addGameObject("Projectile", 
        self.x + d * math.cos(self.r), 
        self.y + d * math.sin(self.r), 
        {r = self.r, attack = self.attack})

    elseif self.attack == "Homing" then
        self.area:addGameObject("Projectile", 
        self.x + d * math.cos(self.r), 
        self.y + d * math.sin(self.r), 
        {r = self.r, attack = self.attack})

    elseif self.attack == "Double" then
        self.area:addGameObject('Projectile', 
    	self.x + d*math.cos(self.r + math.pi/12), 
    	self.y + d*math.sin(self.r + math.pi/12), 
    	{r = self.r + math.pi/12, attack = self.attack})
        
        self.area:addGameObject('Projectile', 
    	self.x + d*math.cos(self.r - math.pi/12),
    	self.y + d*math.sin(self.r - math.pi/12), 
    	{r = self.r - math.pi/12, attack = self.attack})
    
    elseif self.attack == "Triple" then
        self.area:addGameObject('Projectile', 
    	self.x + d*math.cos(self.r + math.pi/12), 
    	self.y + d*math.sin(self.r + math.pi/12), 
    	{r = self.r + math.pi/12, attack = self.attack})
        
        self.area:addGameObject("Projectile", 
        self.x + d * math.cos(self.r), 
        self.y + d * math.sin(self.r), 
        {r = self.r, attack = self.attack})

        self.area:addGameObject('Projectile', 
    	self.x + d*math.cos(self.r - math.pi/12),
    	self.y + d*math.sin(self.r - math.pi/12), 
    	{r = self.r - math.pi/12, attack = self.attack})


    elseif self.attack == "Spread" then
        local max_angle = math.pi / 8
        local rand_angle = random(-max_angle, max_angle)
        local accuracy = self.r + rand_angle

        self.area:addGameObject("Projectile", 
        self.x + d * math.cos(accuracy), 
        self.y + d * math.sin(accuracy), 
        {r = accuracy, attack = self.attack})

    elseif self.attack == "Rapid" then
        self.area:addGameObject("Projectile", 
        self.x + d * math.cos(self.r), 
        self.y + d * math.sin(self.r), 
        {r = self.r, attack = self.attack})

    elseif self.attack == "Back" then
        self.area:addGameObject("Projectile", 
        self.x + d * math.cos(self.r), 
        self.y + d * math.sin(self.r), 
        {r = self.r, attack = self.attack})

        self.area:addGameObject("Projectile", 
        self.x + d * math.cos(self.r + math.pi), 
        self.y + d * math.sin(self.r + math.pi), 
        {r = self.r + math.pi, attack = self.attack})

    elseif self.attack == "Side" then
        self.area:addGameObject("Projectile", 
        self.x + d * math.cos(self.r), 
        self.y + d * math.sin(self.r), 
        {r = self.r, attack = self.attack})

        self.area:addGameObject("Projectile", 
        self.x + d * math.cos(self.r + math.pi * 0.5), 
        self.y + d * math.sin(self.r + math.pi * 0.5), 
        {r = self.r + math.pi * 0.5, attack = self.attack})

        self.area:addGameObject("Projectile", 
        self.x + d * math.cos(self.r - math.pi * 0.5), 
        self.y + d * math.sin(self.r - math.pi * 0.5), 
        {r = self.r - math.pi * 0.5, attack = self.attack})
    
    end

    self:addAmmo(-attacks[self.attack].ammo)
end

        

function Player:cycle()
    self.area:addGameObject("TickEffect", self.x, self.y, {parent = self})
end

function Player:addAmmo(amount)
    self.ammo = self.ammo + amount
    if self.ammo > self.max_ammo then
        self.ammo = self.max_ammo
    elseif self.ammo <= 0 then
        self:setAttack("Neutral")
    end
    --self.ammo = clamp(self.ammo + amount, 0, self.max_ammo)
end

function Player:addBoost(amount)
    self.boost = clamp(self.boost + amount, 0, self.max_boost)
end

function Player:addHP(amount)
    self.hp = clamp(self.hp + amount, 0, self.max_hp)

    if self.hp <= 0 then
        self:die()
    end
end

function Player:hit(damage, pos_x, pos_y)
    if self.invincible then return end
    local dmg = damage or 10
    local x = pos_x or self.x
    local y = pos_y or self.y

    if dmg < self.hp then 
        self:spawnParticles(4, 8, x, y) 

        if dmg >= 30 then
            self.invincible = true
            self.timer:after(2, function () self.invincible = false end)
            self.timer:every(0.04, function ()
                self.invisible = not self.invisible
                if not self.invincible then self.invisible = false end
                return self.invincible 
            end)

            flash(3)
            camera:shake(6, 60, 0.2)
            slow(0.25, 0.5)
        else
            flash(2)
            camera:shake(6, 60, 0.1)
            slow(0.75, 0.25)
        end
    end
    self:addHP(-dmg)
end

function Player:update(dt)
    Player.super.update(self, dt)


    if self.collider:enter("Collectable") then
        local col_info = self.collider:getEnterCollisionData("Collectable")
        local object = col_info.collider:getObject()
        if object:is(Ammo) then
            object:die()
            self:addAmmo(5 + self.ammo_gain)
            self:onAmmoPickup()
            current_room:increaseScore(SCORE_POINTS.AMMO)
        elseif object:is(Boost) then
            object:die()
            self:addBoost(25)
            current_room:increaseScore(SCORE_POINTS.BOOST)
        elseif object:is(HP) then
            object:die()
            self:addHP(25)
            self:onHPPickup()
            current_room:increaseScore(SCORE_POINTS.HP)
        elseif object:is(Skillpoint) then
            object:die()
            SP = SP + 1
            self:onSkillpointPickup()
            current_room:increaseScore(SCORE_POINTS.SKILLPOINT)
        elseif object:is(Attack) then
            object:die()
            self:setAttack(object.attack)
            current_room:increaseScore(SCORE_POINTS.ATTACK)
        end
    elseif self.collider:enter("Enemy") then
        local col_info = self.collider:getEnterCollisionData("Enemy")
        if col_info then
            local object = col_info.collider:getObject()
            if object then
                if object:is(Rock) then
                    self:hit(30)
                elseif object:is(Shooter) then
                    self:hit(20)
                end
            end
        end
    end

    self.cycle_timer = self.cycle_timer + dt
    if self.cycle_timer >= self.cycle_cooldown then
        self.cycle_timer = 0
        self:cycle()
    end

    self.shoot_timer = self.shoot_timer + dt
    if self.shoot_timer > self.shoot_cooldown * self.attack_speed_multiplier then
        self.shoot_timer = 0
        self:shoot()
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
    if self.invisible then return end

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

    self:spawnParticles()
    --for i = 1, love.math.random(8, 12) do
    --    self.area:addGameObject("ExplodeParticle", self.x, self.y)
    --end

    flash(6)
    camera:shake(6, 60, 0.4)
    slow(0.15, 1.0)
    current_room:finish()
end

function Player:spawnParticles(min_amount, max_amount, pos_x, pos_y)
    local min = min_amount or 8
    local max = max_amount or 12
    local x = pos_x or self.x
    local y = pos_y or self.y
    for i = 1, love.math.random(min, max) do
        self.area:addGameObject("ExplodeParticle", x, y)
    end
end

function Player:setAttack(attack)
    self.attack = attack
    self.shoot_cooldown = attacks[attack].cooldown
    self.ammo = self.max_ammo
    self.shoot_timer = 0
end




function Player:onAmmoPickup()
    if self.chances.launch_homing_projectile_on_ammo_pickup_chance:next() then
        local d = self.w * 1.2
        d = d * 1.5 
        self.area:addGameObject("Projectile", 
        self.x + d * math.cos(self.r), 
        self.y + d * math.sin(self.r), 
        {r = self.r, attack = "Homing"})
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
    end

    if self.chances.regain_hp_on_ammo_pickup_chance:next() then
        self:addHP(25)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Regain!'})
    end
end

function Player:onSkillpointPickup()
    if self.chances.regain_hp_on_sp_pickup_chance:next() then
        self:addHP(25)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Regain!'})
    end

    if self.chances.spawn_haste_area_on_sp_pickup_chance:next() then
        self.area:addGameObject("HasteArea", self.x, self.y)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!'})
    end
end

function Player:onHPPickup()
    if self.chances.spawn_haste_area_on_hp_pickup_chance:next() then
        self.area:addGameObject("HasteArea", self.x, self.y)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!'})
    end
end


function Player:enterHasteArea()
    if self.inside_haste_area then return end
    self.inside_haste_area = true
    self.pre_haste_attack_speed_multiplier = self.attack_speed_multiplier
    self.attack_speed_multiplier = self.attack_speed_multiplier * 0.5
end

function Player:exitHasteArea()
    if not self.inside_haste_area then return end
    self.inside_haste_area = false
    self.attack_speed_multiplier = self.pre_haste_attack_speed_multiplier
    self.pre_haste_attack_speed_multiplier = nil
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

