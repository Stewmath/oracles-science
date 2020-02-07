local pkg = {}

local memoryDomains = {}
local numMemoryDomains = 0

function pkg.pushMemDomain()
    numMemoryDomains = numMemoryDomains+1
    memoryDomains[numMemoryDomains] = memory.getcurrentmemorydomain()
end

function pkg.popMemDomain()
    memory.usememorydomain(memoryDomains[numMemoryDomains])
    memoryDomains[numMemoryDomains] = nil
    numMemoryDomains = numMemoryDomains-1
end

-- Currently unused/untested: prompt for a number.
function pkg.promptNumber()
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

return pkg
