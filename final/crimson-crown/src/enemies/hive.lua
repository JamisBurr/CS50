-- Define a Hive class
Hive = {}
Hive.__index = Hive

function Hive:new(x, y)
    local self = setmetatable({}, Hive)

    -- Initialize properties    
    self.collider = world:newRectangleCollider(x, y, 28, 28, {collision_class = "Hive"})
    
    self.collider:setGravityScale(0)
    self.waspCount = 0
    self.spawnInterval = 5 -- Time in seconds between spawns
    self.spawnTimer = self.spawnInterval
    self.hp = 3 -- Example hp value
    self.hit = false
    self.hitTimer = 0
    self.death = false
    self.hitAnimationTimer = 0.3   
    self.deathAnimationTimer = 0.8 -- Add damage immunity timer   
    self.state = 'idle'

    -- Load sprite sheets
    self.spriteSheets = {}
    self.spriteSheets['hive'] = love.graphics.newImage("sprites/hive/hive(78x43).png")
    
    -- Create animations
    local hiveGrid = anim8.newGrid(78, 43, self.spriteSheets['hive']:getWidth(), self.spriteSheets['hive']:getHeight())
    self.animations = {}
    self.animations['idle'] = anim8.newAnimation(hiveGrid("1-9", 2), 0.15)
    self.animations['hit'] = anim8.newAnimation(hiveGrid("1-3", 3), 0.1)
    self.animations['death'] = anim8.newAnimation(hiveGrid("1-8", 4), 0.1) 
    self.animations['dead'] = anim8.newAnimation(hiveGrid(8, 4), 0.1) 

    self.currentAnimation = self.animations['idle']

    return self
end

function Hive:handleIdleState(dt) 
    self.currentAnimation = self.animations['idle']    
end

function Hive:handleHitState(dt)             
    self.hitAnimationTimer = self.hitAnimationTimer - dt 
    self.hitTimer = self.hitTimer - dt 
    playThrottledSoundEffect("assets/sfx/enemyHit.wav", 0.5)
    if self.hit and self.hitTimer <= 0 then
        self.hit = false
        self.state = 'idle'
    end

    if self.hit and self.hitAnimationTimer <= 0 then    
        self.hitAnimationTimer = 0.3
        hiveDealDamage(self, 1)                          
        self.currentAnimation = self.animations['idle']         
    end   
end

function Hive:handleDeathState(dt)        
    self.deathAnimationTimer = self.deathAnimationTimer - dt

    if self.deathAnimationTimer <= 0 then        
        self.death = true
    else
        self.currentAnimation = self.animations['death']
    end
end

function Hive:handleDeadState(dt)
    self.currentAnimation = self.animations['dead']
end

Hive.stateHandlers = {  
    idle = Hive.handleIdleState,  
    hit = Hive.handleHitState,
    death = Hive.handleDeathState,
    dead = Hive.handleDeadState
}    

function Hive:update(dt, index)     
    local hx, hy = self.collider:getPosition()
    self.currentAnimation:update(dt)

    -- Wasp spawning logic
    if self.hp > 0 and self.waspCount < 1 and self.state ~= 'dead' then
        self.spawnTimer = self.spawnTimer - dt
        if self.spawnTimer <= 0 then
            waspSpawn(hx, hy, self)  -- Pass the hive object here
            self.waspCount = self.waspCount + 1
            self.spawnTimer = self.spawnInterval
        end
    end

    if self.stateHandlers[self.state] then
        self.stateHandlers[self.state](self, dt, index) 
    end
end


function Hive:draw()    
    local hx, hy = self.collider:getPosition()
    local width, height = 32, 32  -- Width and height of the collider

    -- Reset color to default if needed
    love.graphics.setColor(1, 1, 1)
    self.currentAnimation:draw(self.spriteSheets['hive'], hx - 35, hy - 16.5, nil, 1)
end

function Hive:waspDied()
    self.waspCount = math.max(0, self.waspCount - 1)  -- Ensure it doesn't go below zero
end

-- Usage:
hives = {} -- Collection of all active hives

-- When spawning a new hive:
function hiveSpawn(x, y)
    local newHive = Hive:new(x, y)
    table.insert(hives, newHive)    
end

-- When updating all hives in the game loop:
function hiveUpdateAll(dt)
    for i = #hives, 1, -1 do
        local hive = hives[i]
        hive:update(dt)  
        
        if hive.death then
            if hive.collider then
                hive.state = 'dead'
            end            
        end      
    end    
end

-- When drawing all hives in the game loop:
function hiveDrawAll()
    for _, hive in ipairs(hives) do
        hive:draw()
    end
end

function hiveDealDamage(hive, amount)    
    hive.hp = hive.hp - amount    
end

function Hive:destroy()
    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end