-- Define a Spitter class
Spitter = {}
Spitter.__index = Spitter

function Spitter:new(x, y)
    local self = setmetatable({}, Spitter)

    -- Initialize properties
    self.collider = world:newRectangleCollider(x, y, 8, 20, {collision_class = "Spitter"})
    self.collider:setFixedRotation(true)
    self.hp = 3
    self.direction = 1
    self.speed = 35
    self.attackRange = 100
    self.chaseRange = 200
    self.closeChaseRange = 50 
    self.shootTimer = 0.5
    self.attackAnimationTimer = 0  
    self.hit = false
    self.hitTimer = 0
    self.hitAnimationTimer = 0.3
    self.death = false
    self.deathAnimationTimer = 0.45 
    self.state = 'idle'

    -- Load sprite sheets    
    self.spriteSheets = {self}    
    self.spriteSheets['idle'] = love.graphics.newImage("sprites/spitter/spitter/idle.png") 
    self.spriteSheets['walk'] = love.graphics.newImage("sprites/spitter/spitter/walk.png")
    self.spriteSheets['attack'] = love.graphics.newImage("sprites/spitter/spitter/attack.png")
    self.spriteSheets['hit'] = love.graphics.newImage("sprites/spitter/spitter/hit.png")
    self.spriteSheets['death'] = love.graphics.newImage("sprites/spitter/spitter/death.png")

    -- Create grids and animations    
    self.animations = {}
    local grids = {
        idle = anim8.newGrid(57, 39, self.spriteSheets['idle']:getWidth(), self.spriteSheets['idle']:getHeight()),
        walk = anim8.newGrid(57, 39, self.spriteSheets['walk']:getWidth(), self.spriteSheets['walk']:getHeight()),
        attack = anim8.newGrid(57, 39, self.spriteSheets['attack']:getWidth(), self.spriteSheets['attack']:getHeight()),
        hit = anim8.newGrid(57, 39, self.spriteSheets['hit']:getWidth(), self.spriteSheets['hit']:getHeight()),
        death = anim8.newGrid(57, 39, self.spriteSheets['death']:getWidth(), self.spriteSheets['death']:getHeight())
    }

    self.animations['idle'] = anim8.newAnimation(grids.idle("1-6", 1), 0.1)
    self.animations['walk'] = anim8.newAnimation(grids.walk("1-7", 1), 0.1)
    self.animations['attack'] = anim8.newAnimation(grids.attack("1-8", 1), 0.1)
    self.animations['hit'] = anim8.newAnimation(grids.hit("1-3", 1), 0.1)
    self.animations['death'] = anim8.newAnimation(grids.death("1-9", 1), 0.05)

    self.currentAnimation = self.animations['idle']
    return self
end

-- Idle State
function Spitter:handleIdleState(dt)
    local sx, sy = self.collider:getPosition()
    local dist = distance(sx, sy, player.x, player.y)
    self.direction = player.x < sx and -1 or 1
    self.collider:setCollisionClass("Spitter")

    if dist < self.chaseRange and dist >= self.attackRange then
        self.state = 'walk'
    elseif dist < self.closeChaseRange then
        self.state = 'walk'
    elseif dist < self.attackRange then
        self.state = 'attack' 
    end 
    self.currentAnimation = self.animations['idle'] 
end

-- Walk State
function Spitter:handleWalkState(dt)
    local sx, sy = self.collider:getPosition()
    local dist = distance(sx, sy, player.x, player.y)
    if dist < self.closeChaseRange then
        self.collider:setX(sx + self.speed * dt * self.direction)
        self.currentAnimation = self.animations['walk']
    elseif dist < self.attackRange then
        self.state = 'attack'
    elseif dist >= self.chaseRange then
        self.state = 'idle'  -- Transition back to idle if the player is outside the chase range
    else
        self.collider:setX(sx + self.speed * dt * self.direction)
        self.currentAnimation = self.animations['walk']
    end    
end

-- Attack State
function Spitter:handleAttackState(dt)
    if not self.attackAnimationTimer then
        local sx, sy = self.collider:getPosition()
        projectileSpawn(sx + (self.direction), sy - 10, self.direction)         
        self.currentAnimation = self.animations['attack']
        self.attackAnimationTimer = 0.8
    end

    if self.attackAnimationTimer then
        self.attackAnimationTimer = self.attackAnimationTimer - dt
        if self.attackAnimationTimer <= 0 then 
            self.attackAnimationTimer = nil
            self.shootTimer = 0.5
            self.state = 'cooldown'
        end
    end   
end

-- Cooldown State
function Spitter:handleCooldownState(dt)    
    self.shootTimer = self.shootTimer - dt
    if self.shootTimer <= 0 then        
        self.state = 'idle'
    end    
    self.currentAnimation = self.animations['idle']
end

-- Hit State
function Spitter:handleHitState(dt)    
    self.hitAnimationTimer = self.hitAnimationTimer - dt    
    self.hitTimer = self.hitTimer - dt      
    if self.hit and self.hitTimer <= 0 then
        self.hit = false   
        self.state = 'idle'      
        spitterDealDamage(self, 1)  
    end        

    if self.hit and self.hitAnimationTimer <= 1 then
        if not sounds.muted then
            playThrottledSoundEffect("assets/sfx/enemyHit.wav", 0.5)   
        end
    end

    if self.hit and self.hitAnimationTimer <= 0 then     
        self.hitAnimationTimer = 0.3        
        self.collider:setCollisionClass("EnemyHit")
        self.currentAnimation = self.animations['idle']       
    end    
end

-- Death State
function Spitter:handleDeathState(dt) 
    self.deathAnimationTimer = self.deathAnimationTimer - dt     
    self.collider:setCollisionClass("EnemyHit") 
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

Spitter.stateHandlers = {
    idle = Spitter.handleIdleState,
    walk = Spitter.handleWalkState,
    attack = Spitter.handleAttackState,
    cooldown = Spitter.handleCooldownState,
    hit = Spitter.handleHitState,
    death = Spitter.handleDeathState
}

function Spitter:update(dt, index)
    self.currentAnimation:update(dt)
    if self.stateHandlers[self.state] then
        self.stateHandlers[self.state](self, dt, index)
    end
end

function Spitter:draw()
    local sx, sy = self.collider:getPosition()

    -- Idle animation
    if self.currentAnimation == self.animations['idle'] then
        self.currentAnimation:draw(self.spriteSheets['idle'], sx + (-3 * self.direction), sy - 4, nil, self.direction, 1, 32, 22)
    -- Walk animation
    elseif self.currentAnimation == self.animations['walk'] then          
        self.currentAnimation:draw(self.spriteSheets['walk'], sx + (-3 * self.direction), sy - 4, nil, self.direction, 1, 32, 22)
    -- Attack animation
    elseif self.currentAnimation == self.animations['attack'] then          
        self.currentAnimation:draw(self.spriteSheets['attack'], sx + (-3 * self.direction), sy - 4, nil, self.direction, 1, 32, 22)
    -- Hit animation
    elseif self.currentAnimation == self.animations['hit'] then          
        self.currentAnimation:draw(self.spriteSheets['hit'], sx + (-3 * self.direction), sy - 4, nil, self.direction, 1, 32, 22)
    -- Death animation
    elseif self.currentAnimation == self.animations['death'] then          
        self.currentAnimation:draw(self.spriteSheets['death'], sx + (-3 * self.direction), sy - 4, nil, self.direction, 1, 32, 22)
    end    
end

-- Usage:
spitters = {}  -- Collection of all active spitters

-- When spawning a new spitter:
function spitterSpawn(x, y)
    local newSpitter = Spitter:new(x, y)
    table.insert(spitters, newSpitter)
end

-- When updating all spitters in the game loop:
function spitterUpdateAll(dt)
    for i = #spitters, 1, -1 do
        local spitter = spitters[i]
        spitter:update(dt)

        if spitter.death then
            if spitter.collider then
                spitter.collider:destroy()
            end
            table.remove(spitters, i)
        end
    end
end

-- When drawing all spitters in the game loop:
function spitterDrawAll()
    for _, spitter in ipairs(spitters) do
        spitter:draw()
    end
end

function spitterDealDamage(spitter, amount)
    spitter.hp = spitter.hp - amount  
end

function Spitter:destroy()
    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end