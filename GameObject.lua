GameObject = Object:extend()

function GameObject:new(area, x, y, opts)
    local opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end

    self.area = area
    self.x, self.y = x, y
    self.id = UUID()
    self.dead = false
    self.timer = Timer()
    self.creation_time = love.timer.getTime()
    self.depth = 50
    self.group = "gameobject"
    self.slow_factor = 1.0
end

function GameObject:update(dt)
    if self.timer then self.timer:update(dt) end
    if self.collider then self.x, self.y = self.collider:getPosition() end
end

function GameObject:draw()

end


function GameObject:checkBounds()
    return self.x < 0 or self.y < 0 or self.x > gw or self.y > gh
end


function GameObject:destroy()
    self.timer:destroy()
    if self.collider then 
        self.collider:destroy()
        self.collider = nil
    end
end

function GameObject:setSlowFactor(factor)
    
end