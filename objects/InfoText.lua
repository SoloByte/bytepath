InfoText = GameObject:extend()


function InfoText:new(area, x,y,opts)
    InfoText.super.new(self,area,x,y,opts)
    self.depth = 80

    --test pos randomization (boost.lua sets w and h)
    self.w, self.h = self.w or 0, self.h or 0
    self.x, self.y = self.x + random(-self.w, self.w), self.y + random(-self.h, self.h)

    self.characters = {}
    self.background_colors = {}
    self.foreground_colors = {}
    for i = 1, #self.text do table.insert(self.characters, self.text:utf8sub(i, i)) end
    self.char_count = #self.characters
    self.font = fonts.m5x7_16

    local default_colors = {default_color, hp_color, boost_color, ammo_color, skill_point_color}
    local negative_colors = {
        {1.0 - default_color[1], 1.0 - default_color[2], 1.0 - default_color[3]},
        {1.0 - hp_color[1], 1.0 - hp_color[2], 1.0 - hp_color[3]},
        {1.0 - boost_color[1], 1.0 - boost_color[2], 1.0 - boost_color[3]},
        {1.0 - ammo_color[1], 1.0 - ammo_color[2], 1.0 - ammo_color[3]},
        {1.0 - skill_point_color[1], 1.0 - skill_point_color[2], 1.0 - skill_point_color[3]},
    }
    self.all_colors = fn.append(default_colors, negative_colors)

    self.visible = true
    self.timer:after(0.70, function()
        self.timer:every(0.05, function() self.visible = not self.visible end, 6)
        self.timer:after(0.35, function() self.visible = true end)

        self.timer:every(0.035, function ()
            local random_characters = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-*#,.;:<>|/[]%$?@!&()=^~"
            local random_char_count = #random_characters
            for i = 1, self.char_count do
                if love.math.random(1, 20) <= 1 then
                    local r = love.math.random(1, random_char_count)
                    self.characters[i] = random_characters:utf8sub(r, r)
                end

                if love.math.random(1, 10) <= 1 then
                    self.background_colors[i] = table.random(self.all_colors)
                else
                    self.background_colors[i] = nil
                end

                if love.math.random(1, 10) <= 2 then
                    self.foreground_colors[i] = table.random(self.all_colors)
                else
                    self.foreground_colors[i] = nil
                end
            end
        end)
    end)
    self.timer:after(1.10, function() self.dead = true end)
end

function InfoText:update(dt)
    InfoText.super.update(self, dt)
end

function InfoText:draw()
    love.graphics.setFont(self.font)

    for i = 1, #self.characters do
        local width = 0
        if i > 1 then
            for j = 1, i - 1 do
                width = width + self.font:getWidth(self.characters[j])
            end
        end

        if self.background_colors[i] then
            love.graphics.setColor(self.background_colors[i])
            love.graphics.rectangle(
                "fill", 
                self.x + width, 
                self.y - self.font:getHeight() * 0.5, 
                self.font:getWidth(self.characters[i]),
                self.font:getHeight())
        end

        love.graphics.setColor(self.foreground_colors[i] or self.color or default_color)
        love.graphics.print(self.characters[i], self.x + width, self.y, 0, 1, 1, 0, self.font:getHeight() * 0.5)
    end

    love.graphics.setColor(default_color)
end

function InfoText:destroy()
    InfoText.super.destroy(self)
end