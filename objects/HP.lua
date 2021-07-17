HP = GameObject:extend()


function HP:new(area, x,y,opts)
    HP.super.new(self,area,x,y,opts)


    local direction = table.random({-1, 1})
    self.x = gw * 0.5 + direction * (gw * 0.5 + 48)
    self.y = random(48, gh - 48)

    self.w, self.h = 12, 12
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setCollisionClass("Collectable")
    self.collider:setFixedRotation(false)
    self.v = -direction * random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(random(-24, 24))

    self.group = "resource"
end

function HP:update(dt)
    HP.super.update(self, dt)
    self.collider:setLinearVelocity(self.v, 0)
end

function HP:draw()
    pushRotate(self.x, self.y, self.collider:getAngle())
    
    love.graphics.setColor(default_color)
    love.graphics.circle("line", self.x, self.y, self.w * 1.35, 7)
    
    love.graphics.setColor(hp_color)
    local hor_w = self.w * 1.0
    local hor_h = self.h * 0.25
    local ver_w = hor_h
    local ver_h = hor_w
    love.graphics.rectangle("fill", self.x - hor_w * 0.5, self.y - hor_h * 0.5, hor_w, hor_h) --horizontal rect
    love.graphics.rectangle("fill", self.x - ver_w * 0.5, self.y - ver_h * 0.5, ver_w, ver_h) --vertical rect
    
    love.graphics.pop()
end

function HP:destroy()
    HP.super.destroy(self)
end

function HP:die()
    self.dead = true
    self.area:addGameObject("HPEffect", self.x, self.y, {color = hp_color, w = self.w, h = self.h})
    self.area:addGameObject("InfoText", self.x, self.y, {text = "+HP", color = hp_color, w = self.w, h = self.h})
end