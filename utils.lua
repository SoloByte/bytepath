


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

function random(min, max)
    local min, max = min or 0, max or 1
    return (min > max and (love.math.random()*(min - max) + max)) or (love.math.random()*(max - min) + min)
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