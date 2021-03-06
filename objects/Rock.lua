Rock = GameObject:extend()


function Rock:new(area, x,y,opts)
    Rock.super.new(self,area,x,y,opts)

    self.group = "enemy"
    
    local direction = opts.spawn_direction or table.random({-1, 1})
    self.x = opts.spawn_x or (gw * 0.5 + direction * (gw * 0.5 + 48))
    self.y = opts.spawn_y or (random(16, gh - 16))

    self.w, self.h = 8, 8
    self.collider = self.area.world:newPolygonCollider(createIrregularPolygon(8, 8))
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    self.collider:setCollisionClass("Enemy")
    self.collider:setFixedRotation(false)
    self.v = -direction * random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(random(-100, 100))

    self.hp = 100

end

function Rock:hit(damage)
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

function Rock:update(dt)
    Rock.super.update(self, dt)
    self.collider:setLinearVelocity(self.v, 0)
end

function Rock:draw()
    if self.hit_flash then
        love.graphics.setColor(default_color)
    else
        love.graphics.setColor(hp_color)
    end
    
    local points = {self.collider:getWorldPoints(self.collider.shapes.main:getPoints())}
    love.graphics.polygon("line", points)
    love.graphics.setColor(default_color)
end

function Rock:destroy()
    Rock.super.destroy(self)
end

function Rock:die()
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
    current_room:increaseScore(SCORE_POINTS.ROCK)
    --self.area:addGameObject("InfoText", self.x, self.y, {text = "+Rock", color = boost_color, w = self.w, h = self.h})
end