BigRock = GameObject:extend()


function BigRock:new(area, x,y,opts)
    BigRock.super.new(self,area,x,y,opts)

    self.group = "enemy"
    
    self.direction = table.random({-1, 1})
    self.x = gw * 0.5 + self.direction * (gw * 0.5 + 48)
    self.y = random(16, gh - 16)

    self.w, self.h = 18, 18
    self.collider = self.area.world:newPolygonCollider(createIrregularPolygon(self.w, 8))
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    self.collider:setCollisionClass("Enemy")
    self.collider:setFixedRotation(false)
    self.v = -self.direction * random(15, 25)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(random(-100, 100))

    self.hp = 300

end

function BigRock:hit(damage)
    if self.dead then return end
    local dmg = damage or 100
    self.hp = self.hp - dmg
    if self.hp <= 0 then
        self:die()
        return
    end

    self.hit_flash = true
    self.timer:after(0.2, function ()
        self.hit_flash = false
    end)
end

function BigRock:update(dt)
    BigRock.super.update(self, dt)
    self.collider:setLinearVelocity(self.v, 0)
end

function BigRock:draw()
    if self.hit_flash then
        love.graphics.setColor(default_color)
    else
        love.graphics.setColor(hp_color)
    end
    
    local points = {self.collider:getWorldPoints(self.collider.shapes.main:getPoints())}
    love.graphics.polygon("line", points)
    love.graphics.setColor(default_color)
end

function BigRock:destroy()
    BigRock.super.destroy(self)
end

function BigRock:die()
    self.dead = true
    if current_room.player then
        if not current_room.player.no_ammo_drop then
            self.area:addGameObject("Ammo", self.x, self.y)
            if current_room.player.chances.drop_double_ammo_chance:next() then
                self.area:addGameObject("Ammo", self.x, self.y)
                self.area:addGameObject('InfoText', self.x, self.y, {text = 'Double Ammo!', color = ammo_color})
            end
        end
    end

    for i = 1, 4 do
        local x = self.x + random(-20, 20)
        local y = self.y + random(-20, 20)
        self.area:addGameObject("Rock", 0, 0, {spawn_x = x, spawn_y = y, spawn_direction = self.direction})
    end

    self.area:addGameObject("EnemyDeathEffect", self.x, self.y, {color = hp_color, w = self.w * 3})
    current_room:increaseScore(SCORE_POINTS.BIGROCK)
    --self.area:addGameObject("InfoText", self.x, self.y, {text = "+BigRock", color = boost_color, w = self.w, h = self.h})
end