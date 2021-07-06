Attack = GameObject:extend()


function Attack:new(area, x,y,opts)
    Attack.super.new(self,area,x,y,opts)


    local direction = table.random({-1, 1})
    self.x = gw * 0.5 + direction * (gw * 0.5 + 48)
    self.y = random(48, gh - 48)

    self.w, self.h = 12, 12
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setCollisionClass("Collectable")
    self.collider:setFixedRotation(true)
    self.v = -direction * random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    --self.collider:applyAngularImpulse(random(-24, 24))

    if not self.attack then
        --choose random attack
        self.attack = table.random(table.keys(attacks))
    end
    self.font = fonts.m5x7_16
    self.font_w, self.font_h = self.font:getWidth(attacks[self.attack].abbrevation), self.font:getHeight()
    
end

function Attack:update(dt)
    Attack.super.update(self, dt)
    self.collider:setLinearVelocity(self.v, 0)
end

function Attack:draw()
    pushRotate(self.x, self.y, self.collider:getAngle())

    love.graphics.setColor(attacks[self.attack].color)
    draft:rhombus(self.x, self.y, self.w * 2.3, self.h * 2.3, "line")

    --love.graphics.setFont(self.font)
    love.graphics.print(attacks[self.attack].abbrevation, 
    self.font, 
    self.x, 
    self.y, 
    0, 1, 1, 
    self.font_w * 0.5, 
    self.font_h * 0.5)
    
    love.graphics.setColor(default_color)
    draft:rhombus(self.x, self.y, self.w * 1.8, self.h * 1.8, "line")
    love.graphics.pop()
end

function Attack:destroy()
    Attack.super.destroy(self)
end

function Attack:die()
    self.dead = true
    self.area:addGameObject("AttackEffect", self.x, self.y, {color = attacks[self.attack].color, w = self.w, h = self.h})
    self.area:addGameObject("InfoText", self.x, self.y, {text = self.attack, color = attacks[self.attack].color, w = self.w, h = self.h})
end