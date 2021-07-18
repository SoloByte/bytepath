Shooter = GameObject:extend()


function Shooter:new(area, x,y,opts)
    Shooter.super.new(self,area,x,y,opts)

    self.group = "enemy"
    
    local direction = table.random({-1, 1})
    self.x = gw * 0.5 + direction * (gw * 0.5 + 48)
    self.y = random(16, gh - 16)

    self.w, self.h = 12, 6
    self.collider = self.area.world:newPolygonCollider(
        {
            self.w, 0, --1
            -self.w * 0.5, self.h, --2
            -self.w, 0, --3
            -self.w * 0.5, -self.h, --4
        }
    )
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    self.collider:setCollisionClass("Enemy")
    self.collider:setFixedRotation(false)
    self.collider:setAngle(direction == 1 and math.pi or 0)
    self.collider:setFixedRotation(true)
    self.v = -direction * random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(random(-100, 100))

    self.hp = 100

    self.timer:every(random(3, 5), function ()
        local angle = self.collider:getAngle()
        self.area:addGameObject(
            "PreAttackEffect",
            self.x + 1.4 * self.w * math.cos(angle),
            self.y + 1.4 * self.w * math.sin(angle),
            {shooter = self, color = hp_color, duration = 1}
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

function Shooter:hit(damage)
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

function Shooter:update(dt)
    Shooter.super.update(self, dt)
    self.collider:setLinearVelocity(self.v, 0)
end

function Shooter:draw()
    if self.hit_flash then
        love.graphics.setColor(default_color)
    else
        love.graphics.setColor(hp_color)
    end
    
    local points = {self.collider:getWorldPoints(self.collider.shapes.main:getPoints())}
    love.graphics.polygon("line", points)
    love.graphics.setColor(default_color)
end

function Shooter:destroy()
    Shooter.super.destroy(self)
end

function Shooter:die()
    self.dead = true
    self.area:addGameObject("Ammo", self.x, self.y)
    if current_room.player then
        if current_room.player.chances.drop_double_ammo_chance:next() then
            self.area:addGameObject("Ammo", self.x, self.y)
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Double Ammo!', color = ammo_color})
        end
    end
    self.area:addGameObject("EnemyDeathEffect", self.x, self.y, {color = hp_color, w = self.w * 3})
    current_room:increaseScore(SCORE_POINTS.SHOOTER)
    --self.area:addGameObject("InfoText", self.x, self.y, {text = "+Shooter", color = boost_color, w = self.w, h = self.h})
end