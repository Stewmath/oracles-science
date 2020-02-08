-- Oracles stuff
local ocl = {}

local common = dofile('lib\\common.lua')

function ocl.isAges()
    common.pushMemDomain()

    memory.usememorydomain('ROM')
    data = memory.readbyterange(0x134, 11)
    str = 'ZELDA NAYRU'
    for i=0,#str-1 do
        if not (str:byte(i+1) == data[i]) then
            common.popMemDomain()
            return false
        end
    end

    common.popMemDomain()
    return true
end

function ocl.isSeasons()
    common.pushMemDomain()

    memory.usememorydomain('ROM')
    local data = memory.readbyterange(0x134, 9)
    local str = 'ZELDA DIN'
    for i=0,#str-1 do
        if not (str:byte(i+1) == data[i]) then
            common.popMemDomain()
            return false
        end
    end

    common.popMemDomain()
    return true
end

-- Choose value for ages or seasons
function ocl.AgSe(ag, se)
    if ocl.isAges() then
        return ag
    elseif ocl.isSeasons() then
        return se
    else
        assert(false)
    end
end

return ocl
