local VirtualMouse = {}

-- Global variables for input mode
useKeyboard = true  -- Initially assume keyboard is used
useController = false  -- Controller is not used initially

function VirtualMouse.new()
    local self = setmetatable({}, {__index = VirtualMouse})
    self.x = love.graphics.getWidth() / 2
    self.y = love.graphics.getHeight() / 2

    -- Initial speed as a percentage of canvas size
    self.baseSpeed = 0.20 -- 5% of canvas size
    self.speedX = love.graphics.getWidth() * self.baseSpeed
    self.speedY = love.graphics.getHeight() * self.baseSpeed

    return self
end


function VirtualMouse:update(dt, joystick)
    -- If using a controller
    if joystick and not useKeyboard then
        -- Dynamically update speed based on canvas size
        local canvasSize = math.min(love.graphics.getWidth(), love.graphics.getHeight())
        local speed = canvasSize * self.baseSpeed

        local xAxis = joystick:getAxis(1)
        local yAxis = joystick:getAxis(2)
       

        -- Deadzone implementation
        local deadzone = 0.1 -- Adjust as needed
        xAxis = math.abs(xAxis) > deadzone and xAxis or 0
        yAxis = math.abs(yAxis) > deadzone and yAxis or 0

        -- Normalize diagonal movement
        local magnitude = math.sqrt(xAxis^2 + yAxis^2)
        local normalizedX = magnitude > 0 and xAxis / magnitude or 0
        local normalizedY = magnitude > 0 and yAxis / magnitude or 0

        -- Update position
        self.x = self.x + normalizedX * speed * dt
        self.y = self.y + normalizedY * speed * dt

        -- Clamp values to screen boundaries
        self.x = math.max(0, math.min(self.x, love.graphics.getWidth()))
        self.y = math.max(0, math.min(self.y, love.graphics.getHeight()))
    end

    -- If using the keyboard, follow the actual mouse
    if useKeyboard then
        local mouseX, mouseY = love.mouse.getPosition()
        self.x, self.y = mouseX / scaleX, mouseY / scaleY
    end
end



function VirtualMouse:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", self.x, self.y, 5)
end

function VirtualMouse:handleClick(button)
    -- Simulate a mouse click here
    -- For example, if your actual mouse click function is handleMousePressedState, then:
    handleMousePressedState(self.x, self.y, button)
end

return VirtualMouse

