-- Function to initialize buttons
function buttonsInit()
    -- Calculate dimensions and positions based on the virtual resolution
    local baseButtonWidth = 300
    local baseButtonHeight = 100
    local baseMuteAndInputWidth = 100
    local baseMuteAndInputHeight = 100

    buttonWidth = baseButtonWidth
    buttonHeight = baseButtonHeight
    buttonMuteAndInputWidth = baseMuteAndInputWidth
    buttonMuteAndInputHeight = baseMuteAndInputHeight
    buttonX = (VIRTUAL_WIDTH - buttonWidth) / 2

    -- Define buttonYSpacing here
    buttonYSpacing = buttonHeight * 1.4

    -- Calculate total height for all buttons including additional buttons
    local numMainButtons = 2
    local totalMainButtonsHeight = numMainButtons * buttonHeight + (numMainButtons - 1) * buttonYSpacing
    local totalMuteAndInputHeight = buttonMuteAndInputHeight -40  -- Including spacing
    local totalHeight = totalMainButtonsHeight + totalMuteAndInputHeight

    -- Center the group of buttons vertically
    buttonYStart = (VIRTUAL_HEIGHT - totalHeight) / 2 + totalMuteAndInputHeight

    loadButtons()
    loadButtonImages()
end

-- Function to load buttons
function loadButtons()   
    -- Title
    startButton = createButton(buttonX, buttonYStart + 450, buttonWidth, buttonHeight)
    
    -- Title Menu
    newGameButton = createButton(buttonX, buttonYStart, buttonWidth, buttonHeight, "newGame")
    continueButton = createButton(buttonX, buttonYStart + buttonYSpacing, buttonWidth, buttonHeight)
    exitButton = createButton(buttonX, buttonYStart + 2 * buttonHeight * 1.4, buttonWidth, buttonHeight)

    -- Pause Menu
    resumeButton = createButton(buttonX, buttonYStart, buttonWidth, buttonHeight)
    settingsButton = createButton(buttonX, buttonYStart + buttonYSpacing, buttonWidth, buttonHeight)
    mainMenuButton = createButton(buttonX, buttonYStart + 2 * buttonHeight * 1.4, buttonWidth, buttonHeight)

    -- Settings Menu
    creditsButton = createButton(buttonX, buttonYStart, buttonWidth, buttonHeight)    
    controlsButton = createButton(buttonX, buttonYStart + buttonYSpacing, buttonWidth, buttonHeight)  
    backButton = createButton(buttonX, buttonYStart + buttonYSpacing * 2, buttonWidth, buttonHeight)
    backButton.originalY = buttonYStart + buttonYSpacing * 2    

    -- Mute/Input
    -- Calculate the combined width of mute and input buttons and the spacing between them
    local spacingBetweenButtons = 20  -- Space between mute and input buttons
    local combinedWidth = buttonMuteAndInputWidth * 2 + spacingBetweenButtons

    -- Calculate starting X position for the mute button to center the block
    local muteButtonX = (VIRTUAL_WIDTH - combinedWidth) / 2

    -- Position the mute button
    muteButton = createButton(muteButtonX, buttonYStart - buttonMuteAndInputHeight - 20, buttonMuteAndInputWidth, buttonMuteAndInputHeight)

    inputButton = createButton(muteButtonX + buttonMuteAndInputWidth + spacingBetweenButtons, buttonYStart - buttonMuteAndInputHeight - 20, buttonMuteAndInputWidth, buttonMuteAndInputHeight)

    --leftButton = createButton(buttonX - 300, buttonYStart + buttonYSpacing, buttonWidth, buttonHeight)
    --rightButton = createButton(buttonX + 300, buttonYStart + buttonYSpacing, buttonWidth, buttonHeight)
end

-- Function to load button images
function loadButtonImages()
    -- Title
    crimsonCrown = love.graphics.newImage("menus/UI - Words/Words With BG - RED_BLUE/crimson_crown.png")
    startImage = love.graphics.newImage("menus/UI - Words/Words With BG - RED_BLUE/start.png")
    
    -- Title Menu
    newGameImage = love.graphics.newImage("menus/UI - Words/Words With BG - RED_BLUE/new_game.png")
    continueImage = love.graphics.newImage("menus/UI - Words/Words With BG - RED_BLUE/continue.png")
    exitImage = love.graphics.newImage("menus/UI - Words/Words With BG - RED_BLUE/exit.png")    

    -- Pause Menu
    resumeImage = love.graphics.newImage("menus/UI - Words/Words With BG - RED_BLUE/resume.png")
    settingsImage = love.graphics.newImage("menus/UI - Words/Words With BG - RED_BLUE/settings.png")
    mainMenuImage = love.graphics.newImage("menus/UI - Words/Words With BG - RED_BLUE/main_menu.png")        

    -- Settings Menu
    creditsImage = love.graphics.newImage("menus/UI - Words/Words With BG - RED_BLUE/credits.png")
    controlsImage = love.graphics.newImage("menus/UI - Words/Words With BG - RED_BLUE/controls.png")
    backImage = love.graphics.newImage("menus/UI - Words/Words With BG - RED_BLUE/back.png")
    unmuteImage = love.graphics.newImage("menus/UI - ICONS/UI - ICONS - RED_BLUE/muted.png")
    muteImage = love.graphics.newImage("menus/UI - ICONS/UI - ICONS - RED_BLUE/unmuted.png")
    
    
    -- Mute/Input
    keyboardImage = love.graphics.newImage("menus/UI - ICONS/UI - ICONS - RED_BLUE/keyboard.png") 
    controllerImage = love.graphics.newImage("menus/UI - ICONS/UI - ICONS - RED_BLUE/controller.png") 
    leftImage = love.graphics.newImage("menus/UI - ICONS/UI - ICONS - RED_BLUE/left.png")
    rightImage = love.graphics.newImage("menus/UI - ICONS/UI - ICONS - RED_BLUE/right.png")  
end
    
function buttonsDraw()    
    if gameState == "title" then
        if controller then
            drawButtonForController(startButton, startImage)
        else
            drawButtonWithHoverEffect(startButton, startImage)
        end

    elseif gameState == "title.menu" then
        if muteAndInput then
            drawMuteAndInputButtons()  
            drawButtonForController(newGameButton, newGameImage)
            drawButtonForController(continueButton, continueImage)
            drawButtonForController(exitButton, exitImage)       
        else
            drawTitleMenuButtons()
        end

    elseif gameState == "pause" then
        
        if muteAndInput then
             -- Set the color to black with alpha for transparency (dimming effect)
            drawMuteAndInputButtons()  
            drawButtonForController(resumeButton, resumeImage)
            drawButtonForController(settingsButton, settingsImage)
            drawButtonForController(mainMenuButton, mainMenuImage)       
        else
            drawPauseMenuButtons() 
        end        
    end
end

function drawMuteAndInputButtons()    
   
    if controller then
        if not sounds.muted then
            drawButtonForController(muteButton, muteImage, controllerCurrentButtonIndex == 1)
        elseif sounds.muted then
            drawButtonForController(muteButton, unmuteImage, controllerCurrentButtonIndex == 1)
        end       
        drawButtonForController(inputButton, controllerImage, controllerCurrentButtonIndex == 2)   
    end
end

function drawTitleMenuButtons()
    if controller then
        drawButtonForController(newGameButton, newGameImage, controllerCurrentButtonIndex == 1)
        drawButtonForController(continueButton, continueImage, controllerCurrentButtonIndex == 2)
        drawButtonForController(exitButton, exitImage, controllerCurrentButtonIndex == 3)   
        drawMuteInputButtons()     
    elseif keyboard then
        drawButtonWithHoverEffect(newGameButton, newGameImage)
        drawButtonWithHoverEffect(continueButton, continueImage)
        drawButtonWithHoverEffect(exitButton, exitImage)
        drawMuteInputButtons()        
    end
end

function drawPauseMenuButtons()    
    if credits then
        drawCreditsMenuButtons()
    elseif controls then
        drawControlsMenuButtons()
    elseif settings then
        drawSettingsMenuButtons()                
    elseif muteAndInput then
        drawMuteAndInputButtons() 
    else
        drawStandardPauseMenuButtons()        
    end   
end

function drawMuteInputButtons()
    if controller then
        -- Draw buttons without hover effect for controller mode
        local scale = 1
        love.graphics.draw(sounds.muted and unmuteImage or muteImage, muteButton.x, muteButton.y, 0, scale * muteButton.w / muteImage:getWidth(), scale * muteButton.h / muteImage:getHeight())
        love.graphics.draw(controllerImage, inputButton.x, inputButton.y, 0, scale * inputButton.w / controllerImage:getWidth(), scale * inputButton.h / controllerImage:getHeight())
    elseif keyboard then
        -- Draw buttons with hover effect for keyboard mode
        local scale, offsetX, offsetY = getHoverEffect(muteButton)
        love.graphics.draw(sounds.muted and unmuteImage or muteImage, muteButton.x + offsetX, muteButton.y + offsetY, 0, scale * muteButton.w / muteImage:getWidth(), scale * muteButton.h / muteImage:getHeight())
        scale, offsetX, offsetY = getHoverEffect(inputButton)
        love.graphics.draw(keyboardImage, inputButton.x + offsetX, inputButton.y + offsetY, 0, scale * inputButton.w / keyboardImage:getWidth(), scale * inputButton.h / keyboardImage:getHeight())
    end
end

function drawCreditsMenuButtons()
    backButton.y = backButton.originalY + 100 -- move the button 200 pixels down
    if controller then
        drawButtonForController(backButton, backImage, controllerCurrentButtonIndex == 1)
    else
        drawButtonWithHoverEffect(backButton, backImage)  
    end    
end

function drawControlsMenuButtons()
    backButton.y = backButton.originalY + 150 -- move the button 200 pixels down
    if controller then
        drawButtonForController(backButton, backImage, controllerCurrentButtonIndex == 1)
    else
        drawButtonWithHoverEffect(backButton, backImage)  
    end    
end

function drawSettingsMenuButtons()    
    if controller then
        backButton.y = backButton.originalY
        drawButtonForController(creditsButton, creditsImage, controllerCurrentButtonIndex == 1)
        drawButtonForController(controlsButton, controlsImage, controllerCurrentButtonIndex == 2)
        drawButtonForController(backButton, backImage, controllerCurrentButtonIndex == 3)        
    else
        backButton.y = backButton.originalY
        drawButtonWithHoverEffect(creditsButton, creditsImage)
        drawButtonWithHoverEffect(controlsButton, controlsImage)
        --drawButtonWithHoverEffect(leftButton, leftImage)
        --drawButtonWithHoverEffect(rightButton, rightImage)      
        drawButtonWithHoverEffect(backButton, backImage)        
    end
  
end

function drawStandardPauseMenuButtons()    
    if controller then
        drawButtonForController(resumeButton, resumeImage, controllerCurrentButtonIndex == 1)
        drawButtonForController(settingsButton, settingsImage, controllerCurrentButtonIndex == 2)
        drawButtonForController(mainMenuButton, mainMenuImage, controllerCurrentButtonIndex == 3)             
    else
        drawButtonWithHoverEffect(resumeButton, resumeImage)            
        drawButtonWithHoverEffect(settingsButton, settingsImage)
        drawButtonWithHoverEffect(mainMenuButton, mainMenuImage)          
    end   
    drawMuteInputButtons()   
end    

function drawButtonWithHoverEffect(button, image)
    local hoverScale, offsetX, offsetY = getHoverEffect(button)

    -- Use button's own dimensions for scaling, as they are already adjusted
    love.graphics.draw(image, button.x + offsetX, button.y + offsetY, 0,
                       hoverScale * button.w / image:getWidth(),
                       hoverScale * button.h / image:getHeight())
end

function drawButtonForController(button, image, isSelectedByController)
    local scale, offsetX, offsetY = 1, 0, 0
    if isSelectedByController then
        scale, offsetX, offsetY = 1.1, -0.05 * button.w, -0.05 * button.h
    end

    love.graphics.draw(image, button.x + offsetX, button.y + offsetY, 0,
                       scale * button.w / image:getWidth(),
                       scale * button.h / image:getHeight())
end

function isMouseOverButton(button)
    local mouseX, mouseY = love.mouse.getPosition()
    -- Convert mouse position to virtual resolution space
    local virtualMouseX = (mouseX - offsetX) / scaleX
    local virtualMouseY = (mouseY - offsetY) / scaleY

    return virtualMouseX > button.x and virtualMouseX < (button.x + button.w) and
           virtualMouseY > button.y and virtualMouseY < (button.y + button.h)
end

function getHoverEffect(button)
    local scale, offsetX, offsetY = 1, 0, 0
    if isMouseOverButton(button) then
        scale = 1.1
        offsetX, offsetY = -0.05 * button.w, -0.05 * button.h
    end
    return scale, offsetX, offsetY
end

function createButton(x, y, w, h, id)
    return {
        x = x,
        y = y,
        w = w,
        h = h,
        id = id  -- Add an identifier for the button
    }
end
