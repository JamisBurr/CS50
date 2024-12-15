local skyYOffset = -55

-- Boss Class
Boss = {}
Boss.__index = Boss

-- Constructor
function Boss:new(x, y)
    local self = setmetatable({}, Boss)
    
    -- Properties Initialization
    self:initializeProperties(x, y)
    
    -- Sprite Sheets and Animations Initialization
    self:initializeSpriteSheets()
    self:initializeAnimations()
    
    -- State Queue Initialization
    self:initializeStateQueue()
    
    return self
end

function Boss:initializeProperties(x, y)
    
    -- Calculate the center position for the collider
    local colliderWidth, colliderHeight = 20, 30
    local centerX = x - colliderWidth / 2
    local centerY = y - colliderHeight / 2

    self.collider = world:newRectangleCollider(centerX, centerY, colliderWidth, colliderHeight, {collision_class = "Boss"})
    self.collider:setFixedRotation(true)

    self.hp = 10
    self.direction = 1
    self.speed = 75
    self.waitTimer = 0
    self.lastState = nil
    self.isAttacking = false
    self.isVanishing = false 
    self.isAppearing = false  
    self.isAbove = false
    self.attackHitboxWidth = 100  -- Width of the attack hitbox
    self.attackHitboxHeight = 10  -- Height of the attack hitbox
    self.attackHitboxesCreated = false
    self.attackHitboxes = {}      -- Table to store attack hitboxes
    self.attackRange = 35  
    self.collisionRange = 15
    self.canAttack = true
    self.hit = false    
    self.death = false    
    self.state = 'idle'
end

function Boss:initializeSpriteSheets()
    self.spriteSheets = {self}
    self.spriteSheets['boss'] = love.graphics.newImage("sprites/boss/boss(222x119).png")
    self.spriteSheets['airAttack'] = love.graphics.newImage("sprites/boss/boss_airAttack(246x121).png")
end

function Boss:initializeAnimations()
    local grids = {
        idle = anim8.newGrid(222, 119, self.spriteSheets.boss:getWidth(), self.spriteSheets.boss:getHeight()),
        move = anim8.newGrid(222, 119, self.spriteSheets.boss:getWidth(), self.spriteSheets.boss:getHeight()),
        vanish = anim8.newGrid(222, 119, self.spriteSheets.boss:getWidth(), self.spriteSheets.boss:getHeight()),
        appear = anim8.newGrid(222, 119, self.spriteSheets.boss:getWidth(), self.spriteSheets.boss:getHeight()),
        riseAttack = anim8.newGrid(222, 119, self.spriteSheets.boss:getWidth(), self.spriteSheets.boss:getHeight()),
        attack = anim8.newGrid(222, 119, self.spriteSheets.boss:getWidth(), self.spriteSheets.boss:getHeight()),
        airAttack = anim8.newGrid(246, 121, self.spriteSheets.airAttack:getWidth(), self.spriteSheets.airAttack:getHeight()),
        riseAirAttack = anim8.newGrid(222, 119, self.spriteSheets.boss:getWidth(), self.spriteSheets.boss:getHeight()),
        death = anim8.newGrid(222, 119, self.spriteSheets.boss:getWidth(), self.spriteSheets.boss:getHeight())
    }

    self.animations = {
        idle = anim8.newAnimation(grids.idle("1-9", 1), 0.1),
        move = anim8.newAnimation(grids.move("1-8", 4), 0.1),
        vanish = anim8.newAnimation(grids.vanish("1-7", 9), 0.1),
        appear = anim8.newAnimation(grids.appear("1-9", 10), 0.1),
        riseAttack = anim8.newAnimation(grids.riseAttack("5-13", 11), 0.1),
        attack = anim8.newAnimation(grids.attack("1-9", 2), 0.05),
        airAttack = anim8.newAnimation(grids.airAttack("1-30", 1), 0.1),
        riseAirAttack = anim8.newAnimation(grids.riseAirAttack("1-13", 11), 0.1),
        death = anim8.newAnimation(grids.death("1-36", 13), 0.1)
    }
    
    self.currentAnimation = self.animations['idle']
end

function Boss:initializeStateQueue()
    self.originalStateQueue = {
        'move', 'attack', 'wait',
        'move', 'attack', 'wait',
        'vanish', 'appear', 'moveAbovePlayer', 'wait', 'airAttack', 'wait',
    }
    self.stateQueue = {}
    for _, state in ipairs(self.originalStateQueue) do
        table.insert(self.stateQueue, state)
    end
    self.state = table.remove(self.stateQueue, 1)
    print("Initial State Queue: ", table.concat(self.stateQueue, ", "))
end

-- State Handlers
function Boss:handleIdleState(dt)
    if self.isAttacking then return end
    --print("Handling Idle State")
    
    local bx = self.collider:getPosition()
    self.direction = player.x < bx and -1 or 1
    self.currentAnimation = self.animations['idle']
end

function Boss:handleMoveState(dt)
    --print("Handling Move State")
    
    local bx, by = self.collider:getPosition()
    local dist = distance(bx, by, player.x, player.y)
    
    self.direction = player.x < bx and -1 or 1

    if dist <= self.attackRange then
        self.state = self:manageStateQueue()
        return
    else
        self.collider:setX(bx + self.speed * dt * self.direction)
        self.currentAnimation = self.animations['move']
    end
end

function Boss:handleMoveAbovePlayerState(dt)
    --print("Handling Move Above Player State")
    
    self.collider:setGravityScale(0)  -- Disable gravity for the boss        
    local bx, by = self.collider:getPosition()

    -- Determine the direction to move based on the player's position
    if player.x < bx then
        self.direction = -1
    else
        self.direction = 1
    end

    -- Update the boss's x position based on its speed and direction
    self.collider:setX(bx + self.speed * dt * self.direction)
    
    -- Set the current animation (you might want to have a flying/moving animation here)
    self.currentAnimation = self.animations['move']  -- Assuming 'move' animation represents the boss moving in the sky
    self.isAbove = true    
    -- Check if the boss's x-coordinate is close enough to the player's x-coordinate
    local xDifference = math.abs(bx - player.x)
    if xDifference <= 5 then  -- Change the value '5' to whatever threshold you find suitable   
        -- Dequeue the next state from the stateQueue using the manageStateQueue function
        self.state = self:manageStateQueue()           
        return
    end
end

function Boss:handleWaitState(dt)
    --print("Handling Wait State")
    
    self.currentAnimation = self.animations['idle']

    if not self.waitTimer or self.waitTimer <= 0 then
        self.waitTimer = 0.5
    end

    self.waitTimer = self.waitTimer - dt

    if self.waitTimer <= 0 then
        if self.nextStateAfterRise then
            --print("Transiting to next state after rise: ", self.nextStateAfterRise)
            self.state = self.nextStateAfterRise
            self.nextStateAfterRise = nil
        else
            local nextState = self:manageStateQueue()
             -- Add the debug prints here
            print("Current State Queue: ", table.concat(self.stateQueue, ", "))
            print("Next State from Queue: ", nextState)
            print("Transiting to next state from queue: ", nextState)
            self.state = nextState
        end
    end   
end

function Boss:handleVanishState(dt) 
    --print("Handling Vanish State")
    self.currentAnimation = self.animations['vanish']
    self.isVanishing = true
    self.collider:setGravityScale(0)  -- Prevent boss from being affected by gravity
end

function Boss:handleAppearState(dt)
    --print("Handling Appear State")

    self.currentAnimation = self.animations['appear']
    self.isAppearing = true
end

function Boss:createAttackHitboxes()
    local bx, by = self.collider:getPosition()
    -- Calculate the center position for the hitbox
    local hitboxX = bx - self.attackHitboxWidth / 2
    local hitboxY = by - self.attackHitboxHeight / 2

    -- Create a single hitbox centered on the boss
    local hitbox = world:newRectangleCollider(hitboxX, hitboxY, self.attackHitboxWidth, self.attackHitboxHeight, {collision_class = "BossAttack"})
    self.attackHitboxes = { hitbox }  -- Store the hitbox in the table
end


function Boss:destroyAttackHitboxes()
    print("Attempting to destroy attack hitboxes...")
    for i, hitbox in ipairs(self.attackHitboxes) do
        if hitbox ~= nil and not hitbox:isDestroyed() then
            print("Destroying hitbox:", i)
            hitbox:destroy()
        else
            print("Hitbox already destroyed or nil:", i)
        end
    end
    self.attackHitboxes = {}
    print("All hitboxes processed for destruction.")
end


function Boss:handleAttackState(dt)
    --print("Handling Attack State")

    if not self.isAttacking then 
        self.currentAnimation = self.animations['attack']
        self.currentAnimation:gotoFrame(1)        
        self.isAttacking = true
    end

    -- Check if the animation has reached a specific frame (e.g., second-to-last frame)
    -- Adjust the frame number according to when you want the attack to happen
    if self.currentAnimation.position == #self.currentAnimation.frames - 4 and not self.attackHitboxesCreated then
        self:createAttackHitboxes()
        self.attackHitboxesCreated = true
    end
end


function Boss:handleAirAttackState(dt)
    --print("Handling AirAttack State")

    self.currentAnimation = self.animations['airAttack']    
    
    -- Check if the current frame is the 7th frame
    if self.currentAnimation.position == 8 and self.isAbove then
        -- Reset self.isAbove to false
        self.isAbove = false
        -- Optionally, move the collider down here if required
        local bx, by = self.collider:getPosition()
        self.collider:setPosition(bx, by - skyYOffset)  -- Move the boss to the ground
    end
    -- Re-enable gravity for the boss
    self.collider:setGravityScale(0)  
end

function Boss:handleRiseAttackState(dt)
    
    --print("Handling Rise State")
    
    -- If the animation is not already set to 'rise' or if it's paused, then reset and start the animation.
    if self.currentAnimation ~= self.animations['riseAttack'] then       
        self.currentAnimation = self.animations['riseAttack']
        self.currentAnimation:gotoFrame(1)
        self.currentAnimation:resume()
    end
end

-- Rise Air Attack State
function Boss:handleRiseAirAttackState(dt)

    --print("Handling Rise Air Attack State")    
    local bx, by = self.collider:getPosition()
    if self.currentAnimation ~= self.animations['riseAirAttack'] then
        self.currentAnimation = self.animations['riseAirAttack']
        self.currentAnimation:gotoFrame(1)
        self.currentAnimation:resume()
    end
end

Boss.stateHandlers = {
    idle = Boss.handleIdleState,
    move = Boss.handleMoveState,
    wait = Boss.handleWaitState,
    vanish = Boss.handleVanishState,
    appear = Boss.handleAppearState,
    moveAbovePlayer = Boss.handleMoveAbovePlayerState,
    airAttack = Boss.handleAirAttackState,
    attack = Boss.handleAttackState,
    riseAttack = Boss.handleRiseAttackState,
    riseAirAttack = Boss.handleRiseAirAttackState,    
}

-- Update Method
function Boss:update(dt, index)
    -- Update the current animation
    self.currentAnimation:update(dt)   

    local bx, by = self.collider:getPosition()
    local dist = distance(bx, by, player.x, player.y)
        -- Check if player is within attack range and not invincible
    if dist <= self.collisionRange and not player.invincible then
        dealPlayerDamage(1)
    end
    

    -- Handle the completion of animations
    if self.currentAnimation.position == #self.currentAnimation.frames then

        if self.state == 'vanish' and self.isVanishing then
            local bx, by = self.collider:getPosition()
            self.collider:setPosition(bx, by + skyYOffset)  -- Move the boss to the sky
            self.state = self:manageStateQueue()
            self.currentAnimation:gotoFrame(1)
            self.isVanishing = false  -- Reset the vanishing flag    

        elseif self.state == 'appear' and self.isAppearing then                          
            self.state = self:manageStateQueue()
            self.currentAnimation:gotoFrame(1)
            self.isAppearing = false  -- Reset the appearing flag                 

        elseif self.state == 'attack' then
            self:destroyAttackHitboxes()
            self.isAttacking = false            
            self.attackHitboxesCreated = false
            self.state = self:manageStateQueue() 
            self.state = 'riseAttack'
            self.currentAnimation:gotoFrame(1)

        elseif self.state == 'airAttack' then   
            local bx, by = self.collider:getPosition()          
            self.state = 'riseAirAttack'            
            self.currentAnimation:gotoFrame(1)
            
        elseif self.state == 'riseAttack' then            
            self.state = self:manageStateQueue()
            self.currentAnimation:gotoFrame(1)

        elseif self.state == 'riseAirAttack' then             
            -- Restore the gravity for the boss
            self.collider:setGravityScale(1)                   
            self.state = self:manageStateQueue()
            self.currentAnimation:gotoFrame(1)    
        elseif self.state == 'wait' then
            self.currentAnimation:gotoFrame(1)
        end
    end

    -- If boss is attacking and the current state is not 'attack', return early
    if self.isAttacking and self.state ~= 'attack' then
        return
    end

    if self.stateHandlers[self.state] then
        -- Handle the current state irrespective of it being the same as the last state
        self.stateHandlers[self.state](self, dt, index)
    end

    -- If nextState exists, set the current state to nextState
    if nextState then
        self.state = nextState
    end

    self.lastState = self.state  -- Set the last state to the current state after executing it
end

-- Draw Method
function Boss:draw()
    local bx, by = self.collider:getPosition()

    -- Draw collider (for debugging)
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.rectangle("line", bx - 10, by - 15, 20, 30) -- half the collider size
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw Attack Hitboxes (for debugging)
    if self.isAttacking then
        love.graphics.setColor(1, 0, 0, 0.5)  -- Red color for hitboxes
        for _, hitbox in ipairs(self.attackHitboxes) do
            local hx, hy, hw, hh = hitbox:getX(), hitbox:getY(), self.attackHitboxWidth, self.attackHitboxHeight
            love.graphics.rectangle("fill", hx - hw / 2, hy - hh / 2, hw, hh)
        end
        love.graphics.setColor(1, 1, 1, 1)  -- Reset color to default
    end

    -- Pivot points
    local pivotX = 111  -- Half of 222
    local pivotY = 59.5  -- Half of 119

    -- Idle animation
    if self.currentAnimation == self.animations['idle'] then
        self.currentAnimation:draw(self.spriteSheets['boss'], bx + (-5 * self.direction), by - 44, nil, self.direction, 1, pivotX - 5, pivotY)
    
    -- Walk animation
    elseif self.currentAnimation == self.animations['move'] then          
        self.currentAnimation:draw(self.spriteSheets['boss'], bx + (-5 * self.direction), by - 44, nil, self.direction, 1, pivotX - 5, pivotY)
    
    -- Attack animation
    elseif self.currentAnimation == self.animations['attack'] then          
        self.currentAnimation:draw(self.spriteSheets['boss'], bx + (-5 * self.direction), by - 44, nil, self.direction, 1, pivotX - 5, pivotY)

    -- Rise animation
    elseif self.currentAnimation == self.animations['riseAttack'] then          
        self.currentAnimation:draw(self.spriteSheets['boss'], bx + (-5 * self.direction), by - 44, nil, self.direction, 1, pivotX - 5, pivotY)
    
    -- Vanish animation
    elseif self.currentAnimation == self.animations['vanish'] then
        self.currentAnimation:draw(self.spriteSheets['boss'], bx + (-5 * self.direction), by - 44, nil, self.direction, 1, pivotX - 5, pivotY)
    
    -- Appear animation
    elseif self.currentAnimation == self.animations['appear'] then
        self.currentAnimation:draw(self.spriteSheets['boss'], bx + (-5 * self.direction), by - 44, nil, self.direction, 1, pivotX - 5, pivotY)
    
    -- Air Attack animation
    elseif self.currentAnimation == self.animations['airAttack'] then
        if self.isAbove then
            self.currentAnimation:draw(self.spriteSheets['airAttack'], bx + (-5 * self.direction), by + 10, nil, self.direction, 1, pivotX + 7, pivotY + 1)  -- Adjusted pivot points for airAttack sprite
        else
            self.currentAnimation:draw(self.spriteSheets['airAttack'], bx + (-5 * self.direction), by - 45, nil, self.direction, 1, pivotX + 7, pivotY + 1)  -- Adjusted pivot points for airAttack sprite
        end

    -- Rise Air Attack animation
    elseif self.currentAnimation == self.animations['riseAirAttack'] then          
        self.currentAnimation:draw(self.spriteSheets['boss'], bx + (-5 * self.direction), by - 44, nil, self.direction, 1, pivotX - 5, pivotY)

    -- Death animation
    elseif self.currentAnimation == self.animations['death'] then
        self.currentAnimation:draw(self.spriteSheets['boss'], bx + (-5 * self.direction), by - 44, nil, self.direction, 1, pivotX - 5, pivotY)
    end
end

-- Usage:
bosses = {}  -- Collection of all active bosses

-- Utility Methods
function bossSpawn(x, y)
    local newBoss = Boss:new(x, y)
    table.insert(bosses, newBoss)
end

function bossUpdateAll(dt)
    for i = #bosses, 1, -1 do
        local boss = bosses[i]
        boss:update(dt)
        if boss.death then
            if boss.collider then
                boss.collider:destroy()
            end
            table.remove(bosses, i)
        end
    end
end

function bossDrawAll()
    for _, boss in ipairs(bosses) do
        boss:draw()
    end
end

function Boss:manageStateQueue()
    print("Before manageStateQueue - Current State: ", self.state, "State Queue: ", table.concat(self.stateQueue, ", "))
    
    if #self.stateQueue == 0 then
        for _, state in ipairs(self.originalStateQueue) do
            table.insert(self.stateQueue, state)
        end
        print("Re-initialized State Queue: ", table.concat(self.stateQueue, ", "))
    end
    
    local nextState = table.remove(self.stateQueue, 1)
    print("After manageStateQueue - Next State: ", nextState, "State Queue: ", table.concat(self.stateQueue, ", "))
    return nextState
end