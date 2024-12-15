transpads = {}

function transpadSpawn(x, y, transpadID)
    transpad = world:newRectangleCollider(x, y + 6, 32, 9, {collision_class = "Transpad", isSensor = true})
    transpad:setType('static')
    transpad.activated = false
    transpad.transpadID = transpadID
    table.insert(transpads, tranpad)   
end

function transpadUpdate(dt)
    for i, transpad in ipairs(transpads) do
        local px, py = player:getPosition()        
        local dx, dy = transpad:getPosition()   

        -- Find the specific switch that activates this transpad
        local activatingTranspad = nil
        for _, t in ipairs(transpads) do
            if t.transpadID == transpad.transpadID then
                activatingTranspad = t
                break
            end
        end
        
        if transpad.activated then
        end
    end  
end          

-- This function finds the destination transpad for a given transpad
function getDestinationTranspad(currentTranspad)
    for _, transpad in ipairs(transpads) do
        if transpad.transpadID == currentTranspad.transpadID and transpad ~= currentTranspad then
            return transpad
        end
    end
    return nil
end