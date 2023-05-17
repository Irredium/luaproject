-- Game constants
local screenWidth = 800
local screenHeight = 600
local textSpeed = 100 -- Adjust the speed as needed
local maxTextLength = 15 -- Maximum characters in a text string
local inputTextSize = 24 -- Font size of the input text

-- List of texts
local texts = {}

-- Current user input
local userInput = ""

-- Game variables
local userLives = 3
local userScore = 0

-- Menu variables
local menuOptions = {"Start", "Level", "Quit"}
local selectedOption = 1
local level = 1
local levelOptions = {3, 5, 7}

-- Function to generate a new text string
local function generateText()
    local characters = "abcdefghijklmnopqrstuvwxyz"
    local length = love.math.random(levelOptions[level], levelOptions[level] + 1)
    local text = ""
    for i = 1, length do
        local index = love.math.random(1, #characters)
        text = text .. characters:sub(index, index)
    end
    local textObj = {
        value = text,
        x = love.math.random(0, screenWidth),
        y = -20 -- Starting position above the screen
    }
    table.insert(texts, textObj)
end

-- Function to check user input
local function checkInput(textObj)
    if textObj.value == userInput then
        -- Text matched user input
        return true
    end
    return false
end

-- Clamp a value between a minimum and maximum
local function clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

function love.load()
    love.window.setMode(screenWidth, screenHeight)
    love.keyboard.setKeyRepeat(true)
end

function love.textinput(text)
    if selectedOption == 1 then
        userInput = userInput .. text
    end
end

function love.keypressed(key)
    if selectedOption == 1 then
        if key == "backspace" then
            userInput = userInput:sub(1, -2)
        elseif key == "return" then
            if userInput ~= "" then
                generateText()
                userInput = ""
            end
        end
    elseif selectedOption == 2 then
        if key == "left" then
            level = clamp(level - 1, 1, 3)
        elseif key == "right" then
            level = clamp(level + 1, 1, 3)
        end
    elseif selectedOption == 3 then
        if key == "return" then
            love.event.quit()
        end
    end

    if key == "up" then
        selectedOption = selectedOption - 1
        if selectedOption < 1 then
            selectedOption = #menuOptions
        end
    elseif key == "down" then
        selectedOption = selectedOption + 1
        if selectedOption > #menuOptions then
            selectedOption = 1
        end
    elseif key == "return" then
        if selectedOption == 1 then
            texts = {}
            userLives = 3
            userScore = 0
            generateText()
            userInput = ""
        end
    end
end

function love.update(dt)
    if selectedOption == 1 then
        -- Move texts down the screen
        for i = #texts, 1, -1 do
            local textObj = texts[i]
            textObj.y = textObj.y + textSpeed * dt
            textObj.x = clamp(textObj.x, 0, screenWidth - inputTextSize * #textObj.value)
            if textObj.y > screenHeight then
                -- Text reached the bottom without being typed
                table.remove(texts, i)
                generateText()
                userLives = userLives - 1
            elseif checkInput(textObj) then
                -- Text matched user input
                table.remove(texts, i)
                generateText()
                if #userInput == #textObj.value then
                    userScore = userScore + 100 -- Add 100 points for completing a word
                else
                    userScore = userScore + 10 -- Add 10 points for each correct letter
                end
                userInput = ""
            end
        end
    end
end

function love.draw()
    if selectedOption == 1 then
        -- Draw the text
        for i, textObj in ipairs(texts) do
            love.graphics.print(textObj.value, textObj.x, textObj.y)
        end

        -- Draw the user input
        local inputTextWidth = love.graphics.getFont():getWidth(userInput)
        local inputTextX = (screenWidth - inputTextWidth) / 2
        love.graphics.setFont(love.graphics.newFont(inputTextSize))
        love.graphics.print(userInput, inputTextX, screenHeight - 30 - inputTextSize)

        -- Draw the red box
        local boxHeight = 20
        love.graphics.setColor(1, 0, 0) -- Set color to red
        love.graphics.rectangle("fill", 0, screenHeight - boxHeight, screenWidth, boxHeight)

        -- Reset color to white
        love.graphics.setColor(1, 1, 1)

        -- Draw user lives and score
        love.graphics.print("Lives: " .. userLives, 10, 10)
        love.graphics.print("Score: " .. userScore, 10, 30)
    else
        -- Draw the main menu when arrow keys are pressed
        local menuX = screenWidth / 2 - 50
        local menuY = screenHeight / 2 - 30
        local optionY = menuY
        local optionSpacing = 30

        for i, option in ipairs(menuOptions) do
            if selectedOption == i then
                love.graphics.setColor(1, 0, 0) -- Set color to red for selected option
            else
                love.graphics.setColor(1, 1, 1) -- Set color to white for unselected options
            end
            love.graphics.print(option, menuX, optionY)
            optionY = optionY + optionSpacing
        end

        -- Draw the level selection and current level when arrow keys pressed
        if selectedOption == 2 then
            love.graphics.setColor(1, 0, 0) -- Set color to red for arrows
        else
            love.graphics.setColor(1, 1, 1) -- Set color to white for arrows
        end
        love.graphics.print("Level: " .. level, menuX + 120, menuY + optionSpacing)
    end
end
