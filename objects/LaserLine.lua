LaserLine = GameObject:extend()



function LaserLine:new(area, x, y, opts)
    LaserLine.super.new(self, area, x, y, opts)
    self.depth = 75
    self.r = opts.r or 0
    self.d = opts.d or 300
    self.w = opts.w or 64

    self.area.world:setQueryDebugDrawing(true)
    
end

function Laser:query()
    local w_half, w_quarter = self.w * 0.5, self.w * 0.25

    local x, y = 0, 0
    local targets = {}

    x = self.x + w_half * math.cos(self.r + math.pi / 2)
    y = self.y + w_half * math.sin(self.r + math.pi / 2)
    local t_left1 = self.area.world:queryLine(
        x, 
        y, 
        x + self.d * math.cos(self.r), 
        y + self.d * math.sin(self.r), 
        {"Enemy", "EnemyProjectile"})

    x = self.x + w_quarter * math.cos(self.r + math.pi / 2)
    y = self.y + w_quarter * math.sin(self.r + math.pi / 2)
    local t_left2 = self.area.world:queryLine(
        x, 
        y, 
        x + self.d * math.cos(self.r), 
        y + self.d * math.sin(self.r), 
        {"Enemy", "EnemyProjectile"})
    
    local t_center = self.area.world:queryLine(
        self.x, self.y, 
        self.x + self.d * math.cos(self.r), 
        self.y + self.d * math.sin(self.r), 
        {"Enemy", "EnemyProjectile"})
    
    x = self.x + w_half * math.cos(self.r - math.pi / 2)
    y = self.y + w_half * math.sin(self.r - math.pi / 2)
    local t_right2 = self.area.world:queryLine(
        x, 
        y, 
        x + self.d * math.cos(self.r), 
        y + self.d * math.sin(self.r), 
        {"Enemy", "EnemyProjectile"})

    x = self.x + w_quarter * math.cos(self.r - math.pi / 2)
    y = self.y + w_quarter * math.sin(self.r - math.pi / 2)
    local t_right1 = self.area.world:queryLine(
        x, 
        y, 
        x + self.d * math.cos(self.r), 
        y + self.d * math.sin(self.r), 
        {"Enemy", "EnemyProjectile"})
    
    table.merge(targets, t_left2)
    table.merge(targets, t_left1)
    table.merge(targets, t_center)
    table.merge(targets, t_right1)
    table.merge(targets, t_right2)

    for i = 1, #targets do
        local target = targets[i]:getObject()
        if target then
            target:hit()
        end
    end
end


function LaserLine:update(dt)
    LaserLine.super.update(self, dt)
end

function LaserLine:draw()

end

function LaserLine:destroy()
    LaserLine.super.destroy(self)
end