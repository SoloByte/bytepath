
Stage = Object:extend()

function Stage:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()
    self.area.world:addCollisionClass("Player")
    self.area.world:addCollisionClass("Enemy")
    self.area.world:addCollisionClass("Projectile", {ignores = {"Projectile", "Player"}})
    self.area.world:addCollisionClass("Collectable", {ignores = {"Projectile", "Collectable"}})
    self.main_canvas = love.graphics.newCanvas(gw, gh)

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

    self.player = self.area:addGameObject("Player", gw * 0.5, gh * 0.5)
    
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
end

function Stage:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        camera:attach(0, 0, gw, gh)
        --love.graphics.circle("line", gw * 0.5, gh * 0.5, 75)
        self.area:draw()
        camera:detach()
    love.graphics.setCanvas()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode("alpha")


end


function Stage:destroy()
    self.area:destroy()
    self.area = nil
end