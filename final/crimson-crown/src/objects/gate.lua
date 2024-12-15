gates = {}    

function gateSpritesheets()
    -- Load sprite sheets    
    local spriteSheets = {}
    spriteSheets['opening'] = love.graphics.newImage("sprites/gate/gate(41x48).png")
    spriteSheets['opened'] = love.graphics.newImage("sprites/gate/gate(41x48).png")
    spriteSheets['closing'] = love.graphics.newImage("sprites/gate/gate(41x48).png")
    spriteSheets['closed'] = love.graphics.newImage("sprites/gate/gate(41x48).png")   
    return spriteSheets
end

function gateAnimations(spriteSheets)
    -- Create grids for each animation
    local openingGrid = anim8.newGrid(41, 48, spriteSheets['opening']:getWidth(), spriteSheets['opening']:getHeight())  
    local openedGrid = anim8.newGrid(41, 48, spriteSheets['opened']:getWidth(), spriteSheets['opened']:getHeight()) 
    local closingGrid = anim8.newGrid(41, 48, spriteSheets['closing']:getWidth(), spriteSheets['closing']:getHeight()) 
    local closedGrid = anim8.newGrid(41, 48, spriteSheets['closed']:getWidth(), spriteSheets['closed']:getHeight()) 

    -- Create animations
     local animations = {}    
     animations['opening'] = anim8.newAnimation(openingGrid("1-14", 1), 0.1)    
     animations['opened'] = anim8.newAnimation(openedGrid(15, 1), 0.1)   
     animations['closing'] = anim8.newAnimation(closingGrid("14-1", 1), 0.1)  
     animations['closed'] = anim8.newAnimation(closedGrid(1, 1), 0.1)    
     return animations 
 end
 
function gateSpawn(x, y, gateID, customEnabledTimer, customStopAnimationTimer)    
    gate = world:newRectangleCollider(x + 6, y + 1.5, 4, 45, {collision_class = "Gate", isSensor = true})
    gate:setType('static')
    gate.startAnimationTimer = gate.originalStartAnimationTimer or 1.4
    gate.originalStartAnimationTimer = 1.4
    gate.enabledTimer = customEnabledTimer
    gate.originalEnabledTimer = customEnabledTimer
    gate.stopAnimationTimer = customStopAnimationTimer
    gate.originalStopAnimationTimer = customStopAnimationTimer
    gate.spriteSheets = gateSpritesheets()
    gate.animations = gateAnimations(gate.spriteSheets)
    gate.currentAnimation = gate.animations['closed']     
    gate.gateID = gateID 
    table.insert(gates, gate)
end


function gateUpdate(dt)    
    for _, gate in ipairs(gates) do        
        -- Update timers
        if gate.activated and gate.currentAnimation == gate.animations['closed'] then            
            transitionToAnimation(gate, 'opening')
        end

        -- Transition from opening to opened
        if gate.currentAnimation == gate.animations['opening'] then
            updateTimer(gate, 'startAnimationTimer', dt)
            if gate.startAnimationTimer <= 0 then
                transitionToAnimation(gate, 'opened')
            end 
        

        -- Transition from opened to closing
        elseif gate.currentAnimation == gate.animations['opened'] then
            updateTimer(gate, 'enabledTimer', dt)
            if gate.enabledTimer <= 0 then
                transitionToAnimation(gate, 'closing')
            end
        
        
        -- Transition from closing to closed
        elseif gate.currentAnimation == gate.animations['closing'] then
            updateTimer(gate, 'stopAnimationTimer', dt)
            if gate.stopAnimationTimer <= 0 then
                transitionToAnimation(gate, 'closed')                     
                resetGate(gate)
            end                  
        end

        updateCollisionSettings(gate)
        gate.currentAnimation:update(dt)   
    end
end

function transitionToAnimation(gate, animationName)
    gate.currentAnimation = gate.animations[animationName]
    gate.currentAnimation:gotoFrame(1)
end

function updateTimer(gate, timerName, dt)
    gate[timerName] = math.max(gate[timerName] - dt, 0)
end

function updateCollisionSettings(gate)
    -- Update collision settings based on current animation
    if gate.currentAnimation == gate.animations['opened'] then
        gate:setCollisionClass("Gate", {ignores = {"Player"}})
        gate:setSensor(true)
    elseif gate.currentAnimation == gate.animations['closing'] then
        gate:setCollisionClass("Gate")
        gate:setSensor(false)
    end  
end

function gateDraw()
    for i,gate in ipairs(gates) do
        local dx, dy = gate:getPosition()

        -- Closed animation   
        if gate.currentAnimation == gate.animations['closed'] then   
            gate.currentAnimation:draw( gate.spriteSheets['closed'], dx, dy, nil, 1.2, 1, 20, 24)
        
        -- Opening animation
        elseif gate.currentAnimation == gate.animations['opening'] then              
            gate.currentAnimation:draw( gate.spriteSheets['opening'], dx, dy, nil, 1.2, 1, 20, 24)  
        
        -- Opened animation
        elseif gate.currentAnimation == gate.animations['opened'] then   
            gate.currentAnimation:draw( gate.spriteSheets['opened'], dx, dy, nil, 1.2, 1, 20, 24) 
        
        -- Closing animation
        elseif gate.currentAnimation == gate.animations['closing'] then   
            gate.currentAnimation:draw( gate.spriteSheets['closing'], dx, dy, nil, 1.2, 1, 20, 24)          
        end
    end
end

function resetGate(gate)
    gate.activated = false  
    gate.startAnimationTimer = gate.originalStartAnimationTimer
    gate.enabledTimer = gate.originalEnabledTimer  -- Reset using the original value
    gate.stopAnimationTimer = gate.originalStopAnimationTimer  -- Reset using the original value   
end
