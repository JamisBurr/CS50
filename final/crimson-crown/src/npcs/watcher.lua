watchers = {}    
local activeWatcher = nil

local function isWatcherExhausted(id)
    local exhaustedWatcherIDs = saveManager.get("exhaustedWatcherIDs") or {}
    return exhaustedWatcherIDs[id] == true
end

function watcherSpawn(x, y, obj)
    watcher = world:newRectangleCollider(x, y + 9.5, 10, 22, {collision_class = "Watcher", isSensor = true})
    watcher:setType('static')  
    -- store the watcherID in the watcher object
    watcher.id = obj.properties.watcherID
    watcher.spriteSheets = {} 
    watcher.spriteSheets['idle'] = love.graphics.newImage("sprites/npcs/watcher(48x64).png")
    local idleGrid = anim8.newGrid(64, 48, watcher.spriteSheets['idle']:getWidth(), watcher.spriteSheets['idle']:getHeight()) 
    watcher.animations = {}
    watcher.animations['idle'] = anim8.newAnimation(idleGrid("1-35", 1), 0.1)   
    watcher.animation = watcher.animations['idle'] 
    watcher.textbox = false    
    watcher.abilityAdded = false
    watcherTimer = 0
    table.insert(watchers, watcher)   
    print("Spawning watcher at", x, y, "with properties", watcher.id)
end

function watcherUpdate(dt)    
    local joystick = love.joystick.getJoysticks()[1] 
    
    if #watchers > 0 then       
        for i, w in ipairs(watchers) do
            local px, py = player:getPosition()
            local wx, wy = w:getPosition()
            local dist = distance(px, py, wx, wy)    

            if not isWatcherExhausted(w.id) then                
                if dist < 15 then
                    -- Check for interaction input (keyboard 'e' or controller button)
                    local interactInput = love.keyboard.isDown("e") or (joystick and joystick:isGamepadDown("y"))

                    if interactInput then                       
                        w.textbox = true                       
                    end
                end
            end   

            if w.textbox and player.hasSword then
                if not w.abilityAdded then
                    print("About to display dialogue for watcher with ID:", w.id)                    
                    w.abilityAdded = true                    
                    Npc.watcherHello(w)                                              
                end
                
                if Talkies.isOpen() then               
                    Talkies.update(dt)
                    player.currentAnimation = player.animations['idle']
                    player.canMove = false
                    player.canJump = false
                    player.canDash = false
                    player.canDeflect = false
                    player.canAttack = false
                    player.canTeleport = false
                    player.canAppear = false                           
                else
                    player.canMove = true
                    player.canJump = true
                    player.canDash = true
                    player.canDeflect = true
                    player.canAttack = true
                    player.canTeleport = true
                    player.canAppear = true
                    w.textbox = false   
                    w.abilityAdded = false                                   
                end  
            end              
            w.animation:update(dt)                     
        end
    end
end

     
function watcherDraw()
    for i,w in ipairs(watchers) do
        local wx, wy = w:getPosition()
        w.animation:draw( w.spriteSheets['idle'], wx + 1, wy - 14, nil, 1, 1, 32, 22)
    end
end

function wDialogueExhausted(w) 
    w.dialougeExhausted = true   
    -- Update the exhaustedWatcherIDs list in the save data
    local currentExhaustedIDs = saveManager.get("exhaustedWatcherIDs") or {}
    currentExhaustedIDs[w.id] = true
    saveManager.set("exhaustedWatcherIDs", currentExhaustedIDs)
    saveManager.save()
end