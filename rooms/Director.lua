Director = Object:extend()



function Director:new(stage)
    self.stage = stage
    self.timer = Timer()

    self.difficulty = 1
    self.round_duration = 22
    self.round_timer = self.round_duration
    
    self.attack_duration = 30
    self.attack_timer = self.attack_duration

    self.resource_duration = 16
    self.resource_timer = self.resource_duration

    self.difficulty_to_points = {}
    self.difficulty_to_points[1] = 16

    for i = 2, 1024, 4 do
        self.difficulty_to_points[i] = self.difficulty_to_points[i - 1] + 8
        self.difficulty_to_points[i + 1] = self.difficulty_to_points[i]
        self.difficulty_to_points[i + 2] = math.floor(self.difficulty_to_points[i + 1] / 1.5)
        self.difficulty_to_points[i + 3] = math.floor(self.difficulty_to_points[i + 2] * 2.0)
    end

    self.enemy_to_points = {
        ["Rock"] = 1,
        ["Shooter"] = 2,
    }

    self.enemy_spawn_chances = {}
    self.enemy_spawn_chances[1] = chanceList({"Rock", 1})
    self.enemy_spawn_chances[2] = chanceList({"Rock", 8}, {"Shooter", 4})
    self.enemy_spawn_chances[3] = chanceList({"Rock", 8}, {"Shooter", 8})
    self.enemy_spawn_chances[4] = chanceList({"Rock", 4}, {"Shooter", 8})
    for i = 5, 1024 do
        self.enemy_spawn_chances[i] = chanceList(
            {"Rock", random(2, 12)},
            {"Shooter", random(2, 12)}
        )
    end
    
    local asc = stage.player.attack_spawn_chance_multipliers
    --[[
    local chance_list = {}
    for key, value in pairs(asc) do
        table.insert(chance_list, {[key] = 5 * value})
    end
    self.attack_spawn_chances = chanceListTable(chance_list)
    --]]
    ---[[
    self.attack_spawn_chances = chanceList(
        --{"Neutral", 0},
        {"Double",      5 * asc["Double"]},
        {"Triple",      5 * asc["Triple"]},
        {"Spread",      5 * asc["Spread"]},
        {"Rapid",       5 * asc["Rapid"]},
        {"Side",        5 * asc["Side"]},
        {"Back",        5 * asc["Back"]},
        {"Homing",      5 * asc["Homing"]},
        {"Sniper",      5 * asc["Sniper"]},
        {"Swarm",       5 * asc["Swarm"]},
        {"Blast",       5 * asc["Blast"]},
        {"Spin",        5 * asc["Spin"]},
        {"Flame",       5 * asc["Flame"]},
        {"Bounce",      5 * asc["Bounce"]},
        {"2Split",      5 * asc["2Split"]},
        {"3Split",      5 * asc["3Split"]},
        {"4Split",      5 * asc["4Split"]},
        {"Lightning",   5 * asc["Lightning"]},
        {"Explode",     5 * asc["Explode"]},
        {"Laser",       0 * asc["Laser"]}
    )
    --]]
    self.resource_spawn_chances = chanceList(
        {'Boost', 28 * self.stage.player.boost_spawn_chance_multiplier}, 
        {'HP', 14 * self.stage.player.hp_spawn_chance_multiplier}, 
        {'Skillpoint', 58 * self.stage.player.sp_spawn_chance_multiplier})

    self:setEnemySpawnsForThisRound()
    
    local next_attack = self.attack_spawn_chances:next()
    self.stage.area:addGameObject("Attack", 0, 0, {attack = next_attack})
end


function Director:update(dt)
    self.timer:update(dt)

    local round_multiplier = 1.0
    local resource_multiplier = 1.0
    local attack_multiplier = 1.0
    if self.stage.player then
        round_multiplier = self.stage.player.enemy_spawn_rate_multiplier
        resource_multiplier = self.stage.player.resource_spawn_rate_multiplier
        attack_multiplier = self.stage.player.attack_spawn_rate_multiplier
    end

    if self.round_timer > 0 then
        self.round_timer = self.round_timer - dt * round_multiplier
        if self.round_timer <= 0 then
            self.round_timer = self.round_duration
            self.difficulty = self.difficulty + 1
            self:setEnemySpawnsForThisRound()
        end
    end

    if self.resource_timer > 0 then
        self.resource_timer = self.resource_timer - dt * resource_multiplier
        if self.resource_timer <= 0 then
            self.resource_timer = self.resource_duration
            local resource = self.resource_spawn_chances:next()
            self.stage.area:addGameObject(resource)
            
            
            if self.stage.player then
                if resource == "HP" then
                    if self.stage.player.chances.spawn_double_hp_chance:next() then
                        self.stage.area:addGameObject("HP")
                        self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Spawn!', color = hp_color})
                    end
                elseif resource == "Skillpoint" then
                    if self.stage.player.chances.spawn_double_sp_chance:next() then
                        self.stage.area:addGameObject("Skillpoint")
                        self.area:addGameObject('InfoText', self.x, self.y, {text = 'SP Spawn!', color = skill_point_color})
                    end
                end
            end
        end
    end

    if self.attack_timer > 0 then
        self.attack_timer = self.attack_timer - dt * attack_multiplier
        if self.attack_timer <= 0 then
            self.attack_timer = self.attack_duration
            local next_attack = self.attack_spawn_chances:next()
            self.stage.area:addGameObject("Attack", 0, 0, {attack = next_attack})
        end
    end
end

function Director:setEnemySpawnsForThisRound()
    local points = self.difficulty_to_points[self.difficulty]
    local enemy_list = {}

    while points > 0 do
        local enemy = self.enemy_spawn_chances[self.difficulty]:next()
        points = points - self.enemy_to_points[enemy]
        table.insert(enemy_list, enemy)
    end
    
    local enemy_spawn_times = {}
    for i = 1, #enemy_list do
        enemy_spawn_times[i] = random(0, self.round_duration)
    end
    table.sort(enemy_spawn_times, function (a, b) return a < b end)
    
    for i = 1, #enemy_spawn_times do
        self.timer:after(enemy_spawn_times[i], function ()
            self.stage.area:addGameObject(enemy_list[i])
        end)
    end
end