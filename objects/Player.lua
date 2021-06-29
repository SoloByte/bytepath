Player = GameObject:extend()



function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)
    
    self.timer:every(0.24, function () self:shoot() end)
    self.timer:every(5, function () self:tick() end)
    input:bind("f3", function () self:die() end)

    self.w, self.h = 12, 12
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)

    self.r = -math.pi * 0.5 --starting angle (up)
    self.rv = 1.66 * math.pi --angle change on player input
    self.vel = 0
    self.base_max_vel = 100
    self.max_vel = self.base_max_vel
    self.acc = 100

    self.ship = "Fighter"
    self.polygons = {}

    self.boosting = false
    self.trail_color = skill_point_color
    
    
    
    self.timer:every(0.025, function ()
        if self.ship == "Fighter" then
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
        end
    end)

    if self.ship == "Fighter" then
        self.polygons[1] = {
            self.w, 0, --1
            self.w / 2, -self.w / 2, --2
            -self.w / 2, -self.w / 2, --3
            -self.w, 0, --4
            -self.w / 2, self.w / 2, --5
            self.w / 2, self.w / 2, --6
        }
        self.polygons[2] = {
            self.w / 2, -self.w / 2, --1
            0, -self.w, --2
            -self.w - self.w / 2, -self.w, --3
            -self.w * 0.75, -self.w * 0.25, --4
            -self.w / 2, -self.w / 2, --5
        }
        self.polygons[3] = {
            self.w / 2, self.w / 2, --1
            0, self.w, --2
            -self.w - self.w / 2, self.w, --3
            -self.w * 0.75, self.w * 0.25, --4
            -self.w / 2, self.w / 2, --5
        }
    end


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

function Player:update(dt)
    Player.super.update(self, dt)

    self.boosting = false
    self.max_vel = self.base_max_vel
    if input:down("up") then 
        self.boosting = true
        self.max_vel = self.base_max_vel * 1.5 
    end
    if input:down("down") then 
        self.boosting = true
        self.max_vel = self.base_max_vel * 0.5 
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