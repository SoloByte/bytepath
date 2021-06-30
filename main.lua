---@diagnostic disable: lowercase-global


Object = require "libs.classic"
Input = require "libs.boipushy.Input"
Timer = require "libs.enhanced-timer.EnhancedTimer"
fn = require "libs.moses.moses"
Camera = require "libs.hump.camera"
Physics = require "libs.windfield"
draft = require("libs.draft.draft")()

require "GameObject"
require "utils"
require "globals"


local flash_frames = nil
local current_room = nil


local function recursiveEnumerator(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)

    for _, item in ipairs(items) do
        local file = folder .. "/" .. item
        local info = love.filesystem.getInfo(file)
        if info.type == "file" then
            table.insert(file_list, file)
        elseif info.type == "directory" then
            recursiveEnumerator(file, file_list)
        end

        --if love.filesystem.isFile(file) then
        --    table.insert(file_list, file)
        --elseif love.filesystem.isDirectory(file) then
        --    recursiveEnumerator(file, file_list)
        --end
    end
end

local function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end

function printTable(t)
    for k, v in pairs(t) do
        print(k, v)
    end
end


function resize(s)
    love.window.setMode(gw * s, gh * s)
    sx, sy = s, s
end



function love.load()
    love.graphics.setDefaultFilter("nearest")
    love.graphics.setLineStyle("rough")

    local object_files = {}
    recursiveEnumerator("objects", object_files)
    requireFiles(object_files)

    local room_files = {}
    recursiveEnumerator("rooms", room_files)
    requireFiles(room_files)

    timer = Timer()
    input = Input()
    camera = Camera()


    slow_amount = 1.0

    
    input:bind("left", "left")
    input:bind("a", "left")
    input:bind("right", "right")
    input:bind("d", "right")

    input:bind("w", "up")
    input:bind("up", "up")
    input:bind("s", "down")
    input:bind("down", "down")

    --memory
    input:bind('f1', function()
        print("Before collection: " .. collectgarbage("count")/1024)
        collectgarbage()
        print("After collection: " .. collectgarbage("count")/1024)
        print("Object count: ")
        local counts = type_count()
        for k, v in pairs(counts) do print(k, v) end
        print("-------------------------------------")
    end)

    input:bind("f2", function ()
        gotoRoom("Stage")
    end)

    
    gotoRoom("Stage")

    resize(2)

    
    --love.window.setVSync(false)
    --local w, h, flags = love.window.getMode()
    --printTable(flags)
end


function love.update(dt)
    timer:update(dt*slow_amount)
    camera:update(dt*slow_amount)
    if current_room then current_room:update(dt*slow_amount) end
end



function love.draw()
    if current_room then current_room:draw() end

    love.graphics.print("FPS: " .. love.timer.getFPS(), 20, 20)

    if flash_frames then
        flash_frames = flash_frames - 1
        if flash_frames < 0 then flash_frames = nil end
    end
    if flash_frames then
        love.graphics.setColor(background_color)
        love.graphics.rectangle("fill", 0, 0, gw * sx, gh * sy)
        love.graphics.setColor(1, 1, 1, 1)
    end
end



function gotoRoom(room_type, ...)
    if current_room and current_room.destroy then
        current_room:destroy()
    end
    current_room = _G[room_type](...)
end


function slow(amount, duration)
    slow_amount = amount
    timer:tween("slow", duration, _G, {slow_amount = 1}, "in-out-cubic")
end


function flash(frames)
    flash_frames = frames
end
-- Memory -----------------------------
function count_all(f)
    local seen = {}
	local count_table
	count_table = function(t)
		if seen[t] then return end
		f(t)
		seen[t] = true
		for k,v in pairs(t) do
			if type(v) == "table" then
				count_table(v)
			elseif type(v) == "userdata" then
				f(v)
			end
		end
	end
	count_table(_G)
end

function type_count()
	local counts = {}
	local enumerate = function (o)
		local t = type_name(o)
		counts[t] = (counts[t] or 0) + 1
	end
	count_all(enumerate)
	return counts
end

global_type_table = nil
function type_name(o)
	if global_type_table == nil then
		global_type_table = {}
		for k,v in pairs(_G) do
			global_type_table[v] = k
		end
		global_type_table[0] = "table"
	end
	return global_type_table[getmetatable(o) or 0] or "Unknown"
end
--------------------------------------



function love.run()
    if love.math then love.math.setRandomSeed(os.time()) end
    if love.load then love.load(arg) end
    if love.timer then love.timer.step() end

    local dt = 0
    local fixed_dt = 1/60
    local accumulator = 0

    while true do
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == 'quit' then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        accumulator = accumulator + dt
        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt) end
            accumulator = accumulator - fixed_dt
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end






--room transition with persisent rooms

--[[
function love.load()
    rooms = {}
    current_room = nil
end

function love.update(dt)
    if current_room then current_room:update(dt) end
end

function love.draw()
    if current_room then current_room:draw() end
end

function addRoom(room_type, room_name, ...)
    local room = _G[room_type](room_name, ...)
    rooms[room_name] = room
    return room
end

function gotoRoom(room_type, room_name, ...)
    if current_room and rooms[room_name] then
        if current_room.deactivate then current_room:deactivate() end
        current_room = rooms[room_name]
        if current_room.activate then current_room:activate() end
    else current_room = addRoom(room_type, room_name, ...) end
end
--]]








    --[[
    hp_bar_main = {
        amount = 250,
        takeDamage = function (self, dmg)
            local final = self.amount - dmg
            if final < 0 then 
                final = 0
                timer:tween(0.5, self, {amount = final}, "in-out-cubic", function ()
                    self.amount = 250
                end)
            else
                timer:tween(0.5, self, {amount = final}, "in-out-cubic")
            end
        end
    }
    hp_bar_second = {
        amount = 250,
        takeDamage = function (self, dmg)
            local final = self.amount - dmg
            if final < 0 then 
                final = 0 
                timer:tween(1.0, self, {amount = final}, "in-out-cubic", function ()
                    self.amount = 250
                end)
            else
                timer:tween(1.0, self, {amount = final}, "in-out-cubic")
            end
        end
    }
    input:bind("space", function ()
        local dmg = love.math.random() * 100
        hp_bar_main:takeDamage(dmg)
        hp_bar_second:takeDamage(dmg)
    end)
    --]]

    --rect_1 = {x = 400, y = 300, w = 50, h = 200}
    --rect_2 = {x = 400, y = 300, w = 200, h = 50}
    --[[
    timer:tween(1, rect_1, {w = 0}, "in-out-cubic", function ()
        timer:tween(1, rect_2, {h = 0}, "in-out-cubic", function ()
            timer:tween(2, rect_1, {w = 50}, "in-out-cubic")
            timer:tween(2, rect_2, {h = 50}, "in-out-cubic")
        end)
    end)
    --]]
    --circle = {radius = 24}
    --[[
    timer:tween(6, circle, {radius = 96}, "in-out-cubic", function ()
        timer:tween(6, circle, {radius = 24}, "in-out-cubic")
        
    end)
    --]]

    --input:bind("q", function () print(math.random()) end)
    --input:bind("a", "timer")
    --input:bind("s", "timer")
    
    --[[
    timer:after(1, function (f)
        local time = love.math.random()
        print("every " .. time)
        timer:after(time, f)
    end)
    --]]


        --love.graphics.circle("fill", 400, 300, circle.radius)
    --love.graphics.rectangle('fill', rect_1.x - rect_1.w/2, rect_1.y - rect_1.h/2, rect_1.w, rect_1.h)
    --love.graphics.rectangle('fill', rect_2.x - rect_2.w/2, rect_2.y - rect_2.h/2, rect_2.w, rect_2.h)


    --love.graphics.setColor(0.8, 0.8, 0.8)
    --love.graphics.rectangle("fill", 400, 300, hp_bar_second.amount, 25)

    --love.graphics.setColor(0.8, 0.0, 0.0)
    --love.graphics.rectangle("fill", 400, 300, hp_bar_main.amount, 25)


        --[[
    if input:pressed("timer") then 
        print("start")
        timer:after(2, 
        function() 
            print(love.math.random())
            timer:after(1, function ()
                print(love.math.random())
                timer:after(0.5, function ()
                    print(love.math.random())
                end)
            end)
        end)
    end
    --]]
    --if input:released("timer") then print("a released") end
    --if input:down("timer", 0.5) then print("a down") end