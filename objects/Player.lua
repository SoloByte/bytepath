Player = GameObject:extend()



function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)
    
    self.w, self.h = 12, 12
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)


    self.r = -math.pi * 0.5 --starting angle (up)
    self.rv = 1.66 * math.pi --angle change on player input
    self.vel = 0
    self.max_vel = 100
    self.acc = 100

    self.timer:every(0.24, function () self:shoot() end)
    self.timer:every(5, function () self:tick() end)
    input:bind("f3", function () self:die() end)
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

    if input:down("left") then self.r = self.r - self.rv * dt end
    if input:down("right") then self.r = self.r + self.rv * dt end

    self.vel = math.min(self.vel + self.acc * dt, self.max_vel)
    self.collider:setLinearVelocity(self.vel * math.cos(self.r), self.vel * math.sin(self.r))

    if self:checkBounds() then
        self:die()
    end

end


function Player:draw()
    love.graphics.circle("fill", self.x, self.y, self.w * 0.25)
    love.graphics.circle("line", self.x, self.y, self.w)
    love.graphics.line(self.x, self.y, self.x + 2*self.w * math.cos(self.r), self.y + 2*self.w * math.sin(self.r))
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