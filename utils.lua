


function clamp(v, min, max)
    return math.max(math.min(v, max), min)
end


function UUID()
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end


function table.random(t)
    return t[love.math.random(1, #t)]
end

function table.randomKey(t)
    return table.random(table.keys(t))
end

function table.keys(t)
    local keys = {}
    for k,v in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end


function table.merge(t1, t2)
    local new_table = {}
    for key, value in pairs(t1) do new_table[key] = value end
    for key, value in pairs(t2) do new_table[key] = value end
    return new_table
end

function random(min, max)
    local min, max = min or 0, max or 1
    return (min > max and (love.math.random()*(min - max) + max)) or (love.math.random()*(max - min) + min)
end

function createIrregularPolygon(size, point_amount)
    local point_amount = point_amount or 8

    local points = {}
    local angle_step = (2.0 * math.pi) / point_amount
    for i = 1, point_amount do
        local current_angle = (i - 1) * angle_step 
        local rand_angle = current_angle + random(-angle_step * 0.25, angle_step * 0.25)
        local rand_size = size + random(-size * 0.25, size * 0.25)
        local x = rand_size * math.cos(rand_angle)
        local y = rand_size * math.sin(rand_angle)
        table.insert(points, x)
        table.insert(points, y)
    end
    return points
end

function pushRotate(x, y, r)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    love.graphics.translate(-x, -y)
end

function pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    love.graphics.scale(sx or 1, sy or sx or 1)
    love.graphics.translate(-x, -y)
end


function chanceList(...)
    return {
        chance_list = {},
        chance_definitions = {...},
        next = function (self)
            if #self.chance_list == 0 then
                for i = 1, #self.chance_definitions do
                    local definition = self.chance_definitions[i]
                    for v = 1, definition[2] do
                        table.insert(self.chance_list, definition[1])
                    end
                end
            end
            return table.remove(self.chance_list, math.random(1, #self.chance_list))
        end
    }
end


function distanceSquared(x1, y1, x2, y2)
    local xdif = x1 - x2
    local ydif = y1 - y2
    return xdif * xdif + ydif * ydif
end

function distance(x1, y1, x2, y2)
    return math.sqrt(distanceSquared(x1, y1, x2, y2))
end


function overlapRectangles(x, y, w, h, x2, y2, w2, h2)
    local left = x
    local right = x + w
    local top = y
    local bottom = y + h

    local left2 = x2
    local right2 = x2 + w2
    local top2 = y2
    local bottom2 = y2 + h2

    return not (left > right2 or right < left2 or top > bottom2 or bottom < top2)
end

--[[
function overlapRectangles(ax, ay, aw, ah, bx, by, bw, bh)
    local left_bound, right_bound, top_bound, bottom_bound

    left_bound = bx - aw
    if ax < left_bound then return false end

    right_bound = bx + bw
    if ax > right_bound then return false end

    top_bound = by - ah
    if ay < top_bound then return false end

    bottom_bound = by + bh
    if ay > bottom_bound then return false end

    return true
end
--]]