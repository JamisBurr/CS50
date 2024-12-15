local saveManager = {}

configData = {
    keyboard = true,
    controller = false,
}

local saveData = {
    currentLevel = "Level1",
    playerProgress = "Default",
    hasSword = false,
    hasKey = false,
    hasDash = false,
    hasTeleport = false,
    hasDeflect = false,
    hasDash2 = false,
    hasDJump = false,
    shopDialogueExhausted = false,
    exhaustedWatcherIDs = {},
    elapsedTime = 0,
    keyboard = false,
    controller = false,
}

function saveManager.resetToDefaults()
    saveData = {
        currentLevel = "Level1",
        playerProgress = "Default",
        hasSword = false,
        hasKey = false,
        hasDash = false,
        hasTeleport = false,
        hasDeflect = false,
        hasDash2 = false,
        hasDJump = false,
        shopDialogueExhausted = false,
        exhaustedWatcherIDs = {},
        elapsedTime = 0,        
    }
end

local function serialize(t)
    local serializedValues = {}
    local value, serializedValue
    for k, v in pairs(t) do
        if type(v) == "table" then
            serializedValue = serialize(v)
        elseif type(v) == "number" then
            serializedValue = tostring(v)
        elseif type(v) == "string" then
            serializedValue = string.format("%q", v)
        elseif type(v) == "boolean" then
            serializedValue = v and "true" or "false"
        else
            -- We don't handle other data types for simplicity
            serializedValue = "nil"
        end
        table.insert(serializedValues, string.format("[%q] = %s", k, serializedValue))
    end
    return "{\n   " .. table.concat(serializedValues, ";\n   ") .. "\n}"
end

function saveManager.save()
    local gameDataStr = "return " .. serialize({saveData = saveData, configData = configData})
    print("Save function called!")
    print("Data to be saved:", gameDataStr)
    love.filesystem.write("data.lua", gameDataStr)
end

function saveManager.load()
    if love.filesystem.getInfo("data.lua") then
        local loadedData = love.filesystem.load("data.lua")()
        saveData = loadedData.saveData or saveData
        configData = loadedData.configData or configData
        return saveData, configData
    else
        return nil, nil
    end
end

function saveManager.get(key)
    return saveData[key]
end

function saveManager.set(key, value)
    saveData[key] = value
    print("Set function called!")
    print("Key:", key)
    print("Value:", value)
end

return saveManager