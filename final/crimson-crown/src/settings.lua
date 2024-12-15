-- Virtual Resolution
VIRTUAL_WIDTH = 1920
VIRTUAL_HEIGHT = 1080

-- Actual screen dimensions (will be set in settingsInit)
SCREEN_WIDTH, SCREEN_HEIGHT = 0, 0

-- Scale factors
scaleX, scaleY = 1, 1

-- Offset for scaling
offsetX, offsetY = 0, 0

FADE_SPEED = 1.0  -- Adjust this value to control the speed of the fade


function settingsInit()
    love.window.setMode(1920, 1080, {fullscreen = true, vsync = 1})
    love.graphics.setDefaultFilter("nearest", "nearest")

    SCREEN_WIDTH, SCREEN_HEIGHT = love.graphics.getDimensions()
    virtualCanvas = love.graphics.newCanvas(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    
    --[[ Shadow and Blood: Curse of the Crimson Crown ]]
    
    love.window.setTitle("Crimson Crown")

    -- Sounds
    sounds = {}    
    sounds.playerAttack = love.audio.newSource("assets/sfx/playerAttack.wav", "static")
    sounds.enemyHit = love.audio.newSource("assets/sfx/enemyHit.wav", "static")
    sounds.titleMusic = love.audio.newSource("assets/music/musicTitle.mp3", "stream") 
    sounds.gameMusic = love.audio.newSource("assets/music/musicGame.mp3", "stream") 
    sounds.deadMusic = love.audio.newSource("assets/music/deadMusic.mp3", "stream")
    sounds.winMusic = love.audio.newSource("assets/music/winMusic.mp3", "stream")
    sounds.music = sounds.titleMusic
    sounds.music:play()
    sounds.music:setVolume(0)
    sounds.music:setLooping(true)        
    sounds.muted = false
end

function updateScaleFactors()
    -- Calculate aspect ratios
    local aspectRatioVirtual = VIRTUAL_WIDTH / VIRTUAL_HEIGHT
    local aspectRatioScreen = SCREEN_WIDTH / SCREEN_HEIGHT

    -- Determine if letterboxing (top and bottom black bars) or pillarboxing (side black bars) is needed
    if aspectRatioScreen > aspectRatioVirtual then
        -- Pillarboxing
        scaleY = SCREEN_HEIGHT / VIRTUAL_HEIGHT
        scaleX = scaleY  -- Keep uniform scaling
        offsetX = (SCREEN_WIDTH - VIRTUAL_WIDTH * scaleX) / 2
        offsetY = 0
    else
        -- Letterboxing
        scaleX = SCREEN_WIDTH / VIRTUAL_WIDTH
        scaleY = scaleX  -- Keep uniform scaling
        offsetY = (SCREEN_HEIGHT - VIRTUAL_HEIGHT * scaleY) / 2
        offsetX = 0
    end
    print("offsetX:", offsetX, "offsetY:", offsetY)
end



function titleVolume(dt)
    if sounds.music and sounds.music ~= sounds.titleMusic then
        sounds.music:stop()
        sounds.music = sounds.titleMusic
        sounds.music:setLooping(true)  -- Ensure the music is set to loop
        sounds.music:play()
    end

    if sounds.music then
        if not sounds.muted then
            sounds.music:setVolume(0.25)  -- Set to 25% volume
        else
            sounds.music:setVolume(0)
        end
    end
end

function gameVolume(dt)
    if sounds.music ~= sounds.gameMusic then
        sounds.music:stop()
        sounds.music = sounds.gameMusic
        sounds.music:setLooping(true)  -- Ensure the music is set to loop
        sounds.music:play()
    end

    if not sounds.muted then
        sounds.music:setVolume(0.5)  -- Set to 50% volume
    else
        sounds.music:setVolume(0)
    end
end

function deadVolume(dt)
    if sounds.music ~= sounds.deadMusic then
        sounds.music:stop()  -- Stop any other music that might be playing
        sounds.music = sounds.deadMusic
        sounds.music:setLooping(true)  -- Ensure the music is set to loop
        sounds.music:play()
    end

    if not sounds.muted then
        sounds.music:setVolume(0.5)  -- Set to 50% volume
    else
        sounds.music:setVolume(0)
    end
end

function winVolume(dt)
    if sounds.music ~= sounds.winMusic then
        sounds.music:stop()  -- Stop any other music that might be playing
        sounds.music = sounds.winMusic
        sounds.music:setLooping(true)  -- Ensure the music is set to loop
        sounds.music:play()
    end

    if not sounds.muted then
        sounds.music:setVolume(0.5)  -- Set to 50% volume
    else
        sounds.music:setVolume(0)
    end
end


function menuVolume(dt)
    if not sounds.muted then
        -- Restore sound volume for game
        sounds.music:setVolume(.25)
        sounds.muted = false
    else 
        sounds.music:setVolume(0)
        sounds.muted = true
    end    
end


function fadeOutMusic(dt)
    if sounds.music then
        local volume = sounds.music:getVolume()
        volume = math.max(0, volume - dt * FADE_SPEED)  -- FADE_SPEED is a constant, e.g., 1.0
        sounds.music:setVolume(volume)

        if volume == 0 then
            sounds.music:stop()
            sounds.music = nil  -- Clear the current music
            return true  -- Indicate that fade out is complete
        end
    end
    return false
end

function fadeInMusic(dt, newMusic)
    if not sounds.music then
        sounds.music = newMusic
        sounds.music:setVolume(0)
        sounds.music:play()
    else
        local volume = sounds.music:getVolume()
        volume = math.min(1, volume + dt * FADE_SPEED)  -- FADE_SPEED is the same constant
        sounds.music:setVolume(volume)

        if volume == 1 then
            return true  -- Indicate that fade in is complete
        end
    end
    return false
end

return settings