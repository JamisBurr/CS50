switches = {}  

function switchSpritesheets()
    -- Load sprite sheets    
    local spriteSheets = {}
    spriteSheets['starting'] = love.graphics.newImage("sprites/switches/start(16x19).png")
    spriteSheets['enabled'] = love.graphics.newImage("sprites/switches/enabled(16x19).png")
    spriteSheets['stopping'] = love.graphics.newImage("sprites/switches/stop(16x19).png")
    spriteSheets['disabled'] = love.graphics.newImage("sprites/switches/stop(16x19).png")   
    return spriteSheets
end

function switchAnimations(spriteSheets)
   -- Create grids for each animation
   local startGrid = anim8.newGrid(16, 19, spriteSheets['starting']:getWidth(), spriteSheets['starting']:getHeight()) 
   local enabledGrid = anim8.newGrid(16, 19, spriteSheets['enabled']:getWidth(), spriteSheets['enabled']:getHeight()) 
   local stopGrid = anim8.newGrid(16, 19, spriteSheets['stopping']:getWidth(), spriteSheets['stopping']:getHeight()) 

   -- Create animations
    local animations = {}    
    animations['starting'] = anim8.newAnimation(startGrid("1-7", 1), 0.1)   
    animations['enabled'] = anim8.newAnimation(enabledGrid("1-4", 1), 0.1)   
    animations['stopping'] = anim8.newAnimation(stopGrid("1-3", 1), 0.1)  
    animations['disabled'] = anim8.newAnimation(stopGrid("4-5", 1), 1)    
    return animations 
end

function switchSpawn(x, y, gateIDString, customEnabledTimer, customStopAnimationTimer)
    switch = world:newRectangleCollider(x, y + 3, 6, 12, {collision_class = "Switch", isSensor = true})
    switch:setType('static')      
    switch.activated = false
    switch.startAnimationTimer = 0.7
    switch.enabledTimer = customEnabledTimer
    switch.originalEnabledTimer = customEnabledTimer
    switch.stopAnimationTimer = customStopAnimationTimer
    switch.originalStopAnimationTimer = customStopAnimationTimer
    switch.spriteSheets = switchSpritesheets()
    switch.animations = switchAnimations(switch.spriteSheets)
    switch.currentAnimation = switch.animations['disabled']    
    switch.gateIDs = {}
    for id in string.gmatch(gateIDString, "([^,]+)") do
        table.insert(switch.gateIDs, id)
    end

    table.insert(switches, switch)
end

function switchUpdate(dt)
    local joystick = love.joystick.getJoysticks()[1]  -- Get the first connected joystick

    for _, s in ipairs(switches) do     
        local px, py = player:getPosition()
        local sx, sy = s:getPosition()
        local distanceToSwitch = distance(px, py, sx, sy)    

        if player.hasKey and not s.activated then
            -- Check for interaction input (keyboard 'e' or controller button)
            local interactInput = love.keyboard.isDown("e") or (joystick and joystick:isGamepadDown("y"))

            if distanceToSwitch <= 12 and interactInput and allGatesClosed(s.gateIDs) then
                transitionToAnimation(s, 'starting')
                s.startAnimationTimer = 0.7
                s.activated = true                
                for _, gateID in ipairs(s.gateIDs) do
                    for _, gate in ipairs(gates) do                    
                        if gate.gateID == gateID then                                 
                            gate.activated = true                                
                        end
                    end                      
                end 
            end
        end

        if s.activated then
            if s.currentAnimation == s.animations['starting'] then
                updateTimer(s, 'startAnimationTimer', dt)
                if s.startAnimationTimer <= 0 then
                    transitionToAnimation(s, 'enabled')
                end

            elseif s.currentAnimation == s.animations['enabled'] then
                updateTimer(s, 'enabledTimer', dt)
                if s.enabledTimer <= 0 then
                    transitionToAnimation(s, 'stopping')
                end

            elseif s.currentAnimation == s.animations['stopping'] then
                updateTimer(s, 'stopAnimationTimer', dt)
                if s.stopAnimationTimer <= 0 then
                    transitionToAnimation(s, 'disabled')
                    resetSwitch(s)
                end
            end
        end               

        s.currentAnimation:update(dt)                  
    end
end

function transitionToAnimation(switch, animationName)
    switch.currentAnimation = switch.animations[animationName]
    switch.currentAnimation:gotoFrame(1)
end

function updateTimer(switch, timerName, dt)
    switch[timerName] = math.max(switch[timerName] - dt, 0)
end

function allGatesClosed(gateIDs)
    for _, gateID in ipairs(gateIDs) do
        for _, gate in ipairs(gates) do
            if gate.gateID == gateID and gate.currentAnimation ~= gate.animations['closed'] then
                return false
            end
        end
    end
    return true
end

function switchDraw()
    for i, s in ipairs(switches) do
        local sx, sy = s:getPosition()

        -- Disabled animation   
        if s.currentAnimation == s.animations['disabled'] then   
            s.currentAnimation:draw(s.spriteSheets['disabled'], sx, sy, nil, 1, 1, 7.5, 12)    
        
        --  Start animation   
        elseif s.currentAnimation == s.animations['starting'] then   
            s.currentAnimation:draw(s.spriteSheets['starting'], sx, sy, nil, 1, 1, 7.5, 12)  
        
        -- Enabled animation   
        elseif s.currentAnimation == s.animations['enabled'] then   
            s.currentAnimation:draw(s.spriteSheets['enabled'], sx, sy, nil, 1, 1, 7.5, 12)  
       
        -- Stop animation   
        elseif s.currentAnimation == s.animations['stopping'] then   
            s.currentAnimation:draw(s.spriteSheets['stopping'], sx, sy, nil, 1, 1, 7.5, 12)
        end
    end
end

function resetSwitch(s)
    s.activated = false    
    s.enabledTimer = s.originalEnabledTimer  -- Reset using the original value
    s.stopAnimationTimer = s.originalStopAnimationTimer  -- Reset using the original value    
end