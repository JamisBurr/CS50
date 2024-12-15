-- Define a Summoner class
Summoner = {}
Summoner.__index = Summoner

-- Constructor for creating a new Summoner instance
function Summoner:new(x, y)
    local self = setmetatable({}, Summoner)

    -- Initialization code..
    self.collider = world:newRectangleCollider(x, y, 14, 11, {collision_class = "Summoner"})
    self.collider:setFixedRotation(true)    
    self.initialY = y  -- Store the initial Y position 
    self.hp = 3 -- Set initial health
    self.direction = 1 -- Set initial direction
    self.speed = 15 -- Set speed   
    self.floatingHeight = 5 -- Height range for floating
    self.floatingSpeed = 2 -- Speed at which the Summoner floats up and down
    self.floatingOffset = 0 -- Current offset from the initial Y position
    self.isFloatingUp = true -- Direction of floating, true for up, false for down
    self.chaseRange = 150
    self.summonRange = 100 -- Range within which the summoner can summon ghouls
    self.summonInterval = 2.6 -- Time in seconds between summons
    self.summonTimer = self.summonInterval
    self.isSummoning = false
    self.ghoulCount = 0
    self.hit = false    
    self.hitTimer = 0
    self.hitAnimationTimer = 0.3
    self.death = false
    self.deathAnimationTimer = 0.5 -- Set death timer
    self.state = 'idle'
    
    self:loadSpritesheets() 
    self:createAnimations()   
    self.currentAnimation = self.animations['idle'] 

    return self
end

-- Loads sprite sheets for different animations
function Summoner:loadSpritesheets()
    -- Loading sprite sheets...    
    self.spriteSheets = {}
    self.spriteSheets['idle'] = love.graphics.newImage("sprites/summoner/idle.png")    
    self.spriteSheets['move'] = love.graphics.newImage("sprites/summoner/move.png")
    self.spriteSheets['summon'] = love.graphics.newImage("sprites/summoner/summon.png")
    self.spriteSheets['hit'] = love.graphics.newImage("sprites/summoner/hit.png")
    self.spriteSheets['death'] = love.graphics.newImage("sprites/summoner/death.png")
end

-- Creates animations for different states
function Summoner:createAnimations()
    -- Creating animations...
    local grids = {
        idle = anim8.newGrid(46, 44, self.spriteSheets['idle']:getWidth(), self.spriteSheets['idle']:getHeight()),     
        move = anim8.newGrid(46, 44, self.spriteSheets['move']:getWidth(), self.spriteSheets['move']:getHeight()), 
        summon = anim8.newGrid(46, 44, self.spriteSheets['summon']:getWidth(), self.spriteSheets['summon']:getHeight()), 
        hit = anim8.newGrid(46, 44, self.spriteSheets['hit']:getWidth(), self.spriteSheets['hit']:getHeight()), 
        death = anim8.newGrid(46, 44, self.spriteSheets['death']:getWidth(), self.spriteSheets['death']:getHeight()) 
    }
   
    self.animations = {}       
    self.animations['idle'] = anim8.newAnimation(grids.idle("1-6", 1), 0.1)
    self.animations['move'] = anim8.newAnimation(grids.move("1-6", 1), 0.1) 
    self.animations['summon'] = anim8.newAnimation(grids.summon("1-9", 1), 0.1)   
    self.animations['hit'] = anim8.newAnimation(grids.hit("1-3", 1), 0.1)
    self.animations['death'] = anim8.newAnimation(grids.death("1-10", 1), 0.05)    
end


-- Handles behavior when Summoner is in idle state
function Summoner:handleIdleState(dt)
    -- Logic for idle state...
    local sx, sy = self.collider:getPosition()
    local dist = distance(sx, sy, player.x, player.y)
    self.direction = player.x < sx and -1 or 1
    self.collider:setCollisionClass("Summoner")
    if dist < self.chaseRange and dist >= self.summonRange then
        self.state = 'move'
    elseif dist < self.summonRange and self.ghoulCount == 0 then
        self.isSummoning = true
        self.currentAnimation = self.animations['summon']
        self.currentAnimation:gotoFrame(1)
        self.summonTimer = self.summonInterval
        self.state = 'summon'
    else
    self.currentAnimation = self.animations['idle'] 
    end
end

-- Handles behavior when Summoner is moving
function Summoner:handleMoveState(dt)
    local sx, sy = self.collider:getPosition()
    local dist = distance(sx, sy, player.x, player.y)
    local x_diff = math.abs(sx - player.x)  -- Calculate the absolute difference in x position

    -- Define a threshold for how close in x-axis the player and summoner need to be to consider them aligned
    local x_threshold = 2  -- Adjust this value as needed

    self.direction = player.x < sx and -1 or 1  
    -- Check if player is within chase range and not aligned on x-axis
    if dist < self.chaseRange and x_diff > x_threshold then
        if dist < self.summonRange and not self.isSummoning and self.ghoulCount == 0 then            
            self.isSummoning = true
            self.currentAnimation = self.animations['summon']
            self.currentAnimation:gotoFrame(1)
            self.summonTimer = self.summonInterval
            self.state = 'summon'
        else
            self.collider:setX(sx + self.speed * dt * self.direction)
            self.currentAnimation = self.animations['move']
        end
    else
        -- Player is out of chase range or aligned on x-axis, return to idle state
        self.state = 'idle'
        self.currentAnimation = self.animations['idle']
    end
end

-- Handles summoning behavior of the Summoner
function Summoner:handleSummonState(dt)
    local sx, sy = self.collider:getPosition()
    local dist = distance(sx, sy, player.x, player.y)
    -- Summoning logic
    if self.isSummoning then
        self.summonTimer = self.summonTimer - dt
        self.collider:setCollisionClass("Summoner")
        if self.summonTimer <= 0 then
            ghoulSpawn(sx, sy, self)  -- Spawn ghoul at the summoner's position
            self.summonTimer = self.summonInterval
            self.isSummoning = false  -- Reset summoning state
            self.state = 'cooldown'  -- Transition to cooldown state
        end
    else
        -- Transition to summon state only if the player is within range and not aligned on x-axis
        local x_diff = math.abs(sx - player.x)
        local x_threshold = 2  -- Adjust this value as needed

        if dist < self.summonRange and x_diff > x_threshold and self.ghoulCount == 0 then           
            self.isSummoning = true
            self.currentAnimation = self.animations['summon']
            self.currentAnimation:gotoFrame(1)
            self.summonTimer = self.summonInterval
        elseif dist >= self.summonRange or x_diff <= x_threshold then
            self.state = 'idle'
        end
    end
end

-- Cooldown state after summoning
function Summoner:handleCooldownState(dt)  
    -- Logic for cooldown after summoning...  
    self.summonTimer = self.summonTimer - dt
    if self.summonTimer <= 0 then        
        self.state = 'idle'
    end    
    self.currentAnimation = self.animations['idle']
end

-- Hit State
function Summoner:handleHitState(dt)
    self.hitAnimationTimer = self.hitAnimationTimer - dt
    self.hitTimer = self.hitTimer - dt
    self.collider:setCollisionClass("EnemyHit")
    if self.hit and self.hitTimer <= 0 then
        self.hit = false 
        self.state = 'idle'
        summonerDealDamage(self, 1)            
    end
    
  
    if self.hit and self.hitAnimationTimer <= 1 then
        if not sounds.muted then
            playThrottledSoundEffect("assets/sfx/enemyHit.wav", 0.5)   
        end
    end
    
    if self.hit and self.hitAnimationTimer <= 0 then
        self.hitAnimationTimer = 0.3     
        self.currentAnimation = self.animations['idle']      
    end
end

-- Handles behavior when Summoner is dying
function Summoner:handleDeathState(dt) 
    -- Logic for death state...
    self.deathAnimationTimer = self.deathAnimationTimer - dt
    self.collider:setCollisionClass("EnemyHit")

    if self.hit and self.deathAnimationTimer <= 2 then
        if not sounds.muted then
            playThrottledSoundEffect("assets/sfx/enemyHit.wav", 0.5)   
        end
    end
    
    if self.deathAnimationTimer <= 0 then        
        self.death = true
    else
        self.currentAnimation = self.animations['death']
    end
end

-- State handler mapping
Summoner.stateHandlers = {
    -- Mapping states to their respective functions...
    idle = Summoner.handleIdleState,
    move = Summoner.handleMoveState,
    summon = Summoner.handleSummonState,
    cooldown = Summoner.handleCooldownState,
    hit = Summoner.handleHitState,
    death = Summoner.handleDeathState
}

-- Inside Summoner:update
function Summoner:update(dt, index)
    -- Update animations
    self.currentAnimation:update(dt)

    -- Handle states
    if self.stateHandlers[self.state] then
        self.stateHandlers[self.state](self, dt, index)
    end

    -- Floating logic
    if self.isFloatingUp then
        self.floatingOffset = self.floatingOffset + self.floatingSpeed * dt
        if self.floatingOffset >= self.floatingHeight then
            self.isFloatingUp = false
        end
    else
        self.floatingOffset = self.floatingOffset - self.floatingSpeed * dt
        if self.floatingOffset <= -self.floatingHeight then
            self.isFloatingUp = true
        end
    end

    -- Apply the floating offset to the Y position
    local sx, sy = self.collider:getPosition()
    self.collider:setY(self.initialY + self.floatingOffset)
end

-- Draws the Summoner on the screen
function Summoner:draw()
    -- Drawing based on current animation...
    local sx, sy = self.collider:getPosition() 

    -- Idle animation
    if self.currentAnimation == self.animations['idle'] then
        self.currentAnimation:draw(self.spriteSheets['idle'], sx - (9  * self.direction), sy, nil, self.direction, 1, 23, 22)

    -- Walk animation
    elseif self.currentAnimation == self.animations['move'] then          
        self.currentAnimation:draw(self.spriteSheets['move'], sx - (9  * self.direction), sy, nil, self.direction, 1, 23, 22)

    -- Attack animation
    elseif self.currentAnimation == self.animations['summon'] then          
        self.currentAnimation:draw(self.spriteSheets['summon'], sx - (9  * self.direction), sy, nil, self.direction, 1, 23, 22)

    -- Hit animation
    elseif self.currentAnimation == self.animations['hit'] then          
        self.currentAnimation:draw(self.spriteSheets['hit'], sx - (9  * self.direction), sy, nil, self.direction, 1, 23, 22)

    -- Death animation
    elseif self.currentAnimation == self.animations['death'] then          
        self.currentAnimation:draw(self.spriteSheets['death'], sx - (9  * self.direction), sy, nil, self.direction, 1, 23, 22)        
    end

-- Debug drawing for the collider
--[[ local sx, sy = self.collider:getPosition()
local colliderWidth = 14
local colliderHeight = 11
love.graphics.setColor(1, 0, 0, 0.5) -- Red color for visibility
love.graphics.rectangle("line", sx - colliderWidth / 2, sy - colliderHeight / 2, colliderWidth, colliderHeight)
love.graphics.setColor(1, 1, 1) -- Reset color to default ]]
end

-- Usage:
summoners = {} -- Collection of all active hives

-- Spawning and updating Summoners
function summonerSpawn(x, y)
    -- Function to spawn a new Summoner...
    local newSummoner = Summoner:new(x, y)
    table.insert(summoners, newSummoner)
end

-- Updates all Summoners
function summonerUpdateAll(dt)
    -- Function to update all Summoners...
    for i = #summoners, 1, -1 do
        local summoner = summoners[i]
        summoner:update(dt)

        if summoner.death then
            if summoner.collider then
                summoner.collider:destroy()
            end
            table.remove(summoners, i)
        end
    end
end

function summonerDrawAll()
    -- Function to draw all Summoners...
    for _, summoner in ipairs(summoners) do
        summoner:draw()
    end
end

-- Function to handle damage to the Summoner
function summonerDealDamage(summoner, amount)
    summoner.hp = summoner.hp - amount          
end 

function Summoner:ghoulDefeated() 
    self.ghoulCount = math.max(0, self.ghoulCount - 1)
end

-- Destroys the Summoner's collider
function Summoner:destroy()
    -- Cleanup when Summoner is destroyed...
    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end