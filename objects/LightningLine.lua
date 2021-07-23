LightningLine = GameObject:extend()



function LightningLine:new(area, x, y, opts)
    LightningLine.super.new(self, area, x, y, opts)
    self.depth = 75

    self.split_ends = opts.split_ends or false
    self.split_ends_chance = opts.split_ends_chance or 0.66

    self.lines = {}
    self.x, self.y = (self.x1+self.x2)/2, (self.y1+self.y2)/2
    table.insert(self.lines, {start_x = self.x1, start_y = self.y1, end_x = self.x2, end_y = self.y2})

    self.generations = opts.generations or 4
    self.max_offset = opts.max_offset or 8

    self:generate()
    
    self.duration = opts.duration or 0.15
    self.alpha = 1
    self.timer:tween(self.duration, self, {alpha = 0}, "in-out-cubic", function() self.dead = true end)
end


function LightningLine:generate()
    local offset = self.max_offset
    local segments = self.lines
    for i = 1, self.generations do
        for j = #segments, 0, -1 do
            local segment = table.remove(segments, i)
            local midpoint_x = (segment.start_x + segment.end_x) / 2
            local midpoint_y = (segment.start_y + segment.end_y) / 2
            local nx, ny = VectorLight.perpendicular(VectorLight.normalize(segment.end_x - segment.start_x, segment.end_y - segment.start_y))
            midpoint_x = midpoint_x + nx * random(-offset, offset)
            midpoint_y = midpoint_y + ny * random(-offset, offset)
            table.insert(segments, {start_x = segment.start_x, start_y = segment.start_y, end_x = midpoint_x, end_y = midpoint_y})
            ---[[
            if self.split_ends and love.math.random() < self.split_ends_chance then
                local direction_x, direction_y = midpoint_x - segment.start_x, midpoint_y - segment.start_y
                direction_x, direction_y = VectorLight.rotate(love.math.random(0, math.pi * 0.05), direction_x, direction_y)
                local random_length = random(0.5, 0.9)
                local split_end_x = midpoint_x + direction_x * random_length
                local split_end_y = midpoint_y + direction_y * random_length
                table.insert(segments, {start_x = midpoint_x, start_y = midpoint_y, end_x = split_end_x, end_y = split_end_y})
            end
            --]]
            table.insert(segments, {start_x = midpoint_x, start_y = midpoint_y, end_x = segment.end_x, end_y = segment.end_y})
        end
        offset = offset * 0.5
    end




end
function LightningLine:update(dt)
    LightningLine.super.update(self, dt)
end

function LightningLine:draw()
    for i = 1, #self.lines do
        local line = self.lines[i]
        local r, g, b = unpack(boost_color)
        love.graphics.setColor(r, g, b, self.alpha)
        love.graphics.setLineWidth(2.5)
        love.graphics.line(line.start_x, line.start_y, line.end_x, line.end_y)

        local r, g, b = unpack(default_color)
        love.graphics.setColor(r, g, b, self.alpha)
        love.graphics.setLineWidth(1.5)
        love.graphics.line(line.start_x, line.start_y, line.end_x, line.end_y)
    end
    love.graphics.setColor(default_color)
    love.graphics.setLineWidth(1)
end

function LightningLine:destroy()
    LightningLine.super.destroy(self)
end