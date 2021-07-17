Skillpoint = GameObject:extend()


function Skillpoint:new(area, x,y,opts)
    Skillpoint.super.new(self,area,x,y,opts)


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

function Skillpoint:update(dt)
    Skillpoint.super.update(self, dt)
    self.collider:setLinearVelocity(self.v, 0)
end

function Skillpoint:draw()
    love.graphics.setColor(skill_point_color)
    pushRotate(self.x, self.y, self.collider:getAngle())
    draft:rhombus(self.x, self.y, self.w * 1.5, self.h * 1.5, "line")
    draft:rhombus(self.x, self.y, self.w * 0.75, self.h * 0.75, "fill")
    love.graphics.pop()
end

function Skillpoint:destroy()
    Skillpoint.super.destroy(self)
end

function Skillpoint:die()
    self.dead = true
    self.area:addGameObject("SkillpointEffect", self.x, self.y, {color = skill_point_color, w = self.w, h = self.h})
    self.area:addGameObject("InfoText", self.x, self.y, {text = "+SP", color = skill_point_color, w = self.w, h = self.h})
end