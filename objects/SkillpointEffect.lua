SkillpointEffect = GameObject:extend()

function SkillpointEffect:new(area, x, y, opts)
    SkillpointEffect.super.new(self, area, x, y, opts)
    self.depth = 75

    self.x, self.y = math.floor(self.x), math.floor(self.y)

    self.current_color = default_color
    self.timer:after(0.2, function() 
        self.current_color = self.color 
        self.timer:after(0.4, function()
            self.dead = true
        end)
    end)

    self.visible = true
    self.timer:after(0.2, function ()
        self.timer:every(0.05, function () self.visible = not self.visible end, 6)
        self.timer:after(0.35, function() self.visible = true end)
    end)

    self.sx, self.sy = 1, 1
    self.timer:tween(0.5, self, {sx = 2, sy = 2}, "in-out-cubic")
end

function SkillpointEffect:update(dt)
    SkillpointEffect.super.update(self, dt)
end

function SkillpointEffect:draw()
    if not self.visible then return end

    love.graphics.setColor(self.current_color)
    draft:rhombus(self.x, self.y, math.floor(self.w * 1.25), math.floor(self.h * 1.25), 'fill')
    draft:rhombus(self.x, self.y, self.w * self.sx * 2, self.h * self.sy * 2, 'line')
    love.graphics.setColor(default_color)
end

function SkillpointEffect:destroy()
    SkillpointEffect.super.destroy(self)
end