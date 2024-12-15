-- Define a local function to check if the wasp is within its roaming radius
local function isWithinRoamingRadius(initialX, initialY, newX, newY, radius)
    local dx = newX - initialX
    local dy = newY - initialY
    return (dx * dx + dy * dy) <= (radius * radius)
end

-- Define a Wasp class
Wasp = {}
Wasp.__index = Wasp

function Wasp:new(x, y, hive)
    local self = setmetatable({}, Wasp)

    -- Initialize properties
    self.collider = world:newRectangleCollider(x, y, 6, 6, {collision_class = "Wasp"})
    self.collider:setGravityScale(0)
    self.collider:setFixedRotation(true)
    self.hp = 1
    self.direction = 1
    self.baseSpeed = 30 -- Base speed
    self.speed = self.baseSpeed + math.random(0, 10) -- Vary speed
    self.initialX = x
    self.initialY = y    
    self.hive = hive  -- Store the reference to the hive    
    self.roamingRadius = 50 -- Example radius value, adjust as needed
    self.roamingCooldown = math.random(1, 3)
    self.roamingDirectionX = math.random(-1, 1)
    self.roamingDirectionY = math.random(-1, 1)
    self.roamingHeightLimit = hive.collider:getY()
    self.chaseRange = 75
    self.attackCooldownDuration = 3
    self.attackCooldownTimer = 0
    self.attackAnimationTimer = 0 
    self.directionChangeCooldown = math.random(2, 5)
    self.hit = false
    self.hitTimerDefault = 0.4
    self.hitTimer = 0
    self.hitAnimationTimerDefault = 0.2
    self.hitAnimationTimer = 0
    self.death = false       
    self.deathAnimationTimer = .25
    self.state = 'idle'

    -- Load sprite sheets
    self.spriteSheets = {}
    self.spriteSheets['wasp'] = love.graphics.newImage("sprites/wasp/wasp(16x16).png")

    -- Create animations
    local waspGrid = anim8.newGrid(16, 16, self.spriteSheets['wasp']:getWidth(), self.spriteSheets['wasp']:getHeight())
    self.animations = {}
    self.animations['idle'] = anim8.newAnimation(waspGrid("1-4", 1), 0.1)
    self.animations['hit'] = anim8.newAnimation(waspGrid("1-2", 3), 0.1)
    self.animations['death'] = anim8.newAnimation(waspGrid("1-5", 4), 0.05)

    self.currentAnimation = self.animations['idle']

    return self
end

-- Idle State
function Wasp:handleIdleState(dt)
    local wx, wy = self.collider:getPosition()
    local px, py = player.x, player.y
    local dist = distance(wx, wy, px, py)

    if dist < self.chaseRange then
        self.state = 'chase'
    else
        if self.roamingCooldown <= 0 then
            self:resetRoamingBehavior()
        else
            self.roamingCooldown = self.roamingCooldown - dt
        end

        -- Update position based on roaming directions
        local newPosX = wx + self.speed * dt * self.roamingDirectionX
        local newPosY = wy + self.speed * dt * self.roamingDirectionY

        -- Ensure the wasp stays within the roaming radius and below the hive's midpoint
        if isWithinRoamingRadius(self.initialX, self.initialY, newPosX, newPosY, self.roamingRadius) then
            -- Constrain newPosY to be above the hive's midpoint
            if newPosY < self.roamingHeightLimit then
                newPosY = self.roamingHeightLimit
            end
            self.collider:setPosition(newPosX, newPosY)  -- Set the new position of the wasp
        end

        if math.abs(newPosX - wx) > 0.1 or math.abs(newPosY - wy) > 0.1 then
            self.direction = self.roamingDirectionX > 0 and 1 or -1
        end
    end 

    self.currentAnimation = self.animations['idle']
end


-- Chase State
function Wasp:handleChaseState(dt)
    local wx, wy = self.collider:getPosition()
    local px, py = player.x, player.y
    local dx, dy = px - wx, py - wy
    local dist = math.sqrt(dx*dx + dy*dy)

    if dist > self.chaseRange then
        self.state = 'returnToHive'  -- New state when wasp is too far
    end

    -- Normalize direction
    local dirX, dirY = dx / dist, dy / dist

    -- Move towards the player
    self.collider:setX(wx + self.speed * dt * dirX)
    self.collider:setY(wy + self.speed * dt * dirY)

    -- Update direction based on X movement towards player
    if math.abs(dirX) > 0.1 then
        self.direction = dirX > 0 and 1 or -1
    end

    self.currentAnimation = self.animations['idle']

    -- If the wasp gets hit, move to Hit State  
    self.direction = dirX > 0 and 1 or -1
end

function Wasp:handleReturnToHiveState(dt)
    -- Generate a random target position near the hive the first time the state is entered
    if not self.returnTargetX or not self.returnTargetY then
        local hx, hy = self.hive.collider:getPosition()

        local angle = math.random() * math.pi
        local distance = math.random() * self.roamingRadius

        self.returnTargetX = hx + math.cos(angle) * distance
        self.returnTargetY = math.min(hy + math.sin(angle) * distance, self.roamingHeightLimit)
    end

    if self.returnTargetY > self.roamingHeightLimit then
        self.returnTargetY = self.roamingHeightLimit
    end

    local wx, wy = self.collider:getPosition()
    local dirX, dirY = self.returnTargetX - wx, self.returnTargetY - wy
    local dist = math.sqrt(dirX * dirX + dirY * dirY)

    -- Move towards the target position
    if dist > 1 then
        dirX, dirY = dirX / dist, dirY / dist
        self.collider:setX(wx + self.speed * dt * dirX)
        self.collider:setY(wy + self.speed * dt * dirY)
        self.direction = dirX > 0 and 1 or -1
    else
        -- Once reached, reset roaming behavior and switch to idle state
        self.returnTargetX, self.returnTargetY = nil, nil  -- Clear the target position
        self.state = 'idle'
        self:resetRoamingBehavior()
    end
end


-- Attack State
function Wasp:handleAttackState(dt)
    -- Logic for handling the 'hit' state of the wasp goes here
end


-- Hit State
function Wasp:handleHitState(dt)    
    
    self.hitAnimationTimer = self.hitAnimationTimer - dt
    self.hitTimer = self.hitTimer - dt  

    if self.hit and self.hitTimer <= 0 then
        self.hit = false   
        self.state = 'idle'       
    end        

    -- Once the hit animation is done, check if the wasp should die or go back to idle
    if self.hit and self.hitAnimationTimer <= 0 then
        self.hitAnimationTimer = 0.1         
        waspDealDamage(self, 1)
        self.currentAnimation = self.animations['idle']   
    end
end

-- Death State
function Wasp:handleDeathState(dt)    
    self.deathAnimationTimer = self.deathAnimationTimer - dt
    if self.deathAnimationTimer <= 0 then
        self.death = true        
    end
    self.currentAnimation = self.animations['death']
end

Wasp.stateHandlers = {
    idle = Wasp.handleIdleState,
    chase = Wasp.handleChaseState,    
    returnToHive = Wasp.handleReturnToHiveState,
    hit = Wasp.handleHitState,
    death = Wasp.handleDeathState
}

function Wasp:resetRoamingBehavior()
    -- X direction can still be random
    self.roamingDirectionX = math.random(-1, 1)

    -- Adjust Y direction to ensure wasps stay below the hive's midpoint
    -- Assuming that positive Y direction is downwards in your coordinate system
    local currentY = self.collider:getY()
    if currentY < self.roamingHeightLimit then
        -- If the wasp is above the limit, force it to move downwards
        self.roamingDirectionY = math.random(0, 1)
    else
        -- Otherwise, allow random upward or downward movement
        self.roamingDirectionY = math.random(-1, 1)
    end

    self.roamingCooldown = math.random(1, 3)
end

function Wasp:avoidObstacles(nearbyWalls, wx, wy)
    -- Find the closest wall
    local closestWall, minDist = nil, math.huge
    for _, wall in ipairs(nearbyWalls) do
        local wallX, wallY = wall:getPosition()
        local dist = distance(wx, wy, wallX, wallY)
        if dist < minDist then
            closestWall, minDist = wall, dist
        end
    end

    if closestWall then
        local wallX, wallY = closestWall:getPosition()
        -- Adjust roaming direction away from the wall
        if wallX > wx then
            self.roamingDirectionX = -1
        else
            self.roamingDirectionX = 1
        end

        if wallY > wy then
            self.roamingDirectionY = -1
        else
            self.roamingDirectionY = 1
        end
    end
end


function Wasp:update(dt, index)
    self.currentAnimation:update(dt)

    -- Collision detection and avoidance
    local avoidanceRange = 20 -- distance to check for obstacles
    local wx, wy = self.collider:getPosition()

    -- Check for nearby obstacles
    local nearbyWalls = world:queryRectangleArea(wx - avoidanceRange, wy - avoidanceRange, 2 * avoidanceRange, 2 * avoidanceRange, {'Wall', 'Platform'})
    if #nearbyWalls > 0 then
        -- Adjust direction away from the closest obstacle
        self:avoidObstacles(nearbyWalls, wx, wy)
    end

    -- Existing behavior
    if self.directionChangeCooldown <= 0 then
        self.direction = self.direction * -1 -- Change direction
        self.directionChangeCooldown = math.random(2, 5) -- Reset cooldown
    end

    if self.directionChangeCooldown <= 0 then
        self.speed = self.baseSpeed + math.random(-10, 10) -- Vary speed
    end

    if self.stateHandlers[self.state] then
        self.stateHandlers[self.state](self, dt, index) 
    end
end

function Wasp:draw()
    local wx, wy = self.collider:getPosition()
    local scaleX = self.direction
    -- Depending on the sprite orientation, you might need to adjust scaleX
    -- For instance, if the wasp sprite faces left by default, invert the scaleX when direction is 1
    scaleX = (self.direction == 1 and -1 or 1)
    self.currentAnimation:draw(self.spriteSheets['wasp'], wx, wy, nil, scaleX, 1, 8, 8)
end
    
function Wasp:die()
    if self.hive then
        self.hive:waspDied()  -- Notify the hive of the wasp's death
    end   
end

-- Usage:
wasps = {}  -- Collection of all active wasps

-- When spawning a new wasp:
function waspSpawn(x, y, hive)
    if not hive or not hive.collider then
        print("Error: Invalid hive or hive collider in waspSpawn")
        return
    end
    local newWasp = Wasp:new(x, y, hive)
    table.insert(wasps, newWasp)
end

-- When updating all wasps in the game loop:
function waspUpdateAll(dt)       
    for i = #wasps, 1, -1 do
        local wasp = wasps[i]
        wasp:update(dt)

        if wasp.death then
            if wasp.collider then
                wasp.collider:destroy()
                wasp:die()
            end
            table.remove(wasps, i)
        end
    end    
end

-- When drawing all wasps in the game loop:
function waspDrawAll()
    for _, wasp in ipairs(wasps) do
        wasp:draw()
    end
end

function waspDealDamage(wasp, amount)
    wasp.hp = wasp.hp - amount    
    if wasp.hp <= 0 then
        wasp.state = 'death'   
    end 
end


function Wasp:destroy()
    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end