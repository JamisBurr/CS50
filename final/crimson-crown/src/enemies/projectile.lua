-- Define a Projectile class
Projectile = {}
Projectile.__index = Projectile

function Projectile:new(x, y, direction, horizontalSpeed)
    local self = setmetatable({}, Projectile)

    -- Initialize properties
    self.collider = world:newCircleCollider(x, y, 1, {collision_class = "Projectile"})
    self.x = x
    self.y = y
    self.horizontalSpeed = horizontalSpeed   
    self.verticalVelocity = -75  -- Initial upward velocity
    self.gravity = 150  -- Gravity pulling the projectile down   
    self.direction = direction  
    self.hasDealtDamage = false
    self.lifetime = 5
    self.deathAnimationTimer = 0  -- Initialize the death animation timer
    self.isDying = false -- Flag to track if the death animation has started
    -- Initialize sprites and animations
    self.spriteSheets = {self}
    self.spriteSheet = love.graphics.newImage("sprites/spitter/projectile/projectile(16x16).png")

    local projectileGrid = anim8.newGrid(16, 16, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {}
    self.animations['fly'] = anim8.newAnimation(projectileGrid("1-4", 1), 0.1)
    self.animations['death'] = anim8.newAnimation(projectileGrid("1-6", 3), 0.05)
    self.currentAnimation = self.animations['fly']

    return self
end

function handleProjectileCollision(projectile, dt)
    -- First, check if the projectile has already dealt its damage or not
    if projectile.hasDealtDamage then
        return
    end

    local projectileRange = 5  -- Adjust this based on the projectile's radius or damage radius
    local px, py = projectile.x, projectile.y  -- Assuming the projectile has x and y properties
    local dist = distance(px, py, player.x, player.y)

    -- If the player is within the projectile's damage range, deal damage
    if dist < projectileRange then
        dealPlayerDamage(1)
        projectile.hasDealtDamage = true
    end
end

function Projectile:update(dt)
    self.currentAnimation:update(dt)
    -- Horizontal movement
    self.x = self.x + self.horizontalSpeed * self.direction * dt

    -- Vertical movement with gravity
    self.verticalVelocity = self.verticalVelocity + self.gravity * dt
    self.y = self.y + self.verticalVelocity * dt

    -- Set the collider's position
    self.collider:setPosition(self.x, self.y)

    -- Check for collisions with the player
    if not self.hasDealtDamage and not player.invincible then
        local projectileRange = 5  -- Adjust based on the projectile's radius or damage radius
        local dist = distance(self.x, self.y, player.x, player.y)

        -- If the player is within the projectile's damage range, deal damage
        if dist < projectileRange then
            dealPlayerDamage(1)
            self.hasDealtDamage = true
        end
    end

    -- Decrease the projectile's lifetime
    self.lifetime = self.lifetime - dt

    -- Check for collision with walls or platforms
    local colliders = world:queryRectangleArea(self.x - 1, self.y - 1, 2, 2, {'Wall', 'Platform'})
    if #colliders > 0 and not self.isDying then
        self.currentAnimation = self.animations['death']
        self.deathAnimationTimer = 0.3  -- Duration of the death animation
        self.isDying = true
    end

    -- Handle the death animation timer
    if self.isDying then
        self.deathAnimationTimer = self.deathAnimationTimer - dt
        if self.deathAnimationTimer <= 0 then 
            self:destroy()
            return
        end
    end
end

function Projectile:draw()
    -- Determine the sprite's width and height if necessary (might need to adjust based on your setup)
    local sprite_width = self.spriteSheet:getWidth() 
    local sprite_height = self.spriteSheet:getHeight()
        
    -- Draw using the projectile's x and y values, adjusting for the sprite's center
    self.currentAnimation:draw(self.spriteSheet, self.x + -8.5, self.y + -8.5)
end

function Projectile:destroy()
    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
    self.destroyed = true  -- Add this line
end

-- Usage:
projectiles = {}  -- Collection of all active projectiles

local MIN_HORIZONTAL_SPEED = 40
local MAX_HORIZONTAL_SPEED = 100

-- When spawning a new projectile:
function projectileSpawn(x, y, direction)
    local horizontalSpeed = math.random(MIN_HORIZONTAL_SPEED, MAX_HORIZONTAL_SPEED)
    local newProjectile = Projectile:new(x, y, direction, horizontalSpeed)
    table.insert(projectiles, newProjectile)
end

-- When updating all projectiles in the game loop:
function projectileUpdateAll(dt)
    for i = #projectiles, 1, -1 do
        local projectile = projectiles[i]
        projectile:update(dt)
        if projectile.lifetime <= 0 or projectile.destroyed then
            table.remove(projectiles, i)
        end
    end
end

-- When drawing all projectiles in the game loop:
function projectileDrawAll()
    for _, projectile in ipairs(projectiles) do
        projectile:draw()
    end
end