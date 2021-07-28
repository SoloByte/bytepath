Seeker = GameObject:extend()


function Seeker:new(area, x,y,opts)
    Seeker.super.new(self,area,x,y,opts)

    self.group = "enemy"
    
    local direction = table.random({-1, 1})
    self.x = gw * 0.5 + direction * (gw * 0.5 + 48)
    self.y = random(16, gh - 16)

    self.r = direction == 1 and math.pi or 0

    self.w, self.h = 16, 8
    self.collider = self.area.world:newPolygonCollider(
        {
            self.w, 0, --1
            self.w * 0.75, self.h, --2
            -self.w * 0.75, self.h, --3
            -self.w, 0, --4
            -self.w * 0.75, -self.h, --5
            self.w * 0.75, -self.h, --6
        }
    )
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    self.collider:setCollisionClass("Enemy")
    self.collider:setFixedRotation(false)
    self.collider:setAngle(self.r)
    self.collider:setFixedRotation(true)
    self.v = -direction * random(10, 25)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    --self.collider:applyAngularImpulse(random(-100, 100))

    self.hp = 200

    
    self.timer:every(random(2, 4), function ()
        local angle = self.r + math.pi

        self.area:addGameObject("EnemyProjectile", 
        self.x + 1.4 * self.w * math.cos(angle),
        self.y + 1.4 * self.w * math.sin(angle), 
        {
            r = angle, 
            v = random(80, 100), 
            s = 3.5,
            mine = true
        })
    end)
end

function Seeker:hit(damage)
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

function Seeker:update(dt)
    Seeker.super.update(self, dt)
    local target = current_room.player
    if self.target and self.target.dead then self.target = nil end
    if target then
        local heading_x, heading_y = math.cos(self.r), math.sin(self.r)
        local target_angle = math.atan2(target.y - self.y, target.x - self.x)
        local to_target_heading_x, to_target_heading_y = math.cos(target_angle), math.sin(target_angle)
        local final_heading_x, final_heading_y = heading_x + to_target_heading_x * 0.1, heading_y + to_target_heading_y * 0.1
        self.r = math.atan2(final_heading_y, final_heading_x)

        --local angle = math.atan2(target.y - self.y, target.x - self.x)
        --local to_target_heading = Vector(math.cos(angle), math.sin(angle)):normalized()
        --local final_heading = (heading + 0.1 * to_target_heading):normalized()
        --self.r = final_heading:angleTo()
        --self.collider:setLinearVelocity(self.v * final_heading.x, self.v * final_heading.y)
    end

    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    --self.collider:setFixedRotation(false)
    --self.collider:setAngle(self.r)
    --self.collider:setFixedRotation(true)
end

function Seeker:draw()
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

function Seeker:destroy()
    Seeker.super.destroy(self)
end

function Seeker:die()
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
    current_room:increaseScore(SCORE_POINTS.SEEKER)
    --self.area:addGameObject("InfoText", self.x, self.y, {text = "+Seeker", color = boost_color, w = self.w, h = self.h})
end