local common = {}

-- Local variables
local memoryDomains = {n=0}

-- Exported variables
common.keysPressed = {}
common.keysPressedLastFrame = {}
common.keysJustPressed = {}
common.keysPressedAutoRepeat = {}
common.keysPressedAutoRepeatCounter = {}

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
    common.keysPressedAutoRepeat = {}

    local function testKey(k)
        if common.keysPressedLastFrame[k] == nil then
            common.keysJustPressed[k] = true
            common.keysPressedAutoRepeat[k] = true
            common.keysPressedAutoRepeatCounter[k] = 30
            --print(string.format('PRESSED %s', k)) -- uncomment to see key names
        else
            common.keysPressedAutoRepeatCounter[k] = common.keysPressedAutoRepeatCounter[k] - 1
            if common.keysPressedAutoRepeatCounter[k] == 0 then
                common.keysPressedAutoRepeat[k] = true
                common.keysPressedAutoRepeatCounter[k] = 5
            end
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

        if common.keysPressedAutoRepeat['NumberPad8'] then -- Up
            value = value+1
        end
        if common.keysPressedAutoRepeat['NumberPad2'] then -- Down
            value = value-1
        end
        if common.keysPressedAutoRepeat['NumberPad9'] then -- PgUp
            value = value+16
        end
        if common.keysPressedAutoRepeat['NumberPad3'] then -- PgDn
            value = value-16
        end
        if common.keysPressedAutoRepeat['NumberPadEnter'] then
            break
        end
        if common.keysPressedAutoRepeat['Escape'] then
            return -1
        end

        value = math.max(value, minVal)
        value = math.min(value, maxVal)

        gui.text(0, common.PROMPT_ROW * common.ROW_PIXELS, stringGetterFunc(value))
        emu.yield()
    end
    return value
end

-- Like above, but use a list view
function common.promptByteWithList(header, list, opt)
    if header == nil then
        header = "Value"
    end

    local value = 0
    local minVal = 0
    local maxVal = 255

    if not (opt == nil) then
        if not (opt.min == nil) then minVal = opt.min end
        if not (opt.max == nil) then maxVal = opt.max end
    end

    while true do
        common.handleInput()

        if common.keysPressedAutoRepeat['NumberPad8'] then -- Up
            value = value-1
        end
        if common.keysPressedAutoRepeat['NumberPad2'] then -- Down
            value = value+1
        end
        if common.keysPressedAutoRepeat['NumberPad9'] then -- PgUp
            value = value-16
        end
        if common.keysPressedAutoRepeat['NumberPad3'] then -- PgDn
            value = value+16
        end
        if common.keysPressedAutoRepeat['NumberPadEnter'] then
            break
        end
        if common.keysPressedAutoRepeat['Escape'] then
            return -1
        end

        value = math.max(value, minVal)
        value = math.min(value, maxVal)

        -- Draw nearby values in list
        gui.text(0, 4 * common.ROW_PIXELS, header)

        local SCREEN_TOP = 6 * common.ROW_PIXELS
        local size = 16

        local start = math.max(value - size / 2, minVal)
        if start + size > maxVal then
            start = maxVal - size + 1
        end

        for i=0,size-1 do
            index = i+start
            if index >= minVal and index <= maxVal then
                name = list[index]
                if name == nil then
                    name = ''
                end
                if index == value then
                    str = string.format('> %.2x %s', index, name)
                else
                    str = string.format('  %.2x %s', index, name)
                end
                gui.text(0, i * common.ROW_PIXELS + SCREEN_TOP, str) 
            end
        end

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
            if keysPressedAutoRepeat[key] or keysPressedAutoRepeat[v] then
                inputString = inputString .. v
            end
        end

        if keysPressedAutoRepeat["Escape"] then
            return
        end

        if keysPressedAutoRepeat["Backspace"] then
            inputString = inputString:sub(1, -2)
        end

        gui.text(0, PROMPT_ROW * ROW_PIXELS, "Number: " .. inputString)
        emu.yield()
    end

    return inputString
end

-- Set a bit in a bitset (ie. global flags)
function common.setFlag(addr, flag)
    local addr = addr + flag / 8
    local b = bit.lshift(1, bit.band(flag, 7))

    local m = memory.readbyte(addr)
    m = bit.bor(m, b)
    memory.writebyte(addr, m)
end

-- Unset a bit in a bitset (ie. global flags)
function common.clearFlag(addr, flag)
    addr = addr + flag / 8
    local b = bit.lshift(1, bit.band(flag, 7))

    local m = memory.readbyte(addr)
    m = bit.band(m, bit.bxor(0xff, b))
    memory.writebyte(addr, m)
end

return common
