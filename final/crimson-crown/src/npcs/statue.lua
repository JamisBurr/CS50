statues = {}    


function statueSpawn(x, y)
    local statueWidth = 128
    local statueHeight = 112
    statue = world:newRectangleCollider(x, y, statueWidth/4, statueHeight/2, {collision_class = "Statue", isSensor = true})
    statue:setType('static')  
    statue.spriteSheets = {}
    statue.spriteSheets['idle'] = love.graphics.newImage("sprites/statues/statue(128x112).png")
    idleGrid = anim8.newGrid(128, 112, statue.spriteSheets['idle']:getWidth(), statue.spriteSheets['idle']:getHeight()) 
    statue.animations = {}
    statue.animations['idle'] = anim8.newAnimation(idleGrid("1-8", 1), 0.1)   
    statue.animation = statue.animations['idle'] 
    local statueTextbox = false
    statueTimer = 0 
    table.insert(statues, statue)
end

function statueUpdate(dt)
    if statue.body then       
        for i, s in ipairs(statues) do            
            s.animation:update(dt)                     
        end
    end
end

function statueDraw()
    for i,s in ipairs(statues) do
        local sx, sy = s:getPosition()
        s.animation:draw( s.spriteSheets['idle'], sx - 52, sy - 60, nil, 1, 1)
    end
end

