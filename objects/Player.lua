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
    self.enemy_spawn_rate_multiplier = 1

    self.attack_speed_multiplier = Stat(1)
    self.attack_speed_boosting = false

    self.movement_speed_multiplier = Stat(1)
    self.movement_speed_boosting = false

    self.projectile_speed_mutliplier = Stat(1)
    self.projectile_speed_boosting = false
    self.projectile_speed_inhibiting = false

    self.cycle_speed_multiplayer = Stat(1)
    self.increased_cycle_speed_while_boosting = false

    self.luck_multiplier = 1
    self.hp_spawn_chance_multiplier = 1.0
    self.sp_spawn_chance_multiplier = 1.0
    self.boost_spawn_chance_multiplier = 1.0
    self.resource_spawn_rate_multiplier = 1.0
    self.attack_spawn_rate_multiplier = 1.0

    self.turn_rate_multiplier = 1.0
    self.boost_effectiveness_multiplier = 1.0
    self.projectile_size_mutliplier = 1.0
    self.boost_recharge_rate_mutliplier = 1.0
    self.invulnerability_time_multiplier = 1.0
    self.ammo_consumption_multiplier = 1.0
    self.size_multiplier = 1.0
    self.stat_boost_duration_multiplier = 1.0
    self.angle_change_frequency_multiplier = 1.0
    self.projectile_waviness_multiplier = 1.0
    self.projectile_acceleration_multiplier = 1.0
    self.projectile_deceleration_multiplier = 1.0
    self.projectile_duration_multiplier = 1.0
    self.area_multiplier = 1.0
    self.laser_width_multiplier = 1.0


    self.attack_spawn_chance_multipliers = {
        ["Neutral"]     = 1,
        ["Double"]      = 1,
        ["Triple"]      = 1,
        ["Spread"]      = 1,
        ["Rapid"]       = 1,
        ["Back"]        = 1,
        ["Side"]        = 1,
        ["Homing"]      = 1,
        ["Sniper"]      = 1,
        ["Swarm"]       = 10,
        ["Blast"]       = 1,
        ["Spin"]        = 1,
        ["Flame"]       = 1,
        ["Bounce"]      = 1,
        ["2Split"]      = 1,
        ["3Split"]      = 1,
        ["4Split"]      = 1,
        ["Lightning"]   = 1,
        ["Explode"]     = 1,
        ["Laser"]       = 1 
    }

    self.start_attack_chances = {
        ["Neutral"]     = true,
        ["Double"]      = false,
        ["Triple"]      = false,
        ["Spread"]      = false,
        ["Rapid"]       = false,
        ["Back"]        = false,
        ["Side"]        = false,
        ["Homing"]      = false,
        ["Sniper"]      = false,
        ["Swarm"]       = false,
        ["Blast"]       = false,
        ["Spin"]        = false,
        ["Flame"]       = false,
        ["Bounce"]      = false,
        ["2Split"]      = false,
        ["3Split"]      = false,
        ["4Split"]      = false,
        ["Lightning"]   = false,
        ["Explode"]     = false,
        ["Laser"]       = false 
    }

    --flats
    self.flat_hp = 0
    self.flat_ammo = 0
    self.flat_boost = 0
    self.additional_bounce_projectiles = 0
    

    --chances
    self.launch_homing_projectile_on_ammo_pickup_chance = 0
    self.regain_hp_on_ammo_pickup_chance = 0
    self.regain_hp_on_sp_pickup_chance = 0
    self.spawn_haste_area_on_hp_pickup_chance = 0
    self.spawn_haste_area_on_sp_pickup_chance = 0
    self.spawn_sp_on_cycle_chance = 0
    self.barrage_on_kill_chance = 0

    self.spawn_hp_on_cycle_chance = 0
    self.regain_hp_on_cycle_chance = 0 --25
    self.regain_full_ammo_on_cycle_chance = 0
    self.change_attack_on_cycle_chance = 0
    self.spawn_haste_area_on_cycle_chance = 0
    self.barrage_on_cycle_chance = 0
    self.launch_homing_projectile_on_cycle_chance = 0
    self.regain_ammo_on_kill_chance = 0 --20
    self.launch_homing_projectile_on_kill_chance = 0
    self.regain_boost_on_kill_chance = 0 --40
    self.spawn_boost_on_kill_chance = 0
    self.gain_attack_speed_boost_on_kill_chance = 0
    self.gain_movement_speed_boost_on_cycle_chance = 0
    self.gain_projectile_speed_boost_on_cycle_chance = 0
    self.gain_projectile_speed_inhibit_on_cycle_chance = 0
    self.launch_homing_projectile_while_boosting_chance = 0
    self.attack_twice_chance = 0
    self.gain_double_sp_chance = 0
    self.split_projectiles_split_chance = 0 --maybe has to be changed so that split children projectiles can never spawn new split children projectiles

    self.spawn_double_hp_chance = 0
    self.spawn_double_sp_chance = 0
    self.drop_double_ammo_chance = 0

    self.shield_projectile_chance = 0

    self.increased_luck_while_boosting = false
    self.luck_boosting = false
    self.invulnerability_while_boosting = false

    --projectile passives
    self.projectile_90_degree_change = false
    self.projectile_random_degree_change = false
    self.projectile_wavy = false
    self.slow_to_fast = false
    self.fast_to_slow = false
    self.additional_lightning_bolt = false
    self.increased_lightning_angle = false
    self.fixed_spin_attack_direction  = false


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

    local start_attacks = {}
    for key, value in pairs(self.start_attack_chances) do
        if value then
            table.insert(start_attacks, key)
        end
    end

    local start_attack = table.random(start_attacks)

    self:setAttack(start_attack)


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
            self.chances[key] = chanceList(
                {true, math.ceil(value * self.luck_multiplier)}, 
                {false, 100 - math.ceil(value * self.luck_multiplier)})
        end
    end
end

function Player:shoot()
    local mods = {
        shield = self.chances.shield_projectile_chance:next(),
        bounce = 0
    }
    
    local d = self.w * 1.2

    d = d * 1.5
    if self.attack == "Neutral" then
        self:spawnProjectile(self.attack, self.r, d, mods)

    elseif self.attack == "Lightning" then
        local x1, y1 = self.x + d * math.cos(self.r), self.y + d * math.sin(self.r)
        local cx, cy
        if self.increased_lightning_angle then
            cx, cy = self.x, self.y
        else
            cx, cy = x1 + 24 * math.cos(self.r), y1 + 24 * math.sin(self.r)
        end
        --local closest_enemy = self.area:getGameObjectsInCircle(cx, cy, 64, "enemy", "closest")--nearby_enemies[1]
        local closest_enemies = self.area:getGameObjectsInCircle(cx, cy, 64 * self.area_multiplier, "enemy", "closest_all")

        local function spawnLightningBolt(enemy, ammo)
            if enemy then
                if ammo then
                    self:addAmmo(-attacks[self.attack].ammo * self.ammo_consumption_multiplier)
                end
                enemy:hit()
                local x2, y2 = enemy.x, enemy.y
                self.area:addGameObject("LightningLine", 0, 0, {x1 = x1, y1 = y1, x2 = x2, y2 = y2})
                for i = 1, love.math.random(4, 8) do 
                    self.area:addGameObject("ExplodeParticle", x1, y1, 
                  {color = table.random({default_color, boost_color})}) 
                end
                for i = 1, love.math.random(4, 8) do 
                        self.area:addGameObject("ExplodeParticle", x2, y2, 
                    {color = table.random({default_color, boost_color})}) 
                end
            end
        end

        spawnLightningBolt(closest_enemies[1], true)
        
        if self.additional_lightning_bolt then
            if closest_enemies[2] then
                self.timer:after(attacks["Lightning"].cooldown * 0.25, function ()
                    spawnLightningBolt(closest_enemies[2], false)
                end)
            end
        end


        return -- so the other shoot code isnt run
    elseif self.attack == "Laser" then
        local x1, y1 = self.x + d * math.cos(self.r), self.y + d * math.sin(self.r)
        self:addAmmo(-attacks[self.attack].ammo * self.ammo_consumption_multiplier)
        self.area:addGameObject("LaserLine", x1, y1, {r = self.r, color = attacks[self.attack].color, w_mp = self.laser_width_multiplier})
        return
    elseif self.attack == "Sniper" then
        self:spawnProjectile(self.attack, self.r, d, mods, 1.5)
        camera:shake(3, 40, 0.3)

    elseif self.attack == "Homing" then
        self:spawnProjectile(self.attack, self.r, d, mods)
    
    elseif self.attack == "Explode" then
        self:spawnProjectile(self.attack, self.r, d, mods)

    elseif self.attack == "2Split" then
        self:spawnProjectile(self.attack, self.r, d, mods)
    
    elseif self.attack == "3Split" then
        self:spawnProjectile(self.attack, self.r, d, mods)

    elseif self.attack == "4Split" then
        self:spawnProjectile(self.attack, self.r, d, mods)
    
    elseif self.attack == "Bounce" then
        mods.bounce = 4
        self:spawnProjectile(self.attack, self.r, d, mods)
    
    elseif self.attack == "Swarm" then
        for i = 1, 6 do
            local angle = self.r + random(-math.pi * 0.2, math.pi * 0.2)
            self:spawnProjectile(self.attack, angle, d, mods, random(0.9, 1.1))
        end

    elseif self.attack == "Double" then
        self:spawnProjectile(self.attack, self.r + math.pi/12, d, mods)
        self:spawnProjectile(self.attack, self.r - math.pi/12, d, mods)
    
    elseif self.attack == "Triple" then
        self:spawnProjectile(self.attack, self.r + math.pi/12, d, mods)
        self:spawnProjectile(self.attack, self.r, d, mods)
        self:spawnProjectile(self.attack, self.r - math.pi/12, d, mods)

    elseif self.attack == "Spread" then
        local max_angle = math.pi / 8
        local rand_angle = random(-max_angle, max_angle)
        local accuracy = self.r + rand_angle
        self:spawnProjectile(self.attack, accuracy, d, mods)

    elseif self.attack == "Flame" then
        local max_angle = math.pi / 12
        local rand_angle = random(-max_angle, max_angle)
        local accuracy = self.r + rand_angle
        self:spawnProjectile(self.attack, accuracy, d, mods)
    
    elseif self.attack == "Rapid" then
        self:spawnProjectile(self.attack, self.r, d, mods)
    
    elseif self.attack == "Spin" then
        self:spawnProjectile(self.attack, self.r, d, mods)
    
    elseif self.attack == "Back" then
        self:spawnProjectile(self.attack, self.r, d, mods)
        self:spawnProjectile(self.attack, self.r + math.pi, d, mods)

    elseif self.attack == "Side" then
        self:spawnProjectile(self.attack, self.r + math.pi * 0.5, d, mods)
        self:spawnProjectile(self.attack, self.r + math.pi/12, d, mods)
        self:spawnProjectile(self.attack, self.r - math.pi * 0.5, d, mods)

    elseif self.attack == "Blast" then
        for i = 1, 12 do
            local angle = self.r + random(-math.pi/6, math.pi/6)
            self:spawnProjectile(self.attack, angle, d, mods, random(2.5, 3)) -------
        end
        camera:shake(4, 60, 0.4)
    end

    self.area:addGameObject("ShootEffect", 
    self.x + d * math.cos(self.r), 
    self.y + d * math.sin(self.r), 
    {player = self, d = d})

    self:addAmmo(-attacks[self.attack].ammo * self.ammo_consumption_multiplier)
end

        

function Player:cycle()
    self.area:addGameObject("TickEffect", self.x, self.y, {parent = self})
    self:onCycle()
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
            self.timer:after(
                "invincible", 
                2 * self.invulnerability_time_multiplier, 
                function () self.invincible = false end)
            self.timer:every("invincible", 0.04, function ()
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
            if self.chances.gain_double_sp_chance:next() then
                SP = SP + 1
                self.area:addGameObject('InfoText', self.x, self.y, {text = 'Double SP!', color = skill_point_color})
            end
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

    if self.increased_cycle_speed_while_boosting then self.cycle_speed_multiplayer:increase(100) end
    self.cycle_timer = self.cycle_timer + dt
    if self.cycle_timer >= self.cycle_cooldown/self.cycle_speed_multiplayer.value then
        self.cycle_timer = 0
        self:cycle()
    end

    if self.projectile_speed_boosting then self.projectile_speed_mutliplier:increase(100) end
    if self.projectile_speed_inhibiting then self.projectile_speed_mutliplier:decrease(50) end
    self.projectile_speed_mutliplier:update(dt)

    if self.inside_haste_area then self.attack_speed_multiplier:increase(100) end
    if self.attack_speed_boosting then self.attack_speed_multiplier:increase(100) end
    self.attack_speed_multiplier:update(dt)
    self.shoot_timer = self.shoot_timer + dt
    if self.shoot_timer > self.shoot_cooldown/self.attack_speed_multiplier.value then
        self.shoot_timer = 0
        self:shoot()
        if self.chances.attack_twice_chance:next() then
            self:shoot()
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Double Attack!', color = ammo_color})
        end
    end

    self.boost = math.min(self.boost + 10 * dt * self.boost_recharge_rate_mutliplier, self.max_boost)
    if not self.can_boost then
        self.boost_timer = self.boost_timer + dt
        if self.boost_timer > self.boost_cooldown then
            self.can_boost = true
            self.boost_timer = 0
        end
    end


    self.boosting = false
    self.max_vel = self.base_max_vel


    if input:pressed("up") and self.boost > 1 and self.can_boost then self:onBoostStart() end
    if input:released("up") then self:onBoostEnd() end

    if input:pressed("down") and self.boost > 1 and self.can_boost then self:onBoostStart() end
    if input:released("down") then self:onBoostEnd() end
    
    if input:down("up") and self.boost > 1 and self.can_boost then 
        self.boosting = true
        self.max_vel = self.base_max_vel * 1.5 * self.boost_effectiveness_multiplier
    end
    if input:down("down") and self.boost > 1 and self.can_boost then 
        self.boosting = true
        self.max_vel = self.base_max_vel * 0.5 / self.boost_effectiveness_multiplier
    end

    if self.boosting then
        self.boost = self.boost - 50 * dt
        if self.boost <= 1 then
            self.can_boost = false
            self.boost_timer = 0
            self.boosting = false
            self:onBoostEnd()
        end
    end

    self.trail_color = skill_point_color
    if self.boosting then self.trail_color = boost_color end


    if input:down("left") then self.r = self.r - self.rv * dt * self.turn_rate_multiplier end
    if input:down("right") then self.r = self.r + self.rv * dt * self.turn_rate_multiplier end

    if self.movement_speed_boosting then self.movement_speed_multiplier:increase(50) end
    self.movement_speed_multiplier:update(dt)
    self.vel = math.min(self.vel + self.acc * dt, self.max_vel * self.movement_speed_multiplier.value)
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



function Player:onBoostStart()
    self.timer:every("boost_chances", 0.2, function ()
        if self.chances.launch_homing_projectile_while_boosting_chance:next() then
            local d = self.w * 1.2
            d = d * 1.5 
            self:spawnProjectile("Homing", self.r, d)
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
        end
    end)

    if self.invulnerability_while_boosting then self.invincible = true end

    if self.increased_luck_while_boosting then
        self.luck_boosting = true
        self.luck_multiplier = self.luck_multiplier * 2.0
        self:generateChances()
    end
end

function Player:onBoostEnd()
    self.timer:cancel("boost_chances")
    if self.invulnerability_while_boosting then self.invincible = false end

    if self.increased_luck_while_boosting and self.luck_boosting then
        self.luck_boosting = false
        self.luck_multiplier = self.luck_multiplier * 0.5
        self:generateChances()
    end
end


function Player:destroy()
    Player.super.destroy(self)
end

function Player:die()
    self.timer:cancel("barrage")
    self.timer:cancel("aspd_boost")
    self.timer:cancel("playertrail")
    self.timer:cancel("invincible")
    self.timer:cancel("mspd_boost")
    self.timer:cancel("pspd_boost")
    self.timer:cancel("pspd_inhibit")
    self.timer:cancel("boost_chances")

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




function Player:onKill()
    if self.chances.barrage_on_kill_chance:next() then
        local d = self.w * 1.2

        self.area:addGameObject("ShootEffect", 
        self.x + d * math.cos(self.r), 
        self.y + d * math.sin(self.r), 
        {player = self, d = d})

        d = d * 1.5
        self.timer:every("barrage", 0.05, function ()
            local angle = self.r + random(-math.pi/8, math.pi/8)
            self:spawnProjectile(self.attack, angle, d)
        end, 8)

        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Barrage!', color = ammo_color})
    end

    if self.chances.regain_ammo_on_kill_chance:next() then
        self:addAmmo(20)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Ammo Regain!', color = ammo_color})
    end

    
    if self.chances.launch_homing_projectile_on_kill_chance:next() then
        local d = self.w * 1.2
        d = d * 1.5 
        self:spawnProjectile("Homing", self.r, d)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
    end

    if self.chances.regain_boost_on_kill_chance:next() then
        self:addBoost(40)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Boost Regain!', color = boost_color})
    end

    if self.chances.spawn_boost_on_kill_chance:next() then
        self.area:addGameObject("Boost")
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Boost Spawn!', color = boost_color})
    end

    if self.chances.gain_attack_speed_boost_on_kill_chance:next() then
        self.attack_speed_boosting = true
        self.timer:after("aspd_boost", 4.0 * self.stat_boost_duration_multiplier, function () self.attack_speed_boosting = false end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'ASPD Boost!', color = ammo_color})
    end
end

function Player:onCycle()
    if self.chances.spawn_sp_on_cycle_chance:next() then
        self.area:addGameObject("Skillpoint")
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'SP SPawn!', color = skill_point_color})
    end

    if self.chances.spawn_hp_on_cycle_chance:next() then
        self.area:addGameObject("HP")
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Spawn!', color = hp_color})
    end

    if self.chances.regain_hp_on_cycle_chance:next() then
        self:addHP(25)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Regain HP!', color = hp_color})
    end

    if self.chances.regain_full_ammo_on_cycle_chance:next() then
        self:addAmmo(self.max_ammo)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Full Ammo!', color = ammo_color})
    end

    if self.chances.change_attack_on_cycle_chance:next() then
        self:setAttack(table.random(table.keys(attacks)))
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Random Attack!', color = skill_point_color})
    end

    if self.chances.spawn_haste_area_on_cycle_chance:next() then
        self:spawnHasteArea()
    end

    if self.chances.barrage_on_cycle_chance:next() then
        local d = self.w * 1.2

        self.area:addGameObject("ShootEffect", 
        self.x + d * math.cos(self.r), 
        self.y + d * math.sin(self.r), 
        {player = self, d = d})

        d = d * 1.5
        self.timer:every("barrage", 0.05, function ()
            local angle = self.r + random(-math.pi/8, math.pi/8)
            self:spawnProjectile(self.attack, angle, d)
        end, 8)

        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Barrage!', color = ammo_color})
    end

    if self.chances.launch_homing_projectile_on_cycle_chance:next() then
        local d = self.w * 1.2
        d = d * 1.5 
        self:spawnProjectile("Homing", self.r + math.pi * 0.5, d)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
    end

    if self.chances.gain_movement_speed_boost_on_cycle_chance:next() then
        self.movement_speed_boosting = true
        self.timer:after("mspd_boost", 4.0 * self.stat_boost_duration_multiplier, function ()
            self.movement_speed_boosting = false
        end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'MSPD Boost!', color = boost_color})
    end

    if self.chances.gain_projectile_speed_boost_on_cycle_chance:next() then
        self.projectile_speed_boosting = true
        self.timer:after("pspd_boost", 4.0 * self.stat_boost_duration_multiplier, function ()
            self.projectile_speed_boosting = false
        end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'PSPD Boost!', color = skill_point_color})
    end

    if self.chances.gain_projectile_speed_inhibit_on_cycle_chance:next() then
        self.projectile_speed_inhibiting = true
        self.timer:after("pspd_inhibit", 4.0 * self.stat_boost_duration_multiplier, function ()
            self.projectile_speed_inhibiting = false
        end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'PSPD Slow!', color = skill_point_color})
    end
end

function Player:onAmmoPickup()
    if self.chances.launch_homing_projectile_on_ammo_pickup_chance:next() then
        local d = self.w * 1.2
        d = d * 1.5 
        self:spawnProjectile("Homing", self.r, d)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
    end

    if self.chances.regain_hp_on_ammo_pickup_chance:next() then
        self:addHP(25)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Regain!', color = hp_color})
    end
end

function Player:onSkillpointPickup()
    if self.chances.regain_hp_on_sp_pickup_chance:next() then
        self:addHP(25)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Regain!', color = hp_color})
    end

    if self.chances.spawn_haste_area_on_sp_pickup_chance:next() then
        self:spawnHasteArea()
    end
end

function Player:onHPPickup()
    if self.chances.spawn_haste_area_on_hp_pickup_chance:next() then
        self:spawnHasteArea()
    end
end


function Player:spawnHasteArea()
    self.area:addGameObject("HasteArea", self.x, self.y, {dur_mp = self.stat_boost_duration_multiplier, area_mp = self.area_multiplier})
    self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!', color = ammo_color})
end

function Player:spawnProjectile(atk, rot, dis, mods, vel_mp)
    
    local split_children
    if self.attack == "2Split" or self.attack == "4Split" then
        if self.split_projectiles_split_chance > 0 then
            if self.chances.split_projectiles_split_chance:next() then
                split_children = self.chances.split_projectiles_split_chance
            end
        end
    end

    self.area:addGameObject("Projectile", 
    self.x + dis * math.cos(rot), 
    self.y + dis * math.sin(rot), 
    {
        r = rot or 0, 
        attack = atk, 
        v = 200 * (vel_mp or 1),
        modulate = attacks[atk].color,
        bounce = mods.bounce + self.additional_bounce_projectiles,
        split_children = split_children,
        multipliers = {
            speed = self.projectile_speed_mutliplier.value,
            size = self.projectile_size_mutliplier,
            angle_change_frequency = self.angle_change_frequency_multiplier,
            wavy_amplitude = self.projectile_waviness_multiplier,
            acceleration_multiplier = self.projectile_acceleration_multiplier,
            deceleration_multiplier = self.projectile_deceleration_multiplier,
            duration_multiplier = self.projectile_duration_multiplier,
            area_multiplier = self.area_multiplier
        },

        passives = {
            degree_change_90 = self.projectile_90_degree_change,
            random_degree_change = self.projectile_random_degree_change,
            wavy = self.projectile_wavy,
            slow_to_fast = self.slow_to_fast,
            fast_to_slow = self.fast_to_slow,
            shield = mods.shield or false,
            fixed_spin = self.fixed_spin_attack_direction
        }
    })
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

