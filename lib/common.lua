local common = {}

-- Local variables
local memoryDomains = {n=0}

-- Exported variables
common.keysPressed = {}
common.keysPressedLastFrame = {}
common.keysJustPressed = {}

common.COL_PIXELS = 16
common.ROW_PIXELS = 16
common.PROMPT_ROW = 15

common.currentRow = 0



-- Exported functions

function common.pushMemDomain()
    memoryDomains.n = memoryDomains.n+1
    memoryDomains[memoryDomains.n] = memory.getcurrentmemorydomain()
end

function common.popMemDomain()
    memory.usememorydomain(memoryDomains[memoryDomains.n])
    memoryDomains[memoryDomains.n] = nil
    memoryDomains.n = memoryDomains.n-1
end

-- Update the "common.keysJustPressed" structure
function common.handleInput()
    common.keysPressedLastFrame = common.keysPressed
    common.keysPressed = input.get()
    common.keysJustPressed = {}

    local function testKey(k)
        if common.keysPressedLastFrame[k] == nil then
            common.keysJustPressed[k] = true
            --print(string.format('PRESSED %s', k)) -- uncomment to see key names
        end
    end

    table.foreach(common.keysPressed, testKey)
end


-- Draw a line of text, update "currentRow" to next line
function common.textLine(text, color)
    gui.text(0, common.ROW_PIXELS * common.currentRow, text, color)
    common.currentRow = common.currentRow+1
end

-- Have the user input a byte using the numpad direction keys.
function common.promptByte(stringGetterFunc)
    if stringGetterFunc == nil then
        stringGetterFunc = function(val)
            return string.format('Value: %.2x', val)
        end
    end

    local value = 0
    local minVal = 0
    local maxVal = 255

    while true do
        common.handleInput()

        if common.keysJustPressed['NumberPad8'] then -- Up
            value = value+1
        end
        if common.keysJustPressed['NumberPad2'] then -- Down
            value = value-1
        end
        if common.keysJustPressed['NumberPad9'] then -- PgUp
            value = value+16
        end
        if common.keysJustPressed['NumberPad3'] then -- PgDn
            value = value-16
        end
        if common.keysJustPressed['NumberPadEnter'] then
            break
        end
        if common.keysJustPressed['Escape'] then
            return -1
        end

        value = math.max(value, minVal)
        value = math.min(value, maxVal)

        gui.text(0, common.PROMPT_ROW * common.ROW_PIXELS, stringGetterFunc(value))
        emu.yield()
    end
    return value
end


-- Currently unused/untested: prompt for a number via numpad inputs as actual
-- numbers, instead of as up/down/pgup/pgdown.
function common.promptNumberAlternate()
    local inputString = ""
    while #inputString < 4 do
        handleInput()
        for _,v in ipairs({0,1,2,3,4,5,6,7,8,9}) do
            local key = "NumberPad" .. tostring(v)
            if keysJustPressed[key] or keysJustPressed[v] then
                inputString = inputString .. v
            end
        end

        if keysJustPressed["Escape"] then
            return
        end

        if keysJustPressed["Backspace"] then
            inputString = inputString:sub(1, -2)
        end

        gui.text(0, PROMPT_ROW * ROW_PIXELS, "Number: " .. inputString)
        emu.yield()
    end

    return inputString
end

return common
