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
local wLoadedObjectGfx = ocl.AgSe(0xc08, 0xc07)
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

function triggerClearFlag()
    local flag = common.promptByteWithList("Clear Flag...", lists.globalFlags)
    if not (flag == -1) then
        common.clearFlag(wGlobalFlags, flag)
    end
end

function triggerSetFlag()
    flag = common.promptByteWithList("Set Flag...", lists.globalFlags)
    if not (flag == -1) then
        common.setFlag(wGlobalFlags, flag)
    end
end


-- Cheat definitions
cheatTable = {}
cheatTable[1] = {name="WTW",  toggle=true,  key="NumberPad1", func=toggleWTW}
cheatTable[2] = {name="RING", toggle=false, key="NumberPad4", func=triggerRingMenu}
cheatTable[3] = {name="ITEM", toggle=false, key="NumberPad5", func=triggerItemMenu}
cheatTable[4] = {name="CLEARFLAG", toggle=false, key="NumberPad8", func=triggerClearFlag}
cheatTable[5] = {name="SETFLAG",   toggle=false, key="NumberPad9", func=triggerSetFlag}

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
    gui.clearGraphics()

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
