
Stage = Object:extend()

function Stage:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()
    self.area.world:addCollisionClass("Player")
    self.area.world:addCollisionClass("Enemy")
    self.area.world:addCollisionClass("Projectile", {ignores = {"Projectile", "Player"}})
    self.area.world:addCollisionClass("EnemyProjectile", {ignores = {"EnemyProjectile", "Enemy"}})
    self.area.world:addCollisionClass("Collectable", {ignores = {"Projectile", "EnemyProjectile", "Collectable", "Enemy"}})
    self.main_canvas = love.graphics.newCanvas(gw, gh)

    self.score = 0
    self.font = fonts.m5x7_16

    input:bind("1", function ()
        self.area:addGameObject("Ammo", random(25, gw - 25), random(25, gh - 25))
    end)

    input:bind("2", function ()
        self.area:addGameObject("Boost", random(25, gw - 25), random(25, gh - 25))
    end)

    input:bind("3", function ()
        self.area:addGameObject("HP", random(25, gw - 25), random(25, gh - 25))
    end)

    input:bind("4", function ()
        self.area:addGameObject("Skillpoint", random(25, gw - 25), random(25, gh - 25))
    end)

    input:bind("5", function ()
        self.area:addGameObject("Attack", random(25, gw - 25), random(25, gh - 25))
    end)

    input:bind("6", function ()
        self.area:addGameObject("Rock", random(25, gw - 25), random(25, gh - 25))
    end)

    input:bind("7", function ()
        self.area:addGameObject("Shooter", random(25, gw - 25), random(25, gh - 25))
    end)

    input:bind("8", function ()
        slow(0.5, 5.0)
    end)

    input:bind("9", function ()
        slow(0.1, 5.0)
    end)

    self.draw_collision = false
    input:bind("f2", function ()
        self.draw_collision = not self.draw_collision
        self.area.world:setQueryDebugDrawing(self.draw_collision)
    end)
    
    

    self.player = self.area:addGameObject("Player", gw * 0.5, gh * 0.5)
    
    self.director = Director(self)

    
    --[[
    input:bind("f4", function ()
        self.player.dead = true
        self.player = nil
    end)

    input:bind("f3", function ()
        camera:shake(4, 60, 1)
    end)
    --]]

    
end

function Stage:update(dt)
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw * 0.5, gh * 0.5)
    self.area:update(dt)
    self.director:update(dt)
end

function Stage:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        camera:attach(0, 0, gw, gh)
        self.area:draw()
        camera:detach()

        --score
        love.graphics.setFont(self.font)
        love.graphics.setColor(default_color)
        self:drawText(self.score, gw - 20, 10, "center", "center")
        
        --skillpoints
        love.graphics.setColor(skill_point_color)
        self:drawText(SP .. "SP", 20, 10, "center", "center")

        self:drawHP()
        self:drawBoost()
        self:drawAmmo()
        self:drawCycle()

        if self.draw_collision then
            self.area.world:draw(128)
        end

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode("alpha")


end


function Stage:destroy()
    self.area:destroy()
    self.area = nil
    self.player = nil
end


function Stage:finish()
    timer:after(1.0, function ()
        gotoRoom("Stage")
    end)
end

function Stage:increaseScore(amount)
    self.score = self.score + amount
end


function Stage:drawText(text, x, y, halign, valign)
    local ox, oy = 0, 0
    halign = halign or "center"
    valign = valign or "center"

    if halign == "center" then
        ox = math.floor(self.font:getWidth(text) * 0.5)
    elseif halign == "right" then
        ox = math.floor(self.font:getWidth(text))
    end

    if valign == "center" then
        oy = math.floor(self.font:getHeight() * 0.5)
    elseif valign == "bottom" then
        oy = math.floor(self.font:getHeight())
    end

    love.graphics.print(text, x, y, 0, 1, 1, ox, oy)
end

function Stage:drawHP()
    local hp, max_hp = self.player.hp, self.player.max_hp
    local x = gw * 0.5 - 52
    local y = gh - 16
    self:drawBar(x, y, 48, 4, (hp / max_hp), hp_color, 0.125)
    self:drawText("HP", x + 24, y - 8)
    self:drawText(math.floor(hp) .. "/" .. math.floor(max_hp), x + 24, y + 10)
end

function Stage:drawBoost()
    local boost, max_boost = self.player.boost, self.player.max_boost
    local x = gw * 0.5 + 4
    local y = 16
    self:drawBar(x, y, 48, 4, (boost / max_boost), boost_color, 0.125)
    self:drawText("Boost", x + 24, y - 8)
    self:drawText(math.floor(boost) .. "/" .. math.floor(max_boost), x + 24, y + 10)
end

function Stage:drawAmmo()
    local ammo, max_ammo = self.player.ammo, self.player.max_ammo
    local x = gw * 0.5 - 52
    local y = 16
    self:drawBar(x, y, 48, 4, (ammo / max_ammo), ammo_color, 0.125)
    self:drawText("Ammo", x + 24, y - 8)
    self:drawText(math.floor(ammo) .. "/" .. math.floor(max_ammo), x + 24, y + 10)
end

function Stage:drawCycle()
    local timer, duration = self.player.cycle_timer, self.player.cycle_cooldown
    local x = gw * 0.5 + 4
    local y = gh - 16
    self:drawBar(x, y, 48, 4, 1.0 - (timer / duration), default_color, 0.125)
    self:drawText("Cycle", x + 24, y - 8)
    self:drawText(math.floor(timer) .. "/" .. math.floor(duration), x + 24, y + 10)
end


function Stage:drawBar(x, y, w, h, factor, color, color_change)
    color_change = color_change or 0.125
    local r, g, b = color[1], color[2], color[3]
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, w * factor, h)
    love.graphics.setColor(r - color_change, g - color_change, b - color_change)
    love.graphics.rectangle("line", x, y, w, h)
end