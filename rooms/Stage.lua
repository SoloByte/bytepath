
Stage = Object:extend()

function Stage:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()
    self.main_canvas = love.graphics.newCanvas(gw, gh)

    input:bind("1", function ()
        self.area:addGameObject("Ammo", random(25, gw - 25), random(25, gh - 25))
    end)
    --[[
    for i = 1, 100 do
        local x = love.math.random(gw)
        local y = love.math.random(gh)
        self.area:addGameObject("Player", x, y)
    end
    --]]
    self.area:addGameObject("Player", gw * 0.5, gh * 0.5)
    
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