oldman = {}    


function oldmanSpawn(x, y)
    oldman = world:newRectangleCollider(x, y, 10, 22, {collision_class = "Oldman", isSensor = true})
    
    oldman.spriteSheets = {}
    oldman.spriteSheets['idle'] = love.graphics.newImage("sprites/npcs/oldman(48x64).png")
    idleGrid = anim8.newGrid(64, 48, oldman.spriteSheets['idle']:getWidth(), oldman.spriteSheets['idle']:getHeight()) 
    oldman.animations = {}
    oldman.animations['idle'] = anim8.newAnimation(idleGrid("1-35", 1), 0.1)   
    oldman.animation = oldman.animations['idle'] 
    local oldmanTextbox = false
    textTimer = 0
    table.insert(oldman, oldman)
end

function oldmanText()
    if textTimer > 0 then
        local wx, wy = oldman:getPosition()
        local spriteWidth, spriteHeight = oldman.spriteSheets['idle']:getDimensions()
        local textWidth, textHeight = 150, 100 -- adjust these values to fit your text

        -- calculate the position of the text
        local x = wx - spriteWidth/2 + (spriteWidth - textWidth)/2
        local y = wy - spriteHeight/2 + (spriteHeight - textHeight)/2

        -- draw the text
        love.graphics.setColor(0, 0, 0)
        --love.graphics.rectangle("fill", x, y - 50, textWidth, textHeight - 40)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("The oldman are always watching!", x + 38, y + 10, textWidth, "center", 0, 0.5)
    end
end

function oldmanUpdate(dt)
    if player.body then       
        for i, w in ipairs(oldman) do
            local px, py = player:getPosition()
            local wx, wy = oldman:getPosition()
            local distanceTooldman = distance(px, py, wx, wy)  
            if textTimer > 0 then
                textTimer = textTimer - dt  -- decrease the timer
            end   

            if distanceTooldman < 50 and love.keyboard.isDown("e") then                
                oldmanTextbox = true
                textTimer = 5
                oldmanText(w)
                player:setCanMove(true)
                player:setCanJump(false)
                player:setCanDash(false)
                player:setCanAttack(false)
                player:setCanTeleport(false)

            elseif not love.keyboard.isDown("e") then                
                player:setCanMove(true)
                player:setCanJump(true)
                player:setCanDash(true)
                player:setCanAttack(true)
                player:setCanTeleport(true)
                
            end 
            w.animation:update(dt)                     
        end
    end
end

function oldmanDraw()
    for i,w in ipairs(oldman) do
        local wx, wy = w:getPosition()
        w.animation:draw( w.spriteSheets['idle'], wx + 1, wy - 15, nil, 1, 1, 32, 22)
    end
end

