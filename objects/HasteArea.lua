HasteArea = GameObject:extend()


function HasteArea:new(area, x,y,opts)
    HasteArea.super.new(self,area,x,y,opts)
    local dur_multiplier = opts.dur_mp or 1.0
    self.r = random(64, 92)
    self.timer:after(4.0 * dur_multiplier, function ()
        self.timer:tween(0.25, self, {r = 0}, "in-out-cubic", function ()
            self:die()
        end)
    end)
end

function HasteArea:update(dt)
    HasteArea.super.update(self, dt)

    local player = current_room.player
    if not player then return end

    local dis_sq = distanceSquared(player.x, player.y, self.x, self.y)
    local r_sq = self.r * self.r
    if dis_sq < r_sq then
        if not player.inside_haste_area then
            player.inside_haste_area = true
        end
    else
        if player.inside_haste_area then
            player.inside_haste_area = false
        end
    end
end

function HasteArea:draw()
    love.graphics.setColor(ammo_color)
    love.graphics.circle("line", self.x, self.y, self.r + random(-2, 2))
    love.graphics.setColor(default_color)
end

function HasteArea:destroy()
    HasteArea.super.destroy(self)
end

function HasteArea:die()
    self.dead = true
    --self.area:addGameObject("BoostEffect", self.x, self.y, {color = boost_color, w = self.w, h = self.h})
    --self.area:addGameObject("InfoText", self.x, self.y, {text = "+HasteArea", color = boost_color, w = self.w, h = self.h})
end