-- Oracles stuff
local ocl = {}

local common = dofile('lib\\common.lua')
local gb = dofile('lib\\gb.lua')

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


-- Takes an object type (ie. "ocl.InteractionObject") as a parameter.
local function getFreeSlot(objType)
    for i=objType.startAddr, objType.endAddr, 0x100 do
        if memory.readbyte(i) == 0 then
            return i
        end
    end

    return -1
end

function ocl.spawnObject(objType, id, subid, x, y)
    common.pushMemDomain()
    gb.useWram()

    local addr = getFreeSlot(objType)
    if addr == -1 then
        common.popMemDomain()
        return -1
    end

    print(string.format('ADDR %.4x', addr))
    memory.writebyte(addr, 0x01)
    memory.writebyte(addr+1, id)
    memory.writebyte(addr+2, subid)
    memory.writebyte(addr+0xd, x)
    memory.writebyte(addr+0xb, y)
    common.popMemDomain()
    return addr
end


ocl.InteractionObject = {
    name = 'Interaction',
    startAddr = 0x1240,
    endAddr   = 0x1f40
}
ocl.EnemyObject = {
    name = 'Enemy',
    startAddr = 0x1080,
    endAddr   = 0x1f80
}
ocl.PartObject = {
    name = 'Part',
    startAddr = 0x10c0,
    endAddr   = 0x1fc0
}

return ocl
