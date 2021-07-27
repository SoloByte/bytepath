Waver = GameObject:extend()


function Waver:new(area, x,y,opts)
    Waver.super.new(self,area,x,y,opts)

    self.group = "enemy"
    
    local direction = table.random({-1, 1})
    self.x = gw * 0.5 + direction * (gw * 0.5 + 48)
    self.y = random(16, gh - 16)

    self.r = direction == 1 and math.pi or 0

    -- Waving
    local d = table.random({-1, 1})
    local m = random(1, 4)
    self.timer:tween(0.25, self, {r = self.r + m*d*math.pi/8}, 'linear', function()
        self.timer:tween(0.5, self, {r = self.r - m*d*math.pi/4}, 'linear')
    end)
    self.timer:every(1, function()
        self.timer:tween(0.5, self, {r = self.r + m*d*math.pi/4}, 'linear', function()
            self.timer:tween(0.5, self, {r = self.r - m*d*math.pi/4}, 'linear')
        end)
    end)

    self.w, self.h = 12, 6
    self.collider = self.area.world:newPolygonCollider(
        {
            self.w, 0, --1
            0, self.h, --2
            -self.w, 0, --3
            0, -self.h, --4
        }
    )
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    self.collider:setCollisionClass("Enemy")
    self.collider:setFixedRotation(false)
    self.collider:setAngle(self.r)
    self.collider:setFixedRotation(true)
    self.v = -direction * random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    --self.collider:applyAngularImpulse(random(-100, 100))

    self.hp = 70

    self.timer:every(random(3, 5), function ()
        local angle = self.collider:getAngle()
        self.area:addGameObject(
            "PreAttackEffect",
            self.x + 1.4 * self.w * math.cos(angle),
            self.y + 1.4 * self.w * math.sin(angle),
            {Waver = self, color = hp_color, duration = 1}
        )
        self.timer:after(1.0, function ()
            local angle = self.collider:getAngle()

            self.area:addGameObject("EnemyProjectile", 
            self.x + 1.4 * self.w * math.cos(angle),
            self.y + 1.4 * self.w * math.sin(angle), 
            {r = math.atan2(current_room.player.y - self.y, current_room.player.x - self.x), 
            v = random(80, 100), s = 3.5})
        end)
    end)

end

function Waver:hit(damage)
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

function Waver:update(dt)
    Waver.super.update(self, dt)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
end

function Waver:draw()
    if self.hit_flash then
        love.graphics.setColor(default_color)
    else
        love.graphics.setColor(hp_color)
    end
    
    local points = {self.collider:getWorldPoints(self.collider.shapes.main:getPoints())}
    pushRotate(self.x, self.y, self.r)
    love.graphics.polygon("line", points)
    love.graphics.setColor(default_color)
    love.graphics.pop()
end

function Waver:destroy()
    Waver.super.destroy(self)
end

function Waver:die()
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
    self.area:addGameObject("EnemyDeathEffect", self.x, self.y, {color = hp_color, w = self.w * 3})
    current_room:increaseScore(SCORE_POINTS.WAVER)
    --self.area:addGameObject("InfoText", self.x, self.y, {text = "+Waver", color = boost_color, w = self.w, h = self.h})
end