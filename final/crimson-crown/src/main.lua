-- Initial setup for game variables and state
saveManager, elapsedTime, virtualMouse = nil, 0, nil 
        
-- Global variables for Game_Win position and size    

function love.load()                   
    requireLibraries()
    requireGameComponents()

    -- Initialization
    settingsInit()
    cameraInit()
    buttonsInit()
    worldInit()

    -- Entity and Map setup                    
    requireEntities()
    gameMap, gameState = sti("maps/Level1.lua"), "title"                                    
    initGraphicsAssets()
    initializeTimers()
    initializeGameVariables()                                                       
end

function requireLibraries()
    anim8 = require "libraries/anim8"
    wf = require "libraries/windfield"
    sti = require "libraries/sti"
    Timer = require "libraries/hump/timer"
    Talkies = require "libraries/talkies"
end

function requireGameComponents()
    saveManager = require("saveManager")
    local settings = require("settings")
    local camera = require("camera")
    local world = require("world")
    local buttons = require("buttons") 
    Npc = require("other")
    require("destroy")
end

function initGraphicsAssets()
    titleImage = love.graphics.newImage("assets/images/crimson_crown.png")
    deathImage = titleImage
    deathFont = love.graphics.newFont("assets/fonts/Pixel UniCode.ttf", 64)
    timerFont = love.graphics.newFont(20)
end

function initializeTimers()
    fadeOutTimer, fadeInTimer = 0, 0
end

function initializeGameVariables()                    
    entitiesToUpdate = {
        {entityName = "ghouls",    updateFunc = ghoulUpdateAll},
        {entityName = "spitters",  updateFunc = spitterUpdateAll},
        {entityName = "wasps",     updateFunc = waspUpdateAll},
        {entityName = "hives",      updateFunc = hiveUpdateAll},        
        {entityName = "summoners",  updateFunc = summonerUpdateAll},
        {entityName = "bosses",    updateFunc = bossUpdateAll},
        {entityName = "switch",    updateFunc = switchUpdate},
        {entityName = "gate",      updateFunc = gateUpdate},
        {entityName = "teleport",  updateFunc = teleportUpdate},
        {entityName = "shop",      updateFunc = shopUpdate},
        {entityName = "statue",    updateFunc = statueUpdate},
        {entityName = "watcher",   updateFunc = watcherUpdate}
    }

    layerSpawnMap = {
        ["Ghouls"] = ghoulSpawn,
        ["Spitters"] = spitterSpawn,
        ["Wasps"] = waspSpawn,
        ["Hives"] = hiveSpawn,        
        ["Summoners"] = summonerSpawn,
        ["Boss"] = bossSpawn,
        ["Switches"] = function(x, y, obj)           
            switchSpawn(x, y, obj.properties.gateID, obj.properties.enabledTimer, obj.properties.stopAnimationTimer) 
        end,
        ["Gates"] = function(x, y, obj) 
            gateSpawn(x, y, obj.properties.gateID, obj.properties.enabledTimer, obj.properties.stopAnimationTimer) 
        end,
        ["Teleports"] = teleportSpawn,        
        ["Shops"] = shopSpawn,
        ["Statues"] = statueSpawn,
        ["Watchers"] = watcherSpawn,
    }

    -- Initialize object layers
    platforms, walls, levels = {}, {}, {}

    -- Other game variables                   
    deathMessage = "You Died! Returning to Title Screen..."
    keyboard, controller, ePressed = true, false, false
    controllerCurrentButtonIndex = 1
    -- Add these near your existing controller button lists    
    controllerMuteAndInputButtonsList = {muteButton, inputButton}
    controllerTitleMenuButtonsList = {new_gameButton, continueButton, exitButton} -- Update this list as per your menu buttons
    controllerPauseButtonsList = {resumeButton, settingsButton, mainMenuButton}
    controllerSettingsButtonsList = {creditsButton, controlsButton, backButton}
    controllerCreditsButtonsList = {backButton}
    controllerControlsButtonsList = {backButton}
    dPadUpPressedLastFrame = false
    dPadDownPressedLastFrame = false
    dPadLeftPressedLastFrame = false
    dPadRightPressedLastFrame = false
    yButtonPressedLastFrame = false
    isInTransition = false  
    winTimer = 11
    savedData = saveManager.load()
    local _, config = saveManager.load()
    if config then
        keyboard = config.keyboard
        controller = config.controller
    end
    TalkiesLoad()
end

-- Add the love.resize function here
function love.resize(w, h)    
    SCREEN_WIDTH, SCREEN_HEIGHT = w, h
    updateScaleFactors()    
    buttonsInit()
end

-- Updating game state
function love.update(dt)
    love.timer.sleep(1/120)
    handleControllerYButtonPress()   
    updateGameState(dt)
    updateFadeTimers(dt)
    
    love.mouse.setGrabbed(true)

    local joystick = love.joystick.getJoysticks()[1]
    
    if joystick then
        if not joystick:isGamepadDown("dpup") then
            dPadUpPressedLastFrame = false
        end

        if not joystick:isGamepadDown("dpdown") then
            dPadDownPressedLastFrame = false
        end

        if not joystick:isGamepadDown("dpleft") then
            dPadLeftPressedLastFrame = false
        end

        if not joystick:isGamepadDown("dpright") then
            dPadRightPressedLastFrame = false
        end

        if not joystick:isGamepadDown("y") then
            yButtonPressedLastFrame = false
        end
    end

    if controller then
        if gameState == "title" then
            controllerCurrentButtonIndex = 1
        elseif gameState == "title.menu" and not muteAndInput and not settings and not credits and not controls then
            if dPadPressed("up") then
                if controllerCurrentButtonIndex == 1 then
                    muteAndInput = true
                    controllerCurrentButtonIndex = 1
                end
                controllerCurrentButtonIndex = math.max(1, controllerCurrentButtonIndex - 1)
            elseif dPadPressed("down") then
                controllerCurrentButtonIndex = math.min(#controllerTitleMenuButtonsList, controllerCurrentButtonIndex + 1)
            elseif dPadPressed("left") then
                muteAndInput = true
                controllerCurrentButtonIndex = 1
            elseif dPadPressed("right") then
                muteAndInput = true
                controllerCurrentButtonIndex = 2
            end 
        elseif gameState == "pause" and not muteAndInput and not settings and not credits and not controls then
            if dPadPressed("up") then
                if controllerCurrentButtonIndex == 1 then
                    muteAndInput = true
                    controllerCurrentButtonIndex = 1
                end
                controllerCurrentButtonIndex = math.max(1, controllerCurrentButtonIndex - 1)
            elseif dPadPressed("down") then
                controllerCurrentButtonIndex = math.min(#controllerPauseButtonsList, controllerCurrentButtonIndex + 1)
            elseif dPadPressed("left") then
                muteAndInput = true
                controllerCurrentButtonIndex = 1
            elseif dPadPressed("right") then
                muteAndInput = true
                controllerCurrentButtonIndex = 2
            end 
        elseif gameState == "pause" and not muteAndInput and settings then       
            if dPadPressed("up") then                
                controllerCurrentButtonIndex = math.max(1, controllerCurrentButtonIndex - 1)
            elseif dPadPressed("down") then
                controllerCurrentButtonIndex = math.min(#controllerSettingsButtonsList, controllerCurrentButtonIndex + 1)
            end        
        elseif gameState == "title.menu" and muteAndInput or "pause" and muteAndInput then
            if dPadPressed("left") then
                controllerCurrentButtonIndex = math.max(1, controllerCurrentButtonIndex - 1)
            elseif dPadPressed("right") then
                controllerCurrentButtonIndex = math.min(#controllerMuteAndInputButtonsList, controllerCurrentButtonIndex + 1)
            elseif dPadPressed("down") then
                muteAndInput = false
                controllerCurrentButtonIndex = 1                
            end                                    
        end
    end  
end

function dPadPressed(direction)
    local joystick = love.joystick.getJoysticks()[1] -- Get the first joystick
    if not joystick then return false end

    if direction == "up" then
        local isPressed = joystick:isGamepadDown("dpup")
        if isPressed and not dPadUpPressedLastFrame then
            dPadUpPressedLastFrame = true
            return true
        end
    elseif direction == "down" then
        local isPressed = joystick:isGamepadDown("dpdown")
        if isPressed and not dPadDownPressedLastFrame then
            dPadDownPressedLastFrame = true
            return true
        end
    elseif direction == "left" then
        local isPressed = joystick:isGamepadDown("dpleft")
        if isPressed and not dPadDownPressedLastFrame then
            dPadDownPressedLastFrame = true
            return true
        end        
    elseif direction == "right" then
        local isPressed = joystick:isGamepadDown("dpright")
        if isPressed and not dPadDownPressedLastFrame then
            dPadDownPressedLastFrame = true
            return true
        end
    end

    return false
end

function updateGameState(dt)
    if gameState == "title" or gameState == "title.menu" then
        if not isFading and sounds.music ~= sounds.titleMusic then
            isFading = true
            fadeOut = true
        end

        if fadeOut then
            if fadeOutMusic(dt) then  -- If fade out is complete
                fadeOut = false
                fadeIn = true
            end
        elseif fadeIn then
            if fadeInMusic(dt, sounds.titleMusic) then
                fadeIn = false
                isFading = false
            end
        end        

        titleVolume(dt)
    elseif gameState == "play" then
        updatePlayState(dt)   
        gameVolume(dt)
    elseif gameState == "pause" then        
        menuVolume(dt)
    elseif gameState == "win" then
        winVolume(dt)
        updateWinState(dt)
    elseif gameState == "death" then
        deadVolume(dt)
        updateDeathState(dt)
    end
end

function updatePlayState(dt)       
    elapsedTime = elapsedTime + dt      

    -- Functions
    world:update(dt)
    gameMap:update(dt)                
    playerUpdate(dt)  
    playerJump(dt)
    playerStart(dt)
    projectileUpdateAll(dt)
    
    for _, entityData in ipairs(entitiesToUpdate) do
        local entity = _G[entityData.entityName]  -- dynamically get the global variable by name
        if entity then
            entityData.updateFunc(dt)
        end
    end
    
    if player.body then 
        local px, py = player:getPosition()
        camX, camY = px, py - 25

        for doorName, door in pairs(departureDoors) do
            local colliders = world:queryCircleArea(door.x + 8, door.y + 8, 10, {"Player"})
            if #colliders > 0 then                                  
                if saveManager.get("currentLevel") ~= door.destinationMap then
                    loadMap(door.destinationMap)  -- Load the target map immediately
                    fadeInTimer = 1  -- Start the fade-in effect immediately
                end
        
                local destination = arrivalDoors[door.destinationDoor]
                if destination then
                    player:setX(destination.x + 8)
                    player:setY(destination.y)
                end        
                break  -- Exit the loop once the door is processed
            end
        end

        -- Collision detection with Game_Win object
        local colliders = world:queryRectangleArea(px - 8, py, 12, 16, {"GameWin"})
        if #colliders > 0 then
            gameState = "win"
            winTimer = 12
        end

        local collidingWithTranspad = false
        local currentTranspad = nil

        for transpadName, transpad in pairs(departureTranspads) do
            local colliders = world:queryCircleArea(transpad.x + 14, transpad.y + 6, 16, {"Player"})
            if #colliders > 0 and not teleportActivated then
                collidingWithTranspad = true
                if not player.teleporting and player.appearing and not player.teleportActive then              
                    -- Move the player to the destination once teleportation animation is complete
                    local destination = arrivalTranspads[transpad.destinationTranspad]
                    if destination then                              
                        player:setX(destination.x + 7)
                        player:setY(destination.y + 6)  
                        player.teleportActive = true                           
                    end
                    break                
                end                     
            end                
        end   

        if collidingWithTranspad then                
            teleportPlayer(dt)  -- This would be the function from player.lua that handles teleportation                
        end   
    -- Call the updateFadeTimers function
    updateFadeTimers(dt)                           
    end             
end

function updateWinState(dt) 
    if gameState == "win" then
        winTimer = winTimer - dt
        if winTimer <= 0 then
            -- Reset game or go to a specific state after death
            fadeInTimer = 1
            gameState = "title.menu"
            resetGame()  
        end
    end
end   

function updateDeathState(dt)
    if gameState == "death" then
        deathTimer = deathTimer - dt
        if deathTimer <= 0 then
            -- Reset game or go to a specific state after death
            fadeInTimer = 1
            gameState = "title.menu"
        end
    end
end     

function updateFadeTimers(dt)
    if fadeOutTimer > 0 then
        fadeOutTimer = math.max(fadeOutTimer - dt, 0)
    end

    if fadeInTimer > 0 then
        fadeInTimer = math.max(fadeInTimer - dt, 0)
    end
end

function fadeOutDraw()
    if fadeOutTimer > 0 then
        love.graphics.setColor(0, 0, 0, 1 - fadeOutTimer)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)  -- Resetting color to default
    end
end

function fadeInDraw()
    if fadeInTimer > 0 then
        love.graphics.setColor(0, 0, 0, fadeInTimer)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)  -- Resetting color to default
    end
end

-- Drawing function
function love.draw()
    -- Draw based on game state
    love.graphics.push()
    love.graphics.setCanvas(virtualCanvas)
    drawGameState()    

    -- Draw custom circle cursor if keyboard is in control
    if keyboard and gameState ~= "play" then
        -- Get actual mouse position
        local mouseX, mouseY = love.mouse.getPosition()
        -- Adjust mouse position based on the virtual resolution scaling
        local virtualMouseX = (mouseX - offsetX) / scaleX
        local virtualMouseY = (mouseY - offsetY) / scaleY
        -- Set the color for the cursor (using 236, 183, 122 as RGB values)
        local red = 236 / 255
        local green = 183 / 255
        blue = 122 / 255
        love.graphics.setColor(red, green, blue)
        -- Draw custom circle cursor at the adjusted position
        love.graphics.circle("fill", virtualMouseX, virtualMouseY, 4)  -- Using 10 as the radius for the cursor
        -- Reset color to white
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.setCanvas()
    love.graphics.origin()
    love.graphics.draw(virtualCanvas, offsetX, offsetY, 0, scaleX, scaleY)
    love.graphics.pop()
end

function draw_common_game_elements()                    
    local px, py = player:getPosition()        
    local centerX, centerY = VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2
    local dx, dy = px - centerX, py - centerY   
end

function drawBackground(color)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

function drawTextWithBorder(text, fontSize, x, y, align, borderColor, textColor, borderWidth)
    local font = love.graphics.newFont("assets/fonts/Pixel UniCode.ttf", fontSize)
    love.graphics.setFont(font)

    -- Set a default color if textColor is not provided
    if not textColor then
        textColor = {1, 1, 1} -- Default to white
    end
    local r, g, b = textColor[1], textColor[2], textColor[3]

    -- Only draw the border if borderColor and borderWidth are provided
    if borderColor and borderWidth then
        local br, bg, bb = borderColor[1], borderColor[2], borderColor[3]
        love.graphics.setColor(br, bg, bb, 1)  -- Border color

        -- Draw the border by offsetting the text slightly in multiple directions
        for i = -borderWidth, borderWidth do
            for j = -borderWidth, borderWidth do
                if i ~= 0 or j ~= 0 then  -- Avoid drawing the border over the main text
                    love.graphics.printf(text, x + i, y + j, VIRTUAL_WIDTH, align)
                end
            end
        end
    end

    -- Main text
    love.graphics.setColor(r, g, b, 1)  -- Main text color using the specified hex color
    love.graphics.printf(text, x, y, VIRTUAL_WIDTH, align)

    -- Reset the color to white (default)
    love.graphics.setColor(1, 1, 1, 1)
end


function drawGameState()        
    if gameState == "title" or gameState == "title.menu" then 
        drawTitleScreen()         
        updateMouseVisibility()    
    elseif gameState == "play" then       
        drawPlayState()                                        
    elseif gameState == "pause" then  
        drawPauseState()
    elseif gameState == "win" then
        drawWinState()         
    elseif gameState == "death" then
        drawDeathScreen()
    end              

    -- Draw the fade effects
    fadeOutDraw()
    fadeInDraw()                    
end

function drawTitleScreen()
   
    -- Draw the background image
    love.graphics.draw(titleImage, 0, 0, 0, VIRTUAL_WIDTH / titleImage:getWidth(), VIRTUAL_HEIGHT / titleImage:getHeight())                        

    -- Only draw the Crimson Crown image when on the actual title screen
    if gameState == "title" then
        -- Define scale factors for the Crimson Crown image
        local scaleWidth = 4  -- Adjust these scale factors as needed
        local scaleHeight = 4

        -- Calculate new dimensions and position for the scaled image
        local scaledWidth = crimsonCrown:getWidth() * scaleWidth
        local scaledHeight = crimsonCrown:getHeight() * scaleHeight
        local crimsonCrownX = (VIRTUAL_WIDTH - scaledWidth) / 2  -- Center horizontally
        local crimsonCrownY = VIRTUAL_HEIGHT / 7  -- Position it near the top (adjust as needed)

        -- Draw the Crimson Crown image scaled
        love.graphics.draw(crimsonCrown, crimsonCrownX, crimsonCrownY, 0, scaleWidth, scaleHeight)
    end

    -- Draw the buttons
    buttonsDraw()  
end

function drawPlayState()      
    drawBackground({0.25, 0.25, 0.25}) -- Dark gray             
    local mapWidth, mapHeight = getMapDimensions(gameMap)                            
    love.graphics.setColor(1, 1, 1, 1) -- Set text color and font  

    -- Camera
    cameraLookAt(dt)                    
    cameraAttach()                        
        if player.body then                
            draw_common_game_elements()                            
            drawEntities()
        end 
    cameraDetach()  

    if shop and shop.textbox then
        Talkies.draw()
    else
        for _, w in ipairs(watchers) do
            if w.textbox then
                Talkies.draw()
                break
            end
        end
    end              

    -- Draw the timer only during the play state
    love.graphics.setFont(timerFont)
    love.graphics.setColor(1, 1, 1) -- Color #236b7a for timer text
    love.graphics.printf(string.format("Time: %.2f", elapsedTime), 10, 10, VIRTUAL_WIDTH, "left")
    
    -- Resetting color to default immediately after drawing the timer text
    love.graphics.setColor(1, 1, 1, 1)
end



function drawPauseState()    

    drawBackground({0.08, 0.08, 0.08}) -- Dark gray
    
    if credits then        
        cameraAttach()
            if player.body then  
                draw_common_game_elements()  
                drawEntities()                     
                updateMouseVisibility()    
            end
        cameraDetach()                   
        drawCredits() 
        buttonsDraw() 
    elseif controls then       
        cameraAttach()
            if player.body then                
                draw_common_game_elements() 
                drawEntities()  
                updateMouseVisibility()             
            end 
        cameraDetach()               
        drawControls() 
        buttonsDraw()   

    else
        cameraAttach()
            if player.body then                
                draw_common_game_elements() 
                drawEntities()    
                updateMouseVisibility()           
            end 
        cameraDetach()          
    end

    -- No Dimming
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw buttons
    buttonsDraw()   
end

function drawWinState() 
    drawBackground({0, 0, 0}) -- Dark gray
    
    local winTextColor = {35 / 255, 107 / 255, 122 / 255} -- RGB for 236b7a
    
    local gameWinFont = love.graphics.newFont("assets/fonts/Pixel UniCode.ttf", 128)
    love.graphics.setFont(gameWinFont)        
 
    drawTextWithBorder("To be continued...", 128, 0, VIRTUAL_HEIGHT / 2.5, 'center', {1, 1, 1}, winTextColor, nil)

    -- Display elapsed time
    local timeDisplay = string.format("Time:%.2fs", elapsedTime)
    drawTextWithBorder(timeDisplay, 36, 0, VIRTUAL_HEIGHT * 2 / 3 - 40, 'center', {1, 1, 1}, {1, 1, 1}, nil) -- Adjust position as needed
   
    drawTextWithBorder("Returning to Title Screen...", 48, 0, VIRTUAL_HEIGHT * 2 / 3, 'center', {1, 1, 1}, {1, 1, 1}, nil)
end

function drawCredits()
    -- Convert hex color 'ab3131' to RGB and then to Love2D color format
    local r, g, b = 1, 1, 1
    love.graphics.setColor(r, g, b, 1) -- Set text color with the new color

    -- Draw credits text
    local creditsFont = love.graphics.newFont("assets/fonts/Pixel UniCode.ttf", 64)
    love.graphics.setFont(creditsFont)    

    local creditsText = "Game Developed by: Jamis Burr\n" ..
                        "Music by: Kevin MacLeod\n" ..
                        "Artwork by: Penusbmic\n" ..
                        "Consultation by: Human Jukebox\n" ..                     
                        "Dedicated to: My Lovely Lucy. <3"
    love.graphics.printf(creditsText, 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
end

function drawControls()
    -- Convert hex color 'ab3131' to RGB and then to Love2D color format
    local r, g, b = 1, 1, 1
    love.graphics.setColor(r, g, b, 1) -- Set text color with the new color

    local controlsFont = love.graphics.newFont("assets/fonts/Pixel UniCode.ttf", 64)
    love.graphics.setFont(controlsFont)
    local actionsText, controlsText

    if keyboard then
        actionsText = "Movement:\n" ..
                      "Jump:\n" ..
                      "Interact:\n" ..
                      "Attack:\n" ..                        
                      "Charge:\n" ..
                      "Teleport:\n" ..
                      "Deflect:"
                     
        
        controlsText = "  WASD\n" ..
                       "  Spacebar\n" ..
                       "  E\n" ..
                       "  C\n" ..                        
                       "  R\n" ..
                       "  F\n" ..
                       "  Q" 
                       
    elseif controller then
        actionsText = "Movement:\n" ..
                      "Jump:\n" ..
                      "Interact:\n" ..
                      "Attack:\n" ..                        
                      "Dash:\n" ..
                      "Teleport:\n" ..
                      "Deflect:"
        
        controlsText = "  DPAD\n" ..
                       "  A\n" ..
                       "  Y\n" ..
                       "  R1\n" ..                        
                       "  X\n" ..
                       "  Y\n" ..
                       "  B"
    end

    -- Calculate the column widths
    local columnWidth = VIRTUAL_WIDTH / 3
    local actionsColumnX = VIRTUAL_WIDTH / 2 - columnWidth
    local controlsColumnX = VIRTUAL_WIDTH / 2

    -- Draw the text in two columns
    love.graphics.printf(actionsText, actionsColumnX, VIRTUAL_HEIGHT / 4, columnWidth, 'right') -- Right align for actions
    love.graphics.printf(controlsText, controlsColumnX, VIRTUAL_HEIGHT / 4, columnWidth, 'left') -- Left align for controls
end


function drawDeathScreen()                    
    drawBackground({0, 0, 0}) -- Dark gray
    
    local deathTextColor = {171 / 255, 49 / 255, 49 / 255} -- RGB for ab3131
    local deathTextBorderColor = {171 / 255, 101 / 255, 84 / 255}
    local deathFontBig = love.graphics.newFont("assets/fonts/Pixel UniCode.ttf", 128)
    love.graphics.setFont(deathFontBig)
    
    drawTextWithBorder("You Died", 128, 0, VIRTUAL_HEIGHT / 2.5, 'center', deathTextBorderColor, deathTextColor, nil)
    drawTextWithBorder("Returning to Title Screen...", 36, 0, VIRTUAL_HEIGHT * 2 / 3, 'center', deathTextBorderColor, {1, 1, 1}, nil)
end

function drawEntities()
    -- Camera
    cameraLookAt() 

    -- Map layers
    mapLayers()

    -- Draw world
    --world:draw()

    -- Draw Objects
    switchDraw()
    gateDraw()
    teleportDraw()

    -- Draw NPCs                
    shopDraw()
    statueDraw()
    watcherDraw()

    -- Draw enemies
    ghoulDrawAll()   
    spitterDrawAll()
    projectileDrawAll()
    waspDrawAll()
    bossDrawAll()
    hiveDrawAll()  
    summonerDrawAll()

    -- Draw player
    playerDraw()
end

-- Utility Functions
function getMapDimensions(gameMap)
    return gameMap.width * gameMap.tilewidth, gameMap.height * gameMap.tileheight
end

function distance(x1, y1, x2, y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end       

-- Mouse Interaction
function love.mousepressed(x, y, button)
    if keyboard then
        local virtualX, virtualY = x / scaleX, y / scaleY
        handleMousePressedState(virtualX, virtualY, button)
    end 
end   

function handleMousePressedState(virtualX, virtualY, button)
    if gameState == "title" and button == 1 then
        handleTitleScreenClick(virtualX, virtualY)
    elseif gameState == "title.menu" and button == 1 then
        handleTitleMenuClick(virtualX, virtualY)
    elseif gameState == "pause" and button == 1 then
        handlePauseMenuClick(virtualX, virtualY)
    end
end

function updateMouseVisibility()
    -- Hide the default mouse cursor when the keyboard or controller is in control
    love.mouse.setVisible(not (keyboard or controller))
end

-- Function to handle the press of the 'A' button on the controller
function handleControllerYButtonPress()
    local joystick = love.joystick.getJoysticks()[1]
    if not joystick or not controller then return end

    local yButtonDown = joystick:isGamepadDown("y")

    if yButtonDown and not yButtonPressedLastFrame then
        yButtonPressedLastFrame = true

        if gameState == "title" then
            executeTitleAction()        

        elseif gameState == "title.menu" then
            if muteAndInput then
                executeMuteAndInputAction() 
            else
                -- Handle Y button press in title menu
                executeTitleMenuAction()  
            end
        elseif gameState == "pause" and muteAndInput then
            executeMuteAndInputAction()      
        elseif gameState == "pause" and not settings and not credits and not controls then
            executePauseMenuAction()
        
        elseif gameState == "pause" and settings and not credits and not controls then
            executeSettingsMenuAction()     
        elseif gameState == "pause" and credits then          
            executeCreditsMenuAction()     
        elseif gameState == "pause" and controls then         
            executeControlsMenuAction()
        end
    end
end

function executeTitleAction()
    gameState = "title.menu"
end
    
-- Function to execute action in the title menu based on the selected index
function executeTitleMenuAction()
    -- New game
    if controllerCurrentButtonIndex == 1 then        
        fadeInTimer = 1
        elapsedTime = 0                  
        saveManager.resetToDefaults()             
        saveManager.save()
        gameState = "play"
        loadMap("Level1")
        controllerCurrentButtonIndex = 1

    -- Continue game
    elseif controllerCurrentButtonIndex == 2 then       
        fadeInTimer = 1   
        savedData = saveManager.load()  
        applySavedData() 
        applyLocationData()              
        setPlayerStartingPosition()
        gameState = "play"    
        controllerCurrentButtonIndex = 1

    -- Exit game
    elseif controllerCurrentButtonIndex == 3 then
        love.event.quit()
    end   
end

function executeMuteAndInputAction()    
    if controllerCurrentButtonIndex == 1 then         
        if not sounds.muted then
            sounds.muted = true        
        elseif sounds.muted then
            sounds.muted = false      
        end

    elseif controllerCurrentButtonIndex == 2 then
        if keyboard then
          
            keyboard = false
            controller = true        
            switchToController()
        elseif controller then
           
            keyboard = true
            controller = false  
            switchToKeyboard()             
        end
        muteAndInput = false
    end
end        

function executePauseMenuAction()
    -- Resume game
    if controllerCurrentButtonIndex == 1 then
        resumeGame()
        controllerCurrentButtonIndex = 1

    -- Settings menu
    elseif controllerCurrentButtonIndex == 2 then
        settings = true
        controllerCurrentButtonIndex = 1
        
    -- Main menu
    elseif controllerCurrentButtonIndex == 3 then
        fadeInTimer = 1
        gameState = "title.menu"
        resetGame()
        controllerCurrentButtonIndex = 1
    end            
end

function executeSettingsMenuAction()
    -- Credits screen
    if controllerCurrentButtonIndex == 1 then 
        controllerCurrentButtonIndex = 1
        credits = true
        settings = false
        
    -- Controls screen
    elseif controllerCurrentButtonIndex == 2 then  
        controllerCurrentButtonIndex = 1 
        controls = true
        settings = false

    -- Back
    elseif controllerCurrentButtonIndex == 3 then
        controllerCurrentButtonIndex = 1
        settings = false        
    end
end

function executeCreditsMenuAction()   
    if controllerCurrentButtonIndex == 1 then
        credits = false  -- Exit credits screen
        controls = false
        settings = true 
    end
end

function executeControlsMenuAction()
    if controllerCurrentButtonIndex == 1 then
    credits = false  -- Exit credits screen
    controls = false
    settings = true
    end
end

function handleMuteClick(virtualX, virtualY)
    -- Handle different buttons in the title menu 
    if virtualX > muteButton.x and virtualX < muteButton.x + muteButton.w and virtualY > muteButton.y and virtualY < muteButton.y + muteButton.h then
        if not sounds.muted then
            sounds.muted = true     
        elseif sounds.muted then
            sounds.muted = false     
        end
    end
end

function handleInputClick(virtualX, virtualY)
    if virtualX > inputButton.x and virtualX < inputButton.x + inputButton.w and 
       virtualY > inputButton.y and virtualY < inputButton.y + inputButton.h then
        if keyboard then
            keyboard = false
            controller = true 
            switchToController()       
                      
        elseif controller then          
            keyboard = true
            controller = false  
            switchToKeyboard() 
        end    
   
       
        controllerCurrentButtonIndex = 1
    end 
end

function handleTitleScreenClick(virtualX, virtualY)
    if virtualX > startButton.x and virtualX < startButton.x + startButton.w 
    and virtualY > startButton.y and virtualY < startButton.y + startButton.h then
        gameState = "title.menu"
    end
end

function handleTitleMenuClick(virtualX, virtualY)
    -- Handle different buttons in the title menu                               
    if virtualX > newGameButton.x and virtualX < newGameButton.x + newGameButton.w and virtualY > newGameButton.y and virtualY < newGameButton.y + newGameButton.h then
        fadeInTimer = 1
        elapsedTime = 0                  
        saveManager.resetToDefaults()             
        saveManager.save()
        gameState = "play"
        loadMap("Level1")   
    end

    -- check if the mouse click is inside the continue button
    if virtualX > continueButton.x and virtualX < continueButton.x + continueButton.w and virtualY > continueButton.y and virtualY < continueButton.y + continueButton.h then
        fadeInTimer = 1   
        savedData = saveManager.load()
        applySavedData() 
        applyLocationData()              
        setPlayerStartingPosition()
        gameState = "play"        
    end

    handleMuteClick(virtualX, virtualY)
    handleInputClick(virtualX, virtualY)   

    -- check if the mouse click is inside the exit button
    if virtualX > exitButton.x and virtualX < exitButton.x + exitButton.w and virtualY > exitButton.y and virtualY < exitButton.y + exitButton.h then
        fadeInTimer = 1
        love.event.quit()
    end                     
end        

function handlePauseMenuClick(virtualX, virtualY)
    -- Handle different buttons in the pause menu
    if credits or controls then                            
        -- Back button
        if virtualX > backButton.x and virtualX < backButton.x + backButton.w and virtualY > backButton.y and virtualY < backButton.y + backButton.h then
            credits = false  -- Exit credits screen
            controls = false
            settings = true
        end

    elseif settings then        
        -- Credits button
        if virtualX > creditsButton.x and virtualX < creditsButton.x + creditsButton.w and virtualY > creditsButton.y and virtualY < creditsButton.y + creditsButton.h then
            credits = true
            settings = false
        end

        -- Mute button
        handleMuteClick(virtualX, virtualY)
        
        -- Input button
        handleInputClick(virtualX, virtualY)      
        
        -- Controls button
        if virtualX > controlsButton.x and virtualX < controlsButton.x + controlsButton.w and virtualY > controlsButton.y and virtualY < controlsButton.y + controlsButton.h then
            controls = true
            settings = false
        end

        -- Back button            
        if virtualX > backButton.x and virtualX < backButton.x + backButton.w and virtualY > backButton.y and virtualY < backButton.y + backButton.h then
            settings = false  -- Exit credits screen           
        end    

    else
        -- Resume button
        if virtualX > resumeButton.x and virtualX < resumeButton.x + resumeButton.w and virtualY > resumeButton.y and virtualY < resumeButton.y + resumeButton.h then
            resumeGame()
        end
        
        -- Mute button
        handleMuteClick(virtualX, virtualY)
        
        -- Input button
        handleInputClick(virtualX, virtualY)      

        -- Settings button
        if virtualX > settingsButton.x and virtualX < settingsButton.x + settingsButton.w and virtualY > settingsButton.y and virtualY < settingsButton.y + settingsButton.h then
            settings = true            
        end
       
        -- Main Menu button
        if virtualX > mainMenuButton.x and virtualX < mainMenuButton.x + mainMenuButton.w and virtualY > mainMenuButton.y and virtualY < mainMenuButton.y + mainMenuButton.h then
            fadeInTimer = 1
            gameState = "title.menu"
            resetGame()
        end                                   
    end            
end

-- Gameplay Functions
function resumeGame()
    gameState = "play"    
end               

-- Spawning Functions              
function spawnPlatform(x, y, width, height) 
    if width > 0 and height > 0 then
    local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
    platform:setType('static')
    table.insert(platforms, platform)
    end
end                

function spawnWall(x, y, width, height)
    if width > 0 and height > 0 then
    local wall = world:newRectangleCollider(x, y, width, height, {collision_class = "Wall"})
    wall:setType('static')
    table.insert(walls, wall)
    end
end

function spawnGameWin(x, y, width, height)
    if width > 0 and height > 0 then
        gameWin = world:newRectangleCollider(x, y, width, height, {collision_class = "GameWin"})
        gameWin:setType('static')    
    end
end

function mapLayers()    
    local layersToDraw = {
        "TileLayer2", "Fences", "Lights2", "Islands", "Webs2", "Doors","Trees3", "Trees2", 
        "Trees", "Webs", "Signs", "Lights", "TileLayer1", "Overlay", "Fences2", 
        "Posts", "Posts2"
    }
    for _, layerName in ipairs(layersToDraw) do
        if gameMap.layers[layerName] then
            gameMap:drawLayer(gameMap.layers[layerName])
        end
    end
end

-- Player Positioning
function setPlayerStartingPosition()
    local startLocation = savedData.playerProgress or "Default"
    loadMap(savedData.currentLevel)
    for _, obj in pairs(gameMap.layers["Game_Start"].objects) do
        if obj.name == startLocation then
            player:setPosition(obj.x, obj.y)
            break
        end
    end                      
end

-- Saving and Loading Data
function saveProgress(abilityName, currentLevel)
    saveManager.set("playerProgress", abilityName)
    saveManager.set("currentLevel", currentLevel)    
    saveManager.save()
end

function applyLocationData()
    if savedData.playerProgress == "Default" then
        saveProgress("Default", "Level1") 
    elseif savedData.playerProgress == "Sword" then
        saveProgress("Sword", "Level1") 
    elseif savedData.playerProgress == "Key" then
        saveProgress("Key", "Level2")  
    elseif savedData.playerProgress == "Dash" then
        saveProgress("Dash", "Level1")  
    elseif savedData.playerProgress == "Teleport" then
        saveProgress("Teleport", "Level3")  
    elseif savedData.playerProgress == "Deflect" then
        saveProgress("Deflect", "Level2")  
    elseif savedData.playerProgress == "Dash2" then
        saveProgress("Dash2", "Level3")   
    elseif savedData.playerProgress == "DJump" then
        saveProgress("DJump", "Level1")   
    end
end

function applySavedData()                            
    if savedData.hasSword then
        acquiredSword()                     
    end

    if savedData.hasKey then
        acquiredKey()                           
    end

    if savedData.hasDash then        
        acquiredDash()               
    end

    if savedData.hasDash2 then
        acquiredDash2()                      
    end

    if savedData.hasTeleport then        
        acquiredTeleport()                     
    end

    if savedData.hasDeflect then
        acquiredDeflect()             
    end

    if savedData.hasDJump then
        acquiredDJump()             
    end

    if savedData.shopDialogueExhausted then
        shopDialogueExhausted = true
    end

    if savedData.elapsedTime then                    
        elapsedTime = savedData.elapsedTime or 0                    
    end

    local exhaustedWatcherIDs = savedData.exhaustedWatcherIDs or {}
    for _, w in ipairs(watchers) do
        if table_contains(exhaustedWatcherIDs, w.id) then
            w.dialougeExhausted = true
        end
    end
end

function loadMap(mapName)              
    print("Loading map: " .. mapName)  -- Add this line                             
    destroyAll()                    
    gameMap = sti("maps/" .. mapName .. ".lua")   
    setupMapEntities(mapName)
end

function setupMapEntities(mapName)
    local startLocation = player.progress or "Default"

for _, obj in pairs(gameMap.layers["Game_Start"].objects) do
    if obj.name == startLocation then
        playerStartX = obj.x
        playerStartY = obj.y
        break
    end
end  

print("Player progress:", player.progress)    
player:setPosition(playerStartX, playerStartY)   

for i, obj in pairs(gameMap.layers["Platforms"].objects) do
    spawnPlatform(obj.x, obj.y, obj.width, obj.height)
end

for i, obj in pairs(gameMap.layers["Walls"].objects) do
    spawnWall(obj.x, obj.y, obj.width, obj.height)
end  

-- Check if 'Game_Win' layer exists
if gameMap.layers["Game_Win"] then
    for i, obj in pairs(gameMap.layers["Game_Win"].objects) do
        spawnGameWin(obj.x, obj.y, obj.width, obj.height)
    end
end

for layerName, spawnFunc in pairs(layerSpawnMap) do
    if gameMap.layers[layerName] then
        for _, obj in pairs(gameMap.layers[layerName].objects) do
            spawnFunc(obj.x, obj.y, obj)
        end
    end
end

departureDoors = {}
arrivalDoors = {}

if gameMap.layers["DepartureDoors"] then
    for i, obj in pairs(gameMap.layers["DepartureDoors"].objects) do
        departureDoors[obj.name] = {
            x = obj.x,
            y = obj.y,
            destinationMap = obj.properties.destinationMap,
            destinationDoor = obj.properties.destinationDoor
        }
    end
end

if gameMap.layers["ArrivalDoors"] then
    for i, obj in pairs(gameMap.layers["ArrivalDoors"].objects) do
        arrivalDoors[obj.name] = {
            x = obj.x,
            y = obj.y
        }
    end
end

departureTranspads = {}
arrivalTranspads = {}

if gameMap.layers["DepartureTranspads"] then
    for i, obj in pairs(gameMap.layers["DepartureTranspads"].objects) do
        departureTranspads[obj.name] = {
            x = obj.x,
            y = obj.y,            
            destinationTranspad = obj.properties.destinationTranspad
        }
    end
end

if gameMap.layers["ArrivalTranspads"] then
    for i, obj in pairs(gameMap.layers["ArrivalTranspads"].objects) do
        arrivalTranspads[obj.name] = {
            x = obj.x,
            y = obj.y
        }
    end
end

player.currentLevel = mapName
print("Loaded map:", player.currentLevel)
end

function table_contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Function to load all entities (enemies, objects, NPCs)
function requireEntities()
    -- Require additional libraries
    require("libraries/show")

    -- List of entities to load
    local entities = {
        "player", "enemies/ghoul", "enemies/spitter", "enemies/projectile",
        "enemies/wasp", "enemies/hive", "enemies/summoner", "enemies/boss",
        "objects/switch", "objects/gate", "objects/teleport",
        "npcs/statue", "npcs/watcher", "npcs/shop"
    }
    for _, entity in ipairs(entities) do
        require(entity)
    end
end 

-- Example of switching to the keyboard
function switchToKeyboard()
    configData.keyboard = true
    configData.controller = false
    saveManager.save()
end

-- Example of switching to the controller
function switchToController()
    configData.keyboard = false
    configData.controller = true
    saveManager.save() 
end

function resetGame()                   
    destroyAll()
    resetPlayerState()
    resetGameState()
end

function resetPlayerState()
    -- Reset player's position
    player.body:setLinearVelocity(0, 0)  -- Reset velocity    

    -- Reset player's abilities and progress
    player.hasSword, player.hasKey, player.hasDash = false, false, false
    player.hasTeleport, player.hasDeflect, player.hasDash2, player.hasDJump = false, false, false, false
    player.progress, player.direction = "Default", 1

    -- Reset player's health and invincibility
    player.health = 1
    player.invincible, player.invincibilityTimer = false, 0

    -- Reset player's attack and other states
    player.attacking, player.dashing, player.deflecting = false, false, false
    player.teleporting, player.appearing, player.teleportActive = false, false, false
    player.jumping, player.falling, player.moving = false, false, false
    player.attackButtonPressed = false
    player.dashButtonPressed = false 
    player.attackCooldown = 0
    player.dashDelay = 0
    -- Reset shop-related states only if shop exists
    if shop then
        shop.textbox = false
        questionAdded = false
    end 

    Talkies.clearMessages()
    canActions()

    -- Reset player's animation to a default state, e.g., 'idle'
    if player.animations and player.animations['idle'] then
        player.currentAnimation = player.animations['idle']
        player.currentAnimation:gotoFrame(1)
        player.currentAnimation:resume()
    end
end

function resetGameState()
    bosses, shopDialogueExhausted, exhaustedWatcherIDs = {}, false, {}
    deathTimer, winTimer = 11, 11
end

function resetWinGameState()
end