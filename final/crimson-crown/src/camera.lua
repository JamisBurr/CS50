-- camera.lua
local cameraFile = require "libraries/hump/camera"

cam = cameraFile.new(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2)

function cameraInit()       
    cam:zoom(5)
end

function cameraLookAt()
    if player.currentLevel == "LevelBoss" then
        cam:lookAt(camX, camY - 35)   
    else
        cam:lookAt(camX, camY) 
    end
end

function cameraAttach()
    cam:attach() 
end

function cameraDetach()
    cam:detach()
end