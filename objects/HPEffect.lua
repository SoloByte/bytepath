HPEffect = GameObject:extend()

function HPEffect:new(area, x, y, opts)
    HPEffect.super.new(self, area, x, y, opts)
    self.depth = 75

    self.x, self.y = math.floor(self.x), math.floor(self.y)

    self.current_color = default_color
    self.timer:after(0.1, function() 
        self.current_color = self.color 
        self.timer:after(0.35, function()
            self.dead = true
        end)
    end)

    self.visible = true
    self.timer:after(0.2, function ()
        self.timer:every(0.05, function () self.visible = not self.visible end, 6)
        self.timer:after(0.35, function() self.visible = true end)
    end)

    self.sx = 1
    self.timer:tween(0.35, self, {sx = 2}, "in-out-cubic")
end

function HPEffect:update(dt)
    HPEffect.super.update(self, dt)
end

function HPEffect:draw()
    if not self.visible then return end

    love.graphics.setColor(self.current_color)
    local hor_w = self.w * 1.0
    local hor_h = self.h * 0.25
    local ver_w = hor_h
    local ver_h = hor_w
    love.graphics.rectangle("fill", self.x - hor_w * 0.5, self.y - hor_h * 0.5, hor_w, hor_h) --horizontal rect
    love.graphics.rectangle("fill", self.x - ver_w * 0.5, self.y - ver_h * 0.5, ver_w, ver_h) --vertical rect

    love.graphics.setColor(default_color)
    love.graphics.circle("line", self.x, self.y, self.w * self.sx * 1.35, 7)
end

function HPEffect:destroy()
    HPEffect.super.destroy(self)
end