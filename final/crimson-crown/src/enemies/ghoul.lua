-- Define a Ghoul class
Ghoul = {}
Ghoul.__index = Ghoul

-- Constructor for creating a new Ghoul instance
function Ghoul:new(x, y, summoner)
    local self = setmetatable({}, Ghoul)
    
    -- Initialization code..
    self.width = 5  -- Width of the Ghoul
    self.height = 20  -- Height of the Ghoul
    self.collider = world:newRectangleCollider(x, y, self.width, self.height, {collision_class = "Ghoul"})
    self.collider:setFixedRotation(true)
    self.hp = 2
    self.direction = 1
    self.speed = 40    
    self.attackRange = 25
    self.chaseRange = 150
    self.attackTimer = 0   
    self.attackAnimationTimer = 0
    self.damagePlayerTimer = 0
    self.hit = false
    self.hitTimer = 0    
    self.death = false  
    self.spawnAnimationTimer = 0.9
    self.hitAnimationTimer = 0.3
    self.deathAnimationTimer = 0.2
    self.summoner = summoner or nil   
    self.state = 'spawn'
    self.isCollidingWithWall = false  -- Initialize collision flag
        
    -- Load sprite sheets and create animations
    self.spriteSheets = {self}
    self.spriteSheets['spawn'] = love.graphics.newImage("sprites/ghoul/spawn.png")
    self.spriteSheets['asleep'] = love.graphics.newImage("sprites/ghoul/asleep.png")
    self.spriteSheets['wake'] = love.graphics.newImage("sprites/ghoul/wake.png")
    self.spriteSheets['idle'] = love.graphics.newImage("sprites/ghoul/idle.png")
    self.spriteSheets['walk'] = love.graphics.newImage("sprites/ghoul/walk.png")
    self.spriteSheets['attack'] = love.graphics.newImage("sprites/ghoul/attack.png")
    self.spriteSheets['hit'] = love.graphics.newImage("sprites/ghoul/hit.png")
    self.spriteSheets['death'] = love.graphics.newImage("sprites/ghoul/death.png")

    self.animations = {}
    local grids = {
        spawn = anim8.newGrid(62, 32, self.spriteSheets['spawn']:getWidth(), self.spriteSheets['spawn']:getHeight()),
        asleep = anim8.newGrid(62, 32, self.spriteSheets['asleep']:getWidth(), self.spriteSheets['asleep']:getHeight()),
        wake = anim8.newGrid(62, 32, self.spriteSheets['wake']:getWidth(), self.spriteSheets['wake']:getHeight()),
        idle = anim8.newGrid(62, 32, self.spriteSheets['idle']:getWidth(), self.spriteSheets['idle']:getHeight()),
        walk = anim8.newGrid(62, 32, self.spriteSheets['walk']:getWidth(), self.spriteSheets['walk']:getHeight()),
        attack = anim8.newGrid(62, 32, self.spriteSheets['attack']:getWidth(), self.spriteSheets['attack']:getHeight()),
        hit = anim8.newGrid(62, 32, self.spriteSheets['hit']:getWidth(), self.spriteSheets['hit']:getHeight()),
        death = anim8.newGrid(62, 32, self.spriteSheets['death']:getWidth(), self.spriteSheets['death']:getHeight())
    }

    self.animations['spawn'] = anim8.newAnimation(grids.spawn("1-9", 1), 0.1)
    self.animations['asleep'] = anim8.newAnimation(grids.asleep(1, 1), 0.1)
    self.animations['wake'] = anim8.newAnimation(grids.wake("1-4", 1), 0.1)
    self.animations['idle'] = anim8.newAnimation(grids.idle(1, 1), 0.1)
    self.animations['walk'] = anim8.newAnimation(grids.walk("1-9", 1), 0.1)
    self.animations['attack'] = anim8.newAnimation(grids.attack("1-7", 1), 0.1)
    self.animations['hit'] = anim8.newAnimation(grids.hit("1-2", 1), 0.15)
    self.animations['death'] = anim8.newAnimation(grids.death("1-8", 1), 0.05)

    self.currentAnimation = self.animations['idle']    
    return self
end

-- Handles behavior when Ghoul is in spawn state
function Ghoul:handleSpawnState(dt)
    self.collider:setCollisionClass("EnemyHit")
    -- Logic for spawn state...
    self.spawnAnimationTimer = self.spawnAnimationTimer - dt
    if self.spawnAnimationTimer <= 0 then
        self.state = 'idle'
        self.currentAnimation = self.animations['idle']
    else
        self.currentAnimation = self.animations['spawn']
    end
end

-- Handles behavior when Ghoul is idle
function Ghoul:handleIdleState(dt)
    -- Logic for idle state...
    local gx, gy = self.collider:getPosition()
    local dist = distance(gx, gy, player.x, player.y)
    self.direction = player.x < gx and -1 or 1
    self.collider:setCollisionClass("Ghoul")

    if dist < self.chaseRange then                  
        self.state = 'walk'                       
    end  
    self.currentAnimation = self.animations['idle']  
end

-- Handles behavior when Ghoul is walking
function Ghoul:handleWalkState(dt)
local gx, gy = self.collider:getPosition()
local dist = distance(gx, gy, player.x, player.y)
local x_diff = math.abs(gx - player.x)  -- Calculate the absolute difference in x position

-- Update the Ghoul's direction based on the player's position
self.direction = player.x < gx and -1 or 1

-- Define a threshold for how close in x-axis the player and ghoul need to be to consider them aligned
local x_threshold = 2  -- You can adjust this value as needed

-- Check if player is still within chase range and not aligned on x-axis
if dist < self.chaseRange and x_diff > x_threshold then
    -- Check if Ghoul is not colliding with a wall, then continue chasing or attack
    if not self.isCollidingWithWall then
        if dist < self.attackRange and self.attackTimer <= 0 then          
            self.state = 'attack'
            self.currentAnimation:gotoFrame(1)
            self.attackTimer = 2
        else
            self.collider:setX(gx + self.speed * dt * self.direction)
            self.currentAnimation = self.animations['walk']
        end
    else
        -- If Ghoul is colliding with a wall, go idle
        self.state = 'idle'
        self.currentAnimation = self.animations['idle']
    end
    self.attackTimer = self.attackTimer - dt
else
    -- Player is out of chase range or aligned on x-axis, return to idle state
    self.state = 'idle'
    self.currentAnimation = self.animations['idle']
end
end



-- Handles behavior when Ghoul is attacking
function Ghoul:handleAttackState(dt)
    if self.attackAnimationTimer <= 0 then       
        self.currentAnimation = self.animations['attack']
        self.currentAnimation:gotoFrame(1)
        self.attackAnimationTimer = 0.7 -- Duration of the attack animation
        self.damagePlayerTimer = 0.4 -- Damage triggers before the end of the attack animation
    end

    if self.damagePlayerTimer > 0 then
        self.damagePlayerTimer = self.damagePlayerTimer - dt
        if self.damagePlayerTimer <= 0 then
            -- Apply damage to player
            local gx, gy = self.collider:getPosition()
            local px, py = player:getX(), player:getY()  -- Assuming player has getX() and getY() methods
            local dist = distance(gx, gy, px, py)

            if dist < self.attackRange then
                if player.health and not player.invincible then
                    -- Deal damage to player
                    dealPlayerDamage(1)  -- Implement this function as needed
                end
            end
        end
    end

    -- Update attack animation timer
    self.attackAnimationTimer = self.attackAnimationTimer - dt
    if self.attackAnimationTimer <= 0 then
        self.state = 'idle'
    end
end

-- Helper function to calculate distance between two points
function distance(x1, y1, x2, y2)
    -- Distance calculation logic...
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Handles behavior when Ghoul is hit
function Ghoul:handleHitState(dt)
    -- Logic for hit state...
    self.hitAnimationTimer = self.hitAnimationTimer - dt 
    self.hitTimer = self.hitTimer - dt    
    if self.hit and self.hitTimer <= 0 then
        self.hit = false   
        self.state = 'idle'       
    end        

    if self.hit and self.hitAnimationTimer <= 1 then
        if not sounds.muted then
            playThrottledSoundEffect("assets/sfx/enemyHit.wav", 0.5)   
        end
    end

    if self.hit and self.hitAnimationTimer <= 0 then
        self.hitAnimationTimer = 0.3
        ghoulDealDamage(self, 1)
        self.collider:setCollisionClass("EnemyHit")
        self.currentAnimation = self.animations['idle']       
    end    
end

-- Handles behavior when Ghoul is dying
function Ghoul:handleDeathState(dt)
    -- Logic for death state...
    self.deathAnimationTimer = self.deathAnimationTimer - dt

    if self.hit and self.deathAnimationTimer <= 2 then
        if not sounds.muted then
            playThrottledSoundEffect("assets/sfx/enemyHit.wav", 0.5)   
        end
    end

    if self.deathAnimationTimer <= 0 then
        self.death = true
    end
    self.currentAnimation = self.animations['death']  
end

-- State handler mapping
Ghoul.stateHandlers = {
    -- Mapping states to their respective functions...
    spawn = Ghoul.handleSpawnState,
    idle = Ghoul.handleIdleState,
    walk = Ghoul.handleWalkState,
    attack = Ghoul.handleAttackState,  
    hit = Ghoul.handleHitState,
    death = Ghoul.handleDeathState
}

-- Updates the Ghoul each frame
function Ghoul:update(dt, index)
    
    -- Updating state and animation...
    self.currentAnimation:update(dt)
    if self.stateHandlers[self.state] then
        self.stateHandlers[self.state](self, dt, index)
    end

    if self.collider then
        -- Check for collision with walls in front of the Ghoul
        local gx, gy = self.collider:getPosition()
        -- Adjust the check position based on the Ghoul's direction
        local checkX = gx + (self.direction * 10)  -- 10 is a small offset to check ahead of the Ghoul
        local colliders = world:queryRectangleArea(checkX, gy, self.width, self.height, {'Wall'})
        self.isCollidingWithWall = #colliders > 0
    end
end

-- Draws the Ghoul on the screen
function Ghoul:draw()
    -- Drawing based on current animation...
    local gx, gy = self.collider:getPosition()

    -- Spawn animation
    if self.currentAnimation == self.animations['spawn'] then
        self.currentAnimation:draw(self.spriteSheets['spawn'], gx + (2.5 * self.direction), gy + 2, nil, self.direction, 1, 32, 22)    
    elseif self.currentAnimation == self.animations['idle'] then
        self.currentAnimation:draw( self.spriteSheets['idle'], gx + (2.5 * self.direction), gy + 2, nil, self.direction, 1, 32, 22)
        -- Walk animation
    elseif self.currentAnimation == self.animations['walk'] then          
        self.currentAnimation:draw( self.spriteSheets['walk'], gx + (2.5 * self.direction), gy + 2, nil, self.direction, 1, 32, 22)
        -- Attack animation
    elseif self.currentAnimation == self.animations['attack'] then          
        self.currentAnimation:draw( self.spriteSheets['attack'], gx + (2.5 * self.direction), gy + 2, nil, self.direction, 1, 32, 22)   
        -- Run animation
    elseif self.currentAnimation == self.animations['hit'] then          
        self.currentAnimation:draw( self.spriteSheets['hit'],  gx + (2.5 * self.direction), gy + 2, nil, self.direction, 1, 32, 22)
        -- Run animation
    elseif self.currentAnimation == self.animations['death'] then          
        self.currentAnimation:draw( self.spriteSheets['death'],  gx + (2.5 * self.direction), gy + 2, nil, self.direction, 1, 32, 22)
    end      
end

-- Usage:
ghouls = {}  -- Collection of all active ghouls

-- Functions for Ghoul management in the game loop

-- Spawns a new Ghoul
function ghoulSpawn(x, y, summoner)
    -- Function to spawn a new Ghoul...
    local newGhoul = Ghoul:new(x, y, summoner)  -- Create Ghoul with or without a summoner
    print("Spawning Ghoul at:", x, y)
    if summoner and summoner.ghoulCount == 0 then
        summoner.ghoulCount = summoner.ghoulCount + 1  -- Increment counter only if summoned by a Summoner
    end

    table.insert(ghouls, newGhoul)
end

    -- Updates all Ghouls
-- Updates all Ghouls
function ghoulUpdateAll(dt)
    for i = #ghouls, 1, -1 do
        local ghoul = ghouls[i]

        if ghoul and not ghoul.death then
            ghoul:update(dt)
            if ghoul.hp <= 0 then                
                ghoul.death = true
                -- Mark the ghoul for death but do not notify the summoner yet
            end
        end

        if ghoul and ghoul.death then
            -- Now that we're removing the ghoul, notify the summoner if it exists
            if ghoul.summoner and ghoul.summoner.ghoulDefeated then
                print("Ghoul died. Notifying summoner.")
                ghoul.summoner:ghoulDefeated()
            end
            if ghoul.collider then
                ghoul.collider:destroy()
            end
            table.remove(ghouls, i)
        end
    end
end

-- Draws all Ghouls
function ghoulDrawAll()
    -- Function to draw all Ghouls...
    for _, ghoul in ipairs(ghouls) do
        ghoul:draw()    
    end
end

-- Handles damage dealt to a Ghoul
function ghoulDealDamage(ghoul, amount)
    -- Applying damage to the Ghoul...
    print("Ghoul taking damage")
    ghoul.hp = ghoul.hp - amount      
end

-- Destroys the Ghoul's collider
function Ghoul:destroy()
    -- Cleanup when Ghoul is destroyed...
    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end