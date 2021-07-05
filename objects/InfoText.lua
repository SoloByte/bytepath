InfoText = GameObject:extend()


function InfoText:new(area, x,y,opts)
    InfoText.super.new(self,area,x,y,opts)
    self.depth = 80

    self.characters = {}
    for i = 1, #self.text do table.insert(self.characters, self.text:utf8sub(i, i)) end

    self.font = fonts.m5x7_16
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
        love.graphics.setColor(self.color)
        love.graphics.print(self.characters[i], self.x + width, self.y, 0, 1, 1, 0, self.font:getHeight() * 0.5)
    end

    love.graphics.setColor(default_color)
end

function InfoText:destroy()
    InfoText.super.destroy(self)
end