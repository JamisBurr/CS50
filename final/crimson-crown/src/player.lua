local saveManager = require("saveManager")
local joystick

-- Player Initialization
function initializePlayer()
    setupPlayerPhysics()
    setupPlayerAnimations()
    setupPlayerControls()
    initializePlayerStates()    
end

function setupPlayerPhysics()
    playerStartX, playerStartY = 0, 0
    player = world:newRectangleCollider(playerStartX, playerStartY, 8, 18, {collision_class = "Player"})
    player:setFixedRotation(true)
end

function setupPlayerAnimations()    
    player.spriteSheets = {
    idle = love.graphics.newImage("sprites/player/idle(32x32).png"),
    run = love.graphics.newImage("sprites/player/run(32x32).png"),
    jump = love.graphics.newImage("sprites/player/jump(32x32).png"),
    fall = love.graphics.newImage("sprites/player/fall(48x32).png"),    

    idleSword = love.graphics.newImage("sprites/player/idleSword(32x32).png"),
    runSword = love.graphics.newImage("sprites/player/runSword(32x32).png"),
    jumpSword = love.graphics.newImage("sprites/player/jumpSword(32x32).png"),
    fallSword = love.graphics.newImage("sprites/player/fallSword(48x32).png"),    

    attack = love.graphics.newImage("sprites/player/Double Slash no VFX (48x32)_blueface.png"),
    teleport = love.graphics.newImage("sprites/player/death or teleport (168x79)_blueface.png"),
    appear = love.graphics.newImage("sprites/player/teleport appear (168x79)_blueface.png"),
    dash = love.graphics.newImage("sprites/player/Stab and spin throw with no VFX (168x79)_blueface.png"),
    hit = love.graphics.newImage("sprites/player/hit(32x32)_blueface.png"),
    deflect = love.graphics.newImage("sprites/player/charge(48x32).png"),  
    }

    -- Create grids for animations
    local idleGrid = anim8.newGrid(32, 32, player.spriteSheets.idle:getWidth(), player.spriteSheets.idle:getHeight())
    local idleSwordGrid = anim8.newGrid(32, 32, player.spriteSheets.idleSword:getWidth(), player.spriteSheets.idleSword:getHeight())
    local runGrid = anim8.newGrid(32, 32, player.spriteSheets.run:getWidth(), player.spriteSheets.run:getHeight())
    local runSwordGrid = anim8.newGrid(32, 32, player.spriteSheets.runSword:getWidth(), player.spriteSheets.runSword:getHeight())
    local jumpGrid = anim8.newGrid(32, 32, player.spriteSheets.jump:getWidth(), player.spriteSheets.jump:getHeight())
    local jumpSwordGrid = anim8.newGrid(32, 32, player.spriteSheets.jumpSword:getWidth(), player.spriteSheets.jumpSword:getHeight())
    local fallGrid = anim8.newGrid(48, 32, player.spriteSheets.fall:getWidth(), player.spriteSheets.fall:getHeight())
    local fallSwordGrid = anim8.newGrid(48, 32, player.spriteSheets.fallSword:getWidth(), player.spriteSheets.fallSword:getHeight())

    local attackGrid = anim8.newGrid(48, 32, player.spriteSheets.attack:getWidth(), player.spriteSheets.attack:getHeight())
    local teleportGrid = anim8.newGrid(168, 79, player.spriteSheets.teleport:getWidth(), player.spriteSheets.teleport:getHeight())
    local appearGrid = anim8.newGrid(168, 79, player.spriteSheets.appear:getWidth(), player.spriteSheets.appear:getHeight())
    local dashGrid = anim8.newGrid(168, 79, player.spriteSheets.dash:getWidth(), player.spriteSheets.dash:getHeight())
    local hitGrid = anim8.newGrid(32, 32, player.spriteSheets.hit:getWidth(), player.spriteSheets.hit:getHeight())
    local deflectGrid = anim8.newGrid(48, 32, player.spriteSheets.deflect:getWidth(), player.spriteSheets.deflect:getHeight())

    -- Create animations
    player.animations = {
        idle = anim8.newAnimation(idleGrid(1, '1-12'), 0.15),
        idleSword = anim8.newAnimation(idleSwordGrid(1, '1-12'), 0.15),
        run = anim8.newAnimation(runGrid(1, '1-8'), 0.08),
        runSword = anim8.newAnimation(runSwordGrid(1, '1-8'), 0.08),
        jump = anim8.newAnimation(jumpGrid(1, "1-4"), 0.1),
        jumpSword = anim8.newAnimation(jumpSwordGrid(1, "1-4"), 0.1),
        fall = anim8.newAnimation(fallGrid(1, "1-4"), 0.1),  
        fallSword = anim8.newAnimation(fallSwordGrid(1, "1-4"), 0.1),  
        attack = anim8.newAnimation(attackGrid(1, "3-7"), 0.090),     
        teleport = anim8.newAnimation(teleportGrid(1, "1-11"), 0.1),  
        appear = anim8.newAnimation(appearGrid(1, "1-11"), 0.1),  
        dash = anim8.newAnimation(dashGrid(1, "4-9"), 0.1), 
        hit = anim8.newAnimation(hitGrid(1, "1-2"), 0.15), 
        deflect = anim8.newAnimation(deflectGrid(1, "1-6"), 0.1), 
    }
end

function setupPlayerControls()
    joystick = love.joystick.getJoysticks()[1]
    _G["globalJoystick"] = joystick
end

function initializePlayerStates()
    player.direction = 1
    player.speed = 120
    player.grounded, player.moving = true, false
    player.attacking, player.dashing, player.deflecting  = false, false, false
    player.teleporting, player.appearing, player.teleportActive = false, false, false 
    player.jumping, player.falling = false, false
    player.dJumpAvailable = false
    player.death = false
    player.attackRange = 20
    player.attackCooldown = 0
    player.health = 1
    player.invincibilityDuration = 0.8
    player.invincible, player.invincibilityTimer = false, 0
    player.dashDelay = 0    

    -- Additional Player State Variables
    player.lungeTargetX = 0
    player.isLunging = false
    player.lungeProgress = 0
    player.lungeSpeed = 2 -- Speed of the lunge, adjust as necessary
    player.lungeDuration = 0.2 -- Duration of the lunge in seconds, adjust as necessary

    player.currentAnimation = player.animations['idle'] -- Initialize with a default animation

    canActions()
end

function canActions()
    -- Initialize player control states
    player.canMove = true
    player.canJump = true
    player.canDash = true
    player.canCharge = true
    player.canAttack = true
    player.canTeleport = true
    player.canAppear = true
end

initializePlayer()



function playerUpdate(dt)
    if player.body then       
        player:setCollisionClass("Player")
        player.x, player.y = player:getX(), player:getY()        
        player.grounded = #world:queryRectangleArea(player.x - 8, player.y, 16, 16, {"Platform"}) > 0

        movePlayer(dt)
        playerJump(dt)
        attackPlayer(dt)
        dashPlayer(dt)
        deflectPlayer(dt) 
        love.keypressed(key, scancode, isrepeat)
                
        local vx, vy = player:getLinearVelocity()


        if player.dashDelay > 0 then
            player.dashDelay = player.dashDelay - dt
            if player.dashDelay <= 0 then
                player.dashing = false
                player.currentAnimation = player.animations['idle']
                player.dashButtonPressed = false
            end
        end

        -- Check if the player has started jumping
        if player.jumpButtonPressed and not player.jumping then   
            player.jumping = true         
            resetJumpAnimation()            
        end

        -- Check if the player has started falling
        if not player.grounded and vy > 0 and not player.falling then
            player.falling = true
            player.jumping = false
            resetFallAnimation()
        elseif player.grounded then
            player.falling = false
        end      
 
        -- Handle damage collision
        if (player:enter("Ghoul") or player:enter("Summoner") or player:enter("Wasp") or player:enter("Spitter") or player:enter("BossAttack")) and not player.invincible then
            dealPlayerDamage(1)
        end
     
        -- Update animations
        if player.currentAnimation then
            player.currentAnimation:update(dt)
            updatePlayerAnimation(player:getLinearVelocity())  -- Extracted animation logic
        end     
    end
end

function updatePlayerAnimation(vx, vy)
    if not player.attacking and not player.dashing and not player.deflecting and not player.teleporting and not player.appearing then
        if player.hasSword then
            updateSwordAnimations(vy)
        else
            updateNonSwordAnimations(vy)
        end
    end
end

function updateSwordAnimations(vy)
    if player.grounded then
        if player.moving then 
            player.currentAnimation = player.animations['runSword']
        else
            player.currentAnimation = player.animations['idleSword']
        end
    else
        if player.falling then
            player.currentAnimation = player.animations['fallSword']
        elseif player.jumping then
            player.currentAnimation = player.animations['jumpSword']
        end
    end    
end

function updateNonSwordAnimations(vy)
    if player.grounded then
        if player.moving then 
            player.currentAnimation = player.animations['run']
        else
            player.currentAnimation = player.animations['idle']
        end
    else
        if player.falling then
            player.currentAnimation = player.animations['fall']            
        elseif player.jumping then
            player.currentAnimation = player.animations['jump']
        end
    end    
end

function playerStart(dt)
    if controller then        
        if joystick:isGamepadDown("start") or love.keyboard.isDown("escape") then
            if gameState == "play" then
                -- Pause the game and display the pause menu
                gameState = "pause"
            elseif gameState == "pause" then
                -- Unpause the game
                gameState = "play"
            end
        end    
    elseif keyboard then 
        if love.keyboard.isDown("escape") then
            if gameState == "play" then
                -- Pause the game and display the pause menu
                gameState = "pause"
            elseif gameState == "pause" then
                -- Unpause the game
                gameState = "play"
            end       
        end
    end
end

function dealPlayerDamage(amount)
    player.health = player.health - amount
    if player.health <= 0 then
        gameState = "death"  
        resetGame()             
    end
end

function swordGameStart()
    player.progress = "Sword"     
    saveManager.set("playerProgress", player.progress)  
    saveManager.set("elapsedTime", elapsedTime)  -- Save the current elapsed time     
    saveManager.save()   
end

function keyGameStart()
    player.progress = "Key"
    saveManager.set("playerProgress", player.progress)
    saveManager.set("elapsedTime", elapsedTime) 
    saveManager.save()
end

function dashGameStart()
    player.progress = "Dash" -- Load saved state  
    saveManager.set("playerProgress", player.progress)
    saveManager.set("elapsedTime", elapsedTime) 
    saveManager.save()
end

function dash2GameStart()
    player.progress = "Dash2" -- Load saved state 
    saveManager.set("playerProgress", player.progress)
    saveManager.set("elapsedTime", elapsedTime) 
    saveManager.save()
end

function teleportGameStart()
    player.progress = "Teleport" -- Load saved state  
    saveManager.set("playerProgress", player.progress)
    saveManager.set("elapsedTime", elapsedTime) 
    saveManager.save()
end

function deflectGameStart()
    player.progress = "Deflect" -- Load saved state  
    saveManager.set("playerProgress", player.progress)
    saveManager.set("elapsedTime", elapsedTime) 
    saveManager.save()
end   

function djumpGameStart()
    player.progress = "DJump" -- Load saved state  
    saveManager.set("playerProgress", player.progress)
    saveManager.set("elapsedTime", elapsedTime) 
    saveManager.save()
end  

function acquiredSword()
    player.hasSword = true        

    -- Save the updated state to a file
    saveManager.set("hasSword", player.hasSword)   
    saveManager.save()  
end

function acquiredKey()
    player.hasKey = true

    -- Save the updated state to a file
    saveManager.set("hasKey", player.hasKey)    
    saveManager.save()
end

function acquiredDash() 
    player.hasDash = true    -- Load saved state        

    -- Save the updated state to a file
    saveManager.set("hasDash", player.hasDash)    
    saveManager.save()
end

function acquiredDash2() 
    player.hasDash2 = true    -- Load saved state             

    -- Save the updated state to a file
    saveManager.set("hasDash2", player.hasDash2)
    saveManager.save()
end

function acquiredTeleport() 
    player.hasTeleport = true    -- Load saved state             

    -- Save the updated state to a file
    saveManager.set("hasTeleport", player.hasTeleport)   
    saveManager.save()
end

function acquiredDeflect() 
    player.hasDeflect = true    -- Load saved state          

    -- Save the updated state to a file
    saveManager.set("hasDeflect", player.hasDeflect)   
    saveManager.save()
end

function acquiredDJump() 
    player.hasDJump = true    -- Load saved state          

    -- Save the updated state to a file
    saveManager.set("hasDJump", player.hasDJump)   
    saveManager.save()
end

function movePlayer(dt)
    if player.canMove and not player.dashing and not player.deflecting and not player.teleporting and not player.appearing then
        if controller then
            handleControllerMovement(dt)
        elseif keyboard then
            if player.hasDash2 then
                player.speed = 140
            else
                player.speed = 120
            end  
            handleKeyboardMovement(dt)            
        end
    end
end

function handleControllerMovement(dt)
    local px, py = player:getPosition()
    local movingRight = joystick:isGamepadDown("dpright") or joystick:getAxis(1) > 0.5
    local movingLeft = joystick:isGamepadDown("dpleft") or joystick:getAxis(1) < -0.5

    if movingRight and not movingLeft then
        player:setX(px + player.speed * dt)
        player.direction = 1
        player.moving = true
    elseif movingLeft and not movingRight then
        player:setX(px - player.speed * dt)
        player.direction = -1
        player.moving = true
    else
        player.moving = false
    end
end

function handleKeyboardMovement(dt)
    local px, py = player:getPosition()
    local movingRight = love.keyboard.isDown("d")
    local movingLeft = love.keyboard.isDown("a")

    if movingRight and not movingLeft then
        player:setX(px + player.speed * dt)
        player.direction = 1
        player.moving = true
    elseif movingLeft and not movingRight then
        player:setX(px - player.speed * dt)
        player.direction = -1
        player.moving = true
    else
        player.moving = false
    end
end


function playerJump(dt)
    -- Check if the jump button is pressed
    local jumpInitiated = checkJumpInput()
    if player.canJump and not player.deflecting and not player.teleporting and not player.appearing then
        -- Reset double jump when grounded
        if player.grounded then        
            player.dJumpAvailable = player.hasDJump
        end

        -- Execute jump logic
        if jumpInitiated then
            local currentVelocityX, currentVelocityY = player:getLinearVelocity()

            -- Perform initial jump if grounded
            if player.grounded then
                player:setLinearVelocity(currentVelocityX, -330) -- Jump velocity
                player.grounded = false
                player.jumping = true
                resetJumpAnimation()
            -- Perform double jump if available and not grounded
            elseif player.dJumpAvailable then
                player:setLinearVelocity(currentVelocityX, -165) -- Half velocity for double jump
                player.dJumpAvailable = false -- Disable double jump until grounded again
                player.jumping = true
                resetJumpAnimation()
            end
        end
    end
end

function checkJumpInput()
    local jumpInitiated = false
    local joystick = love.joystick.getJoysticks()[1]

    if controller then
        if joystick:isGamepadDown("a") and not player.jumpButtonPressed then
            jumpInitiated = true
            player.jumpButtonPressed = true
        elseif not joystick:isGamepadDown("a") then
            player.jumpButtonPressed = false
        end
    elseif keyboard then
        if love.keyboard.isDown("space") and not player.jumpButtonPressed then
            jumpInitiated = true
            player.jumpButtonPressed = true
        elseif not love.keyboard.isDown("space") then
            player.jumpButtonPressed = false
        end
    end

    return jumpInitiated
end

-- Function to reset jump animation
function resetJumpAnimation()
    player.animations['jump']:gotoFrame(1)
    if player.hasSword then
        player.animations['jumpSword']:gotoFrame(1)
    end
end

function resetFallAnimation()
    player.animations['fall']:gotoFrame(1)
    if player.hasSword then
        player.animations['fallSword']:gotoFrame(1)
    end
end

function teleportPlayer(dt)
    -- Only proceed if the player has the teleport ability
    if not player.hasTeleport then
        return
    end

    -- Check if teleport can be initiated
    if player.grounded and not player.jumping and not player.attacking and not player.dashing and 
       not player.deflecting and not player.teleporting and not player.appearing then
        if (controller and joystick:isGamepadDown("y")) or (keyboard and love.keyboard.isDown("f")) then
            startTeleport()
        end
    end

    -- Update teleporting status
    if player.teleporting then
        updateTeleport(dt)
    end

    -- Update appearing after teleport
    if player.appearing then
        updateAppear(dt)
    end
end

function startTeleport()
    player.teleporting = true
    player.animations['teleport']:gotoFrame(1)
    player.currentAnimation = player.animations['teleport']
    player.teleportTimer = 1.1 -- Duration of the teleport animation
end
     
function updateTeleport(dt)
    player.teleportTimer = player.teleportTimer - dt
    if player.teleportTimer < 0 then
        player.appearing = true
        player.teleporting = false
        player.animations['appear']:gotoFrame(1)
        player.currentAnimation = player.animations['appear']
        player.teleportAnimationTimer = 1.1 -- Duration of the appear animation
    end
end
            
function updateAppear(dt)
    player.teleportAnimationTimer = player.teleportAnimationTimer - dt
    if player.teleportAnimationTimer < 0 then
        player.currentAnimation = player.animations['idle']
        player.appearing = false
        player.teleportActive = false
    end
end

function dashPlayer(dt)    
    -- Only proceed if the player has the dash ability
    if not player.hasDash then
        return
    end

    -- Handle dash delay and input
    updateDashDelay(dt)
    handleDashInput(dt)
    
    -- Handle the dash movement and animation
    if player.dashing then
        executeDash(dt)
        updateDashAnimation(dt)
    end
end

function updateDashDelay(dt)
    player.dashDelay = player.dashDelay - dt
end

function handleDashInput(dt)
    if not player.attacking and not player.dashing and not player.deflecting 
    and not player.teleporting and not player.appearing
    and isDashInput() and player.dashDelay <= 0 then
        startDash()
    end
end
function isDashInput()
    local dashInput = (controller and joystick:isGamepadDown("x")) or 
                      (keyboard and love.keyboard.isDown("r"))
    return dashInput and not player.dashButtonPressed
end

function startDash()
    player.dashButtonPressed = true
    player.animations['dash']:gotoFrame(1)
    player.currentAnimation = player.animations['dash']
    player.dashAnimationTimer = 0.5 -- Duration of the dash animation
    player.dashing = true
    player.dashDelay = 1.5
    love.audio.newSource("assets/sfx/playerAttack.wav", "static"):play()
end  

function executeDash(dt)
    local dashSpeed = player.hasDash2 and 220 or 200
    player:setX(player.x + dashSpeed * player.direction * dt)
end

function updateDashAnimation(dt)
    player.dashAnimationTimer = player.dashAnimationTimer - dt
    if player.dashAnimationTimer < 0 then           
        player.dashing = false
        player.dashButtonPressed = false     
        player.currentAnimation = player.animations['idle']     
    end
end         

function deflectPlayer(dt)
    -- Only proceed if the player has the deflect ability
    if not player.hasDeflect then
        return
    end

    -- Handle deflect input
    handleDeflectInput(dt)

    -- Update deflect animation and state
    if player.deflecting then
        updateDeflectAnimation(dt)
    end

    -- Handle invincibility
    updateInvincibility(dt)
end

function handleDeflectInput(dt)
    if player.grounded and not player.jumping and not player.attacking and not player.dashing and 
       not player.teleporting and not player.appearing and not player.deflecting then
        if isDeflectInput() then
            startDeflect()
        end
    end
end

function isDeflectInput()
    return (controller and joystick:isGamepadDown("b")) or 
           (keyboard and love.keyboard.isDown("q"))
end

function startDeflect()
    player.deflectButtonPressed = true
    player.animations['deflect']:gotoFrame(1)
    player.currentAnimation = player.animations['deflect']
    player.deflectAnimationTimer = 0.6 -- Duration of the deflect animation
    player.invincible = true
    player.invincibilityTimer = player.invincibilityDuration
    player.deflecting = true
end

function updateDeflectAnimation(dt)
    player.deflectAnimationTimer = player.deflectAnimationTimer - dt
    if player.deflectAnimationTimer < 0 then
        player.deflecting = false
        player.currentAnimation = player.animations['idle']
        player.deflectButtonPressed = false
    end
end

function updateInvincibility(dt)
    if player.invincible then
        player.invincibilityTimer = player.invincibilityTimer - dt
        if player.invincibilityTimer <= 0 then
            player.invincible = false
        end
    end
end

function attackPlayer(dt)
    -- Only proceed if the player can attack and has a sword
    if not player.hasSword then
        return
    end



    -- Handle attack input
    handleAttackInput(dt)
    updateAttackDelay(dt)

    -- Update attack animation and state
    if player.attacking then
        updateAttackAnimation(dt)
        performAttackActions(dt)
    end
end

function updateAttackDelay(dt)
    -- Decrease attack cooldown timer
    if player.attackCooldown > 0 then
        player.attackCooldown = player.attackCooldown - dt
    end
end

function handleAttackInput(dt)
    if player.dashing then
        return  -- Prevent attacking while dashing
    end
    
    if not player.attacking and not player.dashing and not player.deflecting 
       and not player.teleporting and not player.appearing 
       and player.attackCooldown <= 0 then  -- Check cooldown
        if isAttackInput() then
            startAttack()
            -- Implement lunge
        local lungeSpeed = 50 -- Adjust as necessary for lunge speed
        local currentVelocityX, currentVelocityY = player:getLinearVelocity()
        -- Add lunge speed to current horizontal velocity
        player:setLinearVelocity(currentVelocityX + player.direction * lungeSpeed, currentVelocityY)
        end
    end
end

function isAttackInput()
    local attackInput = (controller and joystick:isGamepadDown("rightshoulder")) or 
                        (keyboard and love.keyboard.isDown("c"))
    return attackInput and not player.attackButtonPressed and player.attackCooldown <= 0
end 

function startAttack()
    player.attackButtonPressed = true
    player.animations['attack']:gotoFrame(1)
    if not sounds.muted then
        love.audio.newSource("assets/sfx/playerAttack.wav", "static"):play()
    end  
    
    player.currentAnimation = player.animations['attack']
    player.attackAnimationTimer = 0.4 -- Duration of the attack animation
    player.attacking = true
    player.attackCooldown = 1  -- Set cooldown to 1 second
    player.attackActive = true  
    player.invincible = true -- Set the player to be invincible during the attack
    player.invincibilityTimer = player.attackAnimationTimer -- Set invincibility duration to the attack duration
end


function updateAttackAnimation(dt)
    player.attackAnimationTimer = player.attackAnimationTimer - dt
    if player.attackAnimationTimer < 0 then
        player.attacking = false
        player.currentAnimation = player.animations['idle']
        player.attackButtonPressed = false

        player.invincible = false -- Reset invincibility when attack ends
    end
end


function performAttackActions(dt)
    attackGhoul(dt)    
    attackSummoner(dt)
    attackWasp(dt)
    attackHive(dt)
    attackSpitter(dt)
end

function drawAttackLine()
    if player.attacking then
        local px, py = player:getPosition() -- Player's position
        local attackDistance = player.attackRange -- Attack range from player's data
        local endX = px + player.direction * attackDistance -- Calculate end point of the line
        local endY = py -- Assuming the attack is horizontal

        love.graphics.setColor(1, 0, 0) -- Set line color to red for visibility
        love.graphics.line(px, py, endX, endY) -- Draw the line
        love.graphics.setColor(1, 1, 1) -- Reset color to default
    end
end

function attackGhoul(dt)
    for i, ghoul in ipairs(ghouls) do
        
        local px, py = player.body:getPosition()
        local attackDistance = player.attackRange        
        local endX = px + player.direction * attackDistance
        local endY = py

        if player.attackActive then 
            local colliders = world:queryLine(px, py, endX, endY, {"Ghoul"})
            for i, ghoul in ipairs(ghouls) do
                if ghoul.state ~= 'spawn' and not ghoul.hit and ghoul.hitTimer <= 0 then
                    for _, collider in ipairs(colliders) do 
                        if collider == ghoul.collider then   
                            ghoul.hitTimer = 0.4  -- Reset animation timer 
                            ghoul.hitAnimationTimer = 0.2  -- Reset animation timer                    
                            ghoul.hit = true   
                            -- Update the direction the ghoul is facing based on the player's position
                            local gx, gy = ghoul.collider:getPosition()
                            ghoul.direction = player.x < gx and -1 or 1  -- Face towards the player 
                            if ghoul.hp <= 1 then
                                ghoul.state = 'death'
                            else                    
                                ghoul.state = 'hit'    
                                ghoul.currentAnimation = ghoul.animations['hit']
                                ghoul.currentAnimation:gotoFrame(1)
                            end                                                                    
                            local kbDistance = 80
                            local kbSpeed = 500
                            local angle = math.atan2(gy - py, gx - px)
                            local kbX = kbDistance * math.cos(angle)
                            local kbY = kbDistance * math.sin(angle)                 
                            ghoul.collider:setLinearVelocity(kbX, kbY)
                        end     
                    end          
                end
            end
        end
    end
end


function attackSummoner(dt)
     -- Only proceed if the spitter is within attack range
     for _, summoner in ipairs(summoners) do  
        local sx, sy = summoner.collider:getPosition()
        local px, py = player.body:getPosition()
        local attackDistance = player.attackRange
        local verticalAttackLimit = 10 -- The vertical range within which the player can attack

        -- Calculate end point of the attack line based on player's direction
        local endX = px + player.direction * attackDistance
        local endY = py  -- Assuming the attack is horizontal

        -- Check if Summoner is within attack range and not too far below the player
        if math.abs(sy - py) <= verticalAttackLimit then
            local colliders = world:queryLine(px, py, endX, endY, {"Summoner"})
            for _, collider in ipairs(colliders) do
                if collider == summoner.collider and not summoner.hit and summoner.hitTimer <= 0 then
                    summoner.hitTimer = 0.4  -- Reset animation timer 
                    summoner.hitAnimationTimer = 0.3  -- Reset animation timer
                    summoner.hit = true
                    -- Update the direction the summoner is facing based on the player's position              
                    summoner.direction = player.x < sx and -1 or 1  -- Face towards the player
                    if summoner.hp <= 1 then
                        summoner.state = 'death'                   
                    else
                        summoner.state = 'hit'
                        summoner.currentAnimation = summoner.animations['hit']
                        summoner.currentAnimation:gotoFrame(1)
                    end
                    local kbDistance = 15
                
                    local angle = math.atan2(sy - py, sx - px)
                    local kbX = kbDistance * math.cos(angle)
                    local kbY = kbDistance * math.sin(angle)
                    summoner.collider:setLinearVelocity(kbX, kbY)                    
                end
            end
        end
    end    
end
 

function attackWasp(dt)
    function attackWasp(dt)
        local px, py = player.body:getPosition()
        local attackDistance = player.attackRange
        local verticalRange = 5
        for i, wasp in ipairs(wasps) do
            local wx, wy = wasp.collider:getPosition()
            local dx, dy = wx - px, wy - py
            local distanceToWasp = math.sqrt(dx*dx + dy*dy)

            if distanceToWasp <= attackDistance and math.abs(dy) <= verticalRange then
                local normalizedDx, normalizedDy = dx / distanceToWasp, dy / distanceToWasp
                local endX = px + normalizedDx * attackDistance
                local endY = py + normalizedDy * attackDistance

                local colliders = world:queryLine(px, py, endX, endY, {"Wasp"})
                for _, collider in ipairs(colliders) do
                    if collider == wasp.collider and not wasp.hit and wasp.hitTimer <= 0 then
                        wasp.hitTimer = wasp.hitTimerDefault
                        wasp.hitAnimationTimer = wasp.hitAnimationTimerDefault  -- Reset animation timer                    
                        wasp.hit = true   
                        if wasp.hp <= 1 then
                            wasp.state = 'death'
                        else
                            wasp.state = 'hit'    
                            wasp.currentAnimation = wasp.animations['hit']
                            wasp.currentAnimation:gotoFrame(1)
                        end                                                                    
                        local kbDistance = 70
                        local kbSpeed = 500
                        local angle = math.atan2(wy - py, wx - px)
                        local kbX = kbDistance * math.cos(angle)
                        local kbY = kbDistance * math.sin(angle)                 
                        wasp.collider:setLinearVelocity(kbX, kbY)
                    end
                end
            end                 
        end
    end
end

function attackHive(dt)
    for i, hive in ipairs(hives) do
        local hx, hy = hive.collider:getPosition()
        local px, py = player.body:getPosition()
        local attackDistance = player.attackRange
        local verticalRange = 12

         -- Calculate end point of the attack line
         local dx, dy = hx - px, hy - py
         local distanceToHive = math.sqrt(dx*dx + dy*dy) 

        -- Only proceed if the summoner is within attack range
        if distanceToHive <= attackDistance and math.abs(dy) <= verticalRange then
            local normalizedDx, normalizedDy = dx / distanceToHive, dy / distanceToHive
            local endX = px + normalizedDx * attackDistance
            local endY = py + normalizedDy * attackDistance
            if player.attackActive and not hive.hit and hive.hitTimer <= 0 then                
                local colliders = world:queryLine(px, py, endX, endY, {"Hive"})
                for _, collider in ipairs(colliders) do             
                    hive.hitTimer = 0.4  -- Reset animation timer 
                    hive.hitAnimationTimer = 0.3  -- Reset animation timer
                    hive.hit = true  -- Mark the hive as hit
                    if hive.hp <= 1 then
                        hive.state = 'death'                       
                    else
                        hive.state = 'hit'    
                        hive.currentAnimation = hive.animations['hit']
                        hive.currentAnimation:gotoFrame(1)
                    end
                end
            end    
        end
    end
end

function attackSpitter(dt)
    for i, spitter in ipairs(spitters) do
        local sx, sy = spitter.collider:getPosition()
        local px, py = player.body:getPosition()
        local attackDistance = player.attackRange

        -- Calculate end point of the attack line based on player's direction
        local endX = px + player.direction * attackDistance
        local endY = py  -- Assuming the attack is horizontal

        -- Only proceed if the spitter is within attack range
        local colliders = world:queryLine(px, py, endX, endY, {"Spitter"})
        for _, collider in ipairs(colliders) do
            if collider == spitter.collider and not spitter.hit and spitter.hitTimer <= 0 then  
                -- Perform necessary actions when spitter is hit
                spitter.hitTimer = 0.4  -- Reset animation timer 
                spitter.hitAnimationTimer = 0.3  -- Reset animation timer                    
                spitter.hit = true               
                -- Update the direction the spitter is facing based on the player's position
                local sx, sy = spitter.collider:getPosition()
                spitter.direction = player.x < sx and -1 or 1  -- Face towards the player                 
                if spitter.hp <= 1 then
                    spitter.state = 'death'
                else
                    spitter.state = 'hit'    
                    spitter.currentAnimation = spitter.animations['hit']
                    spitter.currentAnimation:gotoFrame(1)
                end                                                                    
                local kbDistance = 70
                local kbSpeed = 500
                local angle = math.atan2(sy - py, sx - px)
                local kbX = kbDistance * math.cos(angle)
                local kbY = kbDistance * math.sin(angle)                 
                spitter.collider:setLinearVelocity(kbX, kbY) 
            end   
        end      
    end
end

soundEffectLastPlayed = {}
function playThrottledSoundEffect(source, delay)
    local lastPlayed = soundEffectLastPlayed[source] or 0
    local currentTime = love.timer.getTime()

    if currentTime - lastPlayed >= delay then
        love.audio.newSource(source, "static"):play()
        soundEffectLastPlayed[source] = currentTime
    end
end

function playerDraw()
    drawCurrentAnimation() -- For drawing the current animation of the player  
    --drawAttackLine()
end

function drawCurrentAnimation()
    if player.currentAnimation then
        local spriteSheet = determineSpriteSheet()
        if spriteSheet then
            local offsetX, offsetY = getAnimationOffset(spriteSheet)
            player.currentAnimation:draw(spriteSheet, player.x, player.y + 1, nil, 1 * player.direction, 1, offsetX, offsetY)
        else
            print("Error: spriteSheet is nil for current animation")
        end
    end
end

function determineSpriteSheet()
    -- Idle animation   
    if player.currentAnimation == player.animations['idle'] then        
        return player.spriteSheets['idle']
    elseif player.currentAnimation == player.animations['idleSword'] then
        return player.spriteSheets['idleSword']    

    -- Run animation
    elseif player.currentAnimation == player.animations['run'] then
        return player.spriteSheets['run']   
    elseif player.currentAnimation == player.animations['runSword'] then
        return player.spriteSheets['runSword']    

    -- Jump animation
    elseif player.currentAnimation == player.animations['jump'] then
        return player.spriteSheets['jump']
    elseif player.currentAnimation == player.animations['jumpSword'] then
        return player.spriteSheets['jumpSword'] 
          
    -- Fall animation
    elseif player.currentAnimation == player.animations['fall'] then
        return player.spriteSheets['fall']
    elseif player.currentAnimation == player.animations['fallSword'] then
        return player.spriteSheets['fallSword']   

    -- Attack animation   
    elseif player.currentAnimation == player.animations['attack'] then
        return player.spriteSheets['attack']

    -- Dash animation   
    elseif player.currentAnimation == player.animations['dash'] then     
        return player.spriteSheets['dash']       

    -- Deflect animation   
    elseif player.currentAnimation == player.animations['deflect'] then
        return player.spriteSheets['deflect']
        
    -- Teleport animation   
    elseif player.currentAnimation == player.animations['teleport'] then
        return player.spriteSheets['teleport']   

    -- Appear animation   
    elseif player.currentAnimation == player.animations['appear'] then
        return player.spriteSheets['appear']
    end   
end

function getAnimationOffset(spriteSheet)
    -- Example offsets, adjust these based on your sprite sheet configurations
    local offsets = {
        ['idle'] = {22, 22},
        ['idleSword'] = {22, 22},
        ['run'] = {20, 22},
        ['runSword'] = {20, 22},
        ['attack'] = {20, 22},
        ['jump'] = {20, 22},
        ['jumpSword'] = {20, 22},
        ['fall'] = {20, 22},
        ['fallSword'] = {20, 22}, 
        ['dash'] = {88, 70},  -- Special handling for dash        
        ['teleport'] = {55, 70},
        ['appear'] = {55, 70},
        ['deflect'] = {20, 22}   
    }

    local key = nil
    for k, sheet in pairs(player.spriteSheets) do
        if sheet == spriteSheet then
            key = k
            break
        end
    end

    if key and offsets[key] then
        return unpack(offsets[key])
    else
        return 0, 0 -- Default offset if none is found
    end
end