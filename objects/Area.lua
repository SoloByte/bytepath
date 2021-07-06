Area = Object:extend()

function Area:new(room)
    self.room = room
    self.game_objects = {}
end

function Area:update(dt)
    if self.world then self.world:update(dt) end
    
    for i = #self.game_objects, 1, -1 do
        local game_object = self.game_objects[i]
        game_object:update(dt)
        if game_object.dead then 
            game_object:destroy()
            table.remove(self.game_objects, i) 
        end
    end
end

function Area:draw()
    --draws colliders (can be important for debugging)
    --if self.world then self.world:draw() end
    table.sort(self.game_objects, function (a, b)
        if a.depth == b.depth then 
            return a.creation_time < b.creation_time 
        else
            return a.depth < b.depth
        end
    end)
    for _, game_object in ipairs(self.game_objects) do game_object:draw() end
end


function Area:destroy()
    for i = #self.game_objects, 1, -1 do
        local game_object = self.game_objects[i]
        if game_object.dead then 
            game_object:destroy()
            table.remove(self.game_objects, i) 
        end
    end

    self.game_objects = {}

    if self.world then
        self.world:destroy()
        self.world = nil
    end
end

function Area:getAllGameObjectsThat(filter)
    local out = {}
    local count = #self.game_objects
    for i = 1, count do
        local go = self.game_objects[i]
        if filter(go) then table.insert(out, go) end
    end
    return out
end
function Area:addGameObject(game_object_type, x, y, opts)
    local opts = opts or {}
    local game_object = _G[game_object_type](self, x or 0, y or 0, opts)
    table.insert(self.game_objects, game_object)
    return game_object
end


function Area:addPhysicsWorld()
    self.world = Physics.newWorld(0,0, true)
end