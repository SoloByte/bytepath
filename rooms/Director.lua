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

    self.attack_spawn_chances = chanceList(
        --{"Neutral", 0},
        {"Double", 25},
        {"Triple", 15},
        {"Spread",30},
        {"Rapid", 10},
        {"Side", 10},
        {"Back", 10}
    )
    
    self.resource_spawn_chances = chanceList({'Boost', 28}, {'HP', 14}, {'SkillPoint', 58})

    self:setEnemySpawnsForThisRound()
    self.stage.area:addGameObject("Attack", random(25, gw - 25), random(25, gh - 25))
end


function Director:update(dt)
    self.timer:update(dt)

    if self.round_timer > 0 then
        self.round_timer = self.round_timer - dt
        if self.round_timer <= 0 then
            self.round_timer = self.round_duration
            self.difficulty = self.difficulty + 1
            self:setEnemySpawnsForThisRound()
        end
    end

    if self.resource_timer > 0 then
        self.resource_timer = self.resource_timer - dt
        if self.resource_timer <= 0 then
            self.resource_timer = self.resource_duration
            self.stage.area:addGameObject(self.resource_spawn_chances:next())
        end
    end

    if self.attack_timer > 0 then
        self.attack_timer = self.attack_timer - dt
        if self.attack_timer <= 0 then
            self.attack_timer = self.attack_duration
            local next_attack = self.attack_spawn_chances:next()
            print("Next Attack", next_attack)
            self.stage.area:addGameObject(next_attack)
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