teleports = {}

function teleportSpritesheets()
    -- Load sprite sheet    
    local spriteSheets = {}
    spriteSheets['teleport'] = love.graphics.newImage("sprites/teleports/teleport.png")  
    return spriteSheets
end

function teleportAnimations(spriteSheets)
   -- Create grid for animation
   local teleportGrid = anim8.newGrid(189, 90, spriteSheets['teleport']:getWidth(), spriteSheets['teleport']:getHeight()) 
  

   -- Create animations
   local animations = {}    
   animations['teleport'] = anim8.newAnimation(teleportGrid('1-24', '1-3'), 0.1)    
   return animations
end

function teleportSpawn(x, y)
    teleport = world:newRectangleCollider(x, y + 6, 189, 90, {collision_class = "Teleport"})
    teleport:setType('static')
    teleport.activated = false
    teleport.startAnimationTimer = 0
    teleport.enabledTimer = 0
    teleport.stopAnimationTimer = 0    
    teleport.spriteSheets = teleportSpritesheets()
    teleport.animations = teleportAnimations(teleport.spriteSheets)
    teleport.animations['teleport']:gotoFrame(58)  -- Set to the last frame (24th column of 3rd row) for idle
    teleport.currentAnimation = teleport.animations['teleport']  
    
    table.insert(teleports, teleport)   
end

function teleportUpdate(dt)
    if teleports and #teleports > 0 then       
        for i, t in ipairs(teleports) do
            local px, py = player:getPosition()
            local tx, ty = t:getPosition()                
        end        
    end
end

function teleportDraw()
    for i, t in ipairs(teleports) do
        local tx, ty = t:getPosition()        
        -- If there is no current animation set for the teleport, default to the last frame of the teleport animation
        if not t.currentAnimation then
            t.animations['teleport']:gotoFrame(58)  -- Set to the last frame (idle frame)
            t.animations['teleport']:draw(t.spriteSheets['teleport'], tx, ty, nil, 1, 1, 94, 45)
        else
            t.currentAnimation:draw(t.spriteSheets['teleport'], tx, ty, nil, 1, 1, 94, 45)
        end
    end
end