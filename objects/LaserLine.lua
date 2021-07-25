LaserLine = GameObject:extend()



function LaserLine:new(area, x, y, opts)
    LaserLine.super.new(self, area, x, y, opts)
    self.depth = 75
    self.r = opts.r or 0
    self.d = opts.d or 650
    self.w = opts.w or 8
    self.gap = self.w
    self.side_w = self.w * 0.25
    self.alpha = 1
    self.dur = opts.dur or 0.2
    self.timer:tween(self.dur, self, {w = 0, gap = self.gap * 2, alpha = 0}, "in-out-cubic", function() self.dead = true end)
    --self.timer:every(0.05, function() self:query() end, math.floor(self.dur / 0.05))
    self:query()
    --self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.d, self.w * 2)
    --self.collider:setPosition(self.x, self.y)
    --self.collider:setObject(self)
    --self.collider:setCollisionClass("Projectile")
    --self.collider:setFixedRotation(false)
    --self.collider:setAngle(self.r)
    --self.collider:setFixedRotation(true)
    --self.collider:setSensor(true)

end

function LaserLine:query()
    --local w_half = self.w * 0.5
    local world = self.area.world.box2d_world
    
    local cx, cy = self.x - 16 * math.cos(self.r), self.y - 16 * math.sin(self.r)
    local xr, yr = cx + self.gap * math.cos(self.r - math.pi * 0.5), cy + self.gap * math.sin(self.r - math.pi * 0.5)
    local xl, yl = cx + self.gap * math.cos(self.r + math.pi * 0.5), cy + self.gap * math.sin(self.r + math.pi * 0.5)
    local targets

    world:rayCast(xl, yl, xl + self.d * math.cos(self.r), yl + self.d * math.sin(self.r), function (fixture, x, y, xn, yn, fraction)
        
        print("Collider: ", fixture)
        return 1
    end)
    

    targets = self.area.world:queryLine(
        xl, yl, 
        xl + self.d * math.cos(self.r), 
        yl + self.d * math.sin(self.r), {"Enemy", "EnemyProjectile"})
    
    table.merge(targets, self.area.world:queryLine(
        cx, cy, 
        cx + self.d * math.cos(self.r), 
        cy + self.d * math.sin(self.r), {"Enemy", "EnemyProjectile"}))
    
    table.merge(targets, self.area.world:queryLine(
        xr, yr, 
        xr + self.d * math.cos(self.r), 
        yr + self.d * math.sin(self.r), {"Enemy", "EnemyProjectile"}))

    for i = 1, #targets do
        local obj = targets[i]:getObject()
        if obj then
            obj:hit()
        end
    end
end


function LaserLine:update(dt)
    LaserLine.super.update(self, dt)
    --[[
    if self.collider:enter("Enemy") then
        local col_info = self.collider:getEnterCollisionData("Enemy")
        if col_info then
            local object = col_info.collider:getObject()
            if object then
                object:hit()
            end
        end
    elseif self.collider:enter("EnemyProjectile") then
        local col_info = self.collider:getEnterCollisionData("EnemyProjectile")
        if col_info then
            local object = col_info.collider:getObject()
            if object then
                object:hit()
            end
        end
    end
    --]]
end

function LaserLine:draw()
    --pushRotate(self.x, self.y, self.r)
    local r, g, b = unpack(self.color)
    love.graphics.setColor(r, g, b, self.alpha)
    love.graphics.setLineWidth(self.side_w)
    local xr, yr = self.x + self.gap * math.cos(self.r - math.pi * 0.5), self.y + self.gap * math.sin(self.r - math.pi * 0.5)
    local xl, yl = self.x + self.gap * math.cos(self.r + math.pi * 0.5), self.y + self.gap * math.sin(self.r + math.pi * 0.5)
    love.graphics.line(xr, yr, xr + self.d * math.cos(self.r), yr + self.d * math.sin(self.r))
    love.graphics.line(xl, yl, xl + self.d * math.cos(self.r), yl + self.d * math.sin(self.r))

    love.graphics.setColor(default_color)
    love.graphics.setLineWidth(self.w)
    love.graphics.line(self.x, self.y, self.x + self.d * math.cos(self.r), self.y + self.d * math.sin(self.r))

    love.graphics.setLineWidth(1)
    --love.graphics.rectangle("fill", self.x, self.y - self.w * 0.5, self.d, self.w)
    --love.graphics.pop()
end

function LaserLine:destroy()
    LaserLine.super.destroy(self)
end