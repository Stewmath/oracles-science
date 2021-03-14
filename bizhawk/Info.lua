-- Displays helpful info to the screen, and does other stuff too.

console.clear()

-- Don't use require because it's wonky with bizhawk? (need to reset bizhawk for
-- changes to propogate, it seems)
local common = dofile('lib\\common.lua')
local gb     = dofile('lib\\gb.lua')
local lists  = dofile('lib\\lists.lua')
local ocl    = dofile('lib\\ocl.lua')

-- Memory constants (rom)
local giveTreasure = ocl.AgSe(0x171c, 0x16eb)
-- Memory constants (wram)
local wActiveRing = ocl.AgSe(0x6cb, 0x6c5)
local wGlobalFlags = ocl.AgSe(0x6d0, 0x6ca)
local wStatusBarNeedsRefresh = ocl.AgSe(0xbe9, 0xbea)
local wLoadedObjectGfx = ocl.AgSe(0xc08, 0xc07)
local wActiveRoom = ocl.AgSe(0xc30, 0xc4c)
local wActiveRoom = ocl.AgSe(0xc30, 0xc4c)
--

-- Cheat function handlers
function toggleWTW()
    common.pushMemDomain()
    memory.usememorydomain("ROM")

    local addr = 0x4000*5 + ocl.AgSe(0x1da5, 0x1c96)
    if memory.readbyte(addr) == 0xaf then
        memory.writebyte(addr, 0x1a) -- ld a,(de)
        cheatEnabled['WTW'] = nil
    else
        memory.writebyte(addr, 0xaf) -- xor a
        cheatEnabled['WTW'] = true
    end
    common.popMemDomain()
end

function triggerItemMenu()
    -- Get item type
    local item = common.promptByteWithList("Get Item...", lists.items)

    if item == -1 then
        return
    end

    -- Get item level
    local level = common.promptByte(function(level)
        return string.format("Level/Amount: %.2x", level)
    end)

    if level == -1 then
        return
    end

    gb.call(giveTreasure, {a=item, c=level})
    memory.writebyte(wStatusBarNeedsRefresh, 0xff)
end

function triggerRingMenu()
    local ring = common.promptByteWithList("Set Active Ring...", lists.rings, {min=0, max=0x40})
    if ring == -1 then return end
    memory.writebyte(wActiveRing, ring)
end

function triggerObjectMenu()
    local objectIndex = common.promptByteWithList('Object type', {'Interaction', 'Enemy', 'Part'}, {min=1, max=3})
    if objectIndex == -1 then return end
    local objectType = { ocl.InteractionObject, ocl.EnemyObject, ocl.PartObject }
    objectType = objectType[objectIndex]

    local id = common.promptByte(string.format('%s ID', objectType.name))
    if id == -1 then return end
    local subid = common.promptByte('SubID')
    if subid == -1 then return end

    while true do
        common.handleInput()
        local mouse = input.getmouse()

        if common.keysJustPressed['Escape'] then
            return
        end

        local x = mouse.X
        local y = mouse.Y

        local inBounds = (not (x == nil)) and not ((y == nil)) and x >= 0 and x < 160 and y >= 0 and y < 144

        if inBounds then
            local roundX = bit.band(x, 0xf8)
            local roundY = bit.band(y, 0xf8)
            gui.drawRectangle(roundX, roundY, 8, 8)

            if mouse.Left then
                local ret = ocl.spawnObject(objectType, id, subid, roundX, roundY)
                if ret == -1 then
                    print(string.format("Couldn't spawn %s %.2x%.2x.", objectType.name, id, subid))
                end
                break
            end
        end
        gui.DrawFinish()
        emu.yield()
    end
end

function triggerRoomFlagMenu()
    function getFlagLocation() -- FIXME
        return 0x0700
    end
    list = {'', '', '', 'Visited', '', '', ''}
    list[0] = 'Layout'
    flagAddr = getFlagLocation() + memory.readbyte(wActiveRoom)
    common.editBitset('Edit room flags...', flagAddr, list)
end

function triggerGlobalFlagMenu()
    common.editBitset("Edit global flags...", wGlobalFlags, lists.globalFlags)
end


-- Cheat definitions
cheatTable = {}
cheatTable[1] = {name="WTW",  toggle=true,  key="NumberPad1", func=toggleWTW}
cheatTable[4] = {name="RING", toggle=false, key="NumberPad4", func=triggerRingMenu}
cheatTable[5] = {name="ITEM", toggle=false, key="NumberPad5", func=triggerItemMenu}
cheatTable[6] = {name="OBJECT", toggle=false, key="NumberPad6", func=triggerObjectMenu}
cheatTable[7] = {name="ROOMFLAG", toggle=false, key="NumberPad7", func=triggerRoomFlagMenu}
cheatTable[8] = {name="GLOBALFLAG", toggle=false, key="NumberPad8", func=triggerGlobalFlagMenu}

cheatEnabled = {}


-- Display cheats and check for toggles
function handleCheat(cheat)
    local name = cheat.name
    local key = cheat.key
    local toggleFunc = cheat.func

    if common.keysJustPressed[key] then
        toggleFunc()
    end

    local status
    if cheatEnabled[name] then
        status = "ON "
        color = 'lightgreen'
    else
        status = "OFF"
        color = nil
    end
    local keyname = string.gsub(key, 'NumberPad', 'NP')
    if cheat.toggle then
        common.textLine(string.format("%5s %s: %s", keyname, name, status), color)
    else
        common.textLine(string.format("%5s %s", keyname, name, status))
    end
end



-- Main code
while true do
    common.handleInput()
    gui.cleartext()

    gb.useWram()
    local numLoadedObjGfx = 0
    for addr = wLoadedObjectGfx, wLoadedObjectGfx+0x10, 2 do
        if not (memory.read_u8(addr) == 0) then
            numLoadedObjGfx = numLoadedObjGfx+1
        end
    end

    -- Display variables
    common.currentRow = 8

    common.textLine(string.format("X: %.2x.%.2x", memory.read_u8(0x100d), memory.read_u8(0x100c)))
    common.textLine(string.format("Y: %.2x.%.2x", memory.read_u8(0x100b), memory.read_u8(0x100a)))
    common.textLine(string.format("Knockback timer: %.2x", memory.read_u8(0x102d), memory.read_u8(0x100a)))
    common.textLine(string.format("Knockback angle: %.2x", memory.read_u8(0x102c), memory.read_u8(0x100a)))

    common.textLine('')

    -- This can cause lag when unpausing
    common.textLine(string.format("# loaded obj gfx: %d", numLoadedObjGfx))

    -- Cheats
    common.textLine("")
    common.textLine("CHEATS")

    for cheat in pairs(cheatTable) do
        handleCheat(cheatTable[cheat])
    end

    emu.yield()
    --emu.frameadvance()
end
