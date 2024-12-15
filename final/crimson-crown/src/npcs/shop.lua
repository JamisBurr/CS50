shops = {}    


function shopSpawn(x, y)
    local shopWidth = 53
    local shopHeight = 39

    shop = world:newRectangleCollider(x, y + 24, shopWidth, shopHeight, {collision_class = "Shop", isSensor = true})
    shop:setType('static')   
    shop.spriteSheets = {}
    shop.spriteSheets['idle'] = love.graphics.newImage("sprites/shops/bloodshop.png")
    idleGrid = anim8.newGrid(83, 69, shop.spriteSheets['idle']:getWidth(), shop.spriteSheets['idle']:getHeight()) 
    shop.animations = {}
    shop.animations['idle'] = anim8.newAnimation(idleGrid("1-5", 1), 0.1)   
    shop.animation = shop.animations['idle'] 
    shop.textbox = false
    questionAdded = false
    shopTimer = 0
    table.insert(shops, shop)
end

function shopUpdate(dt)
    local joystick = love.joystick.getJoysticks()[1]  -- Get the first connected joystick

    if #shops > 0 then       
        for i, s in ipairs(shops) do
            local px, py = player:getPosition()
            local sx, sy = shop:getPosition()
            local dist = distance(px, py, sx, sy)             
            if not shopDialogueExhausted and dist < 20 and 
               (love.keyboard.isDown("e") or (joystick and joystick:isGamepadDown("y"))) then
                -- The player is within range and either "E" is pressed on the keyboard or "A" on the gamepad
                s.textbox = true
            end
            
            if s.textbox then
                if not questionAdded then
                    Npc.shopQuestion()
                    questionAdded = true                    
                end
                
                if Talkies.isOpen() then               
                    Talkies.update(dt)
                    player.currentAnimation = player.animations['idle']
                    player.canMove = false
                    player.canJump = false
                    player.canDash = false
                    player.canCharge = false
                    player.canAttack = false
                    player.canTeleport = false
                    player.canAppear = false                                      
                else
                    player.canMove = true
                    player.canJump = true
                    player.canDash = true
                    player.canCharge = true
                    player.canAttack = true
                    player.canTeleport = true
                    player.canAppear = true
                    s.textbox = false
                    questionAdded = false 
                    dialougeExhausted()                     
                end        
            end
            shop.animation:update(dt)                     
        end
    end
end


function shopDraw()
    for i,s in ipairs(shops) do
        local sx, sy = s:getPosition()
        s.animation:draw(s.spriteSheets['idle'], sx - 83/2, sy - 69/2 - 14)  -- Adjusted the offsets to align the sprite to the collider's center
    end
end

function dialougeExhausted() 
    shopDialogueExhausted = true    -- Load saved state        

    -- Save the updated state to a file
    saveManager.set("shopDialogueExhausted", shopDialogueExhausted)
    saveManager.save()
end