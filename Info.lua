-- Displays helpful info to the screen, and does other stuff too.

-- Don't use require because it's wonky with bizhawk? (need to reset bizhawk for
-- changes to propogate, it seems)
local gb = dofile('lib\\gb.lua')
local common = dofile('lib\\common.lua')
local lists = dofile('lib\\lists.lua')

-- Memory constants for seasons (rom)
local giveTreasure = 0x16eb -- TODO: ages is 171c
-- Memory constants for seasons (wram)
local wLoadedObjectGfx = 0xc07
local wStatusBarNeedsRefresh = 0xbea
--

-- Cheat function handlers
function toggleWTW()
    common.pushMemDomain()
    memory.usememorydomain("ROM")

    addr = 0x4000*5 + 0x1c96 -- TODO: ages addr is 05:5da5
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
    item = 0
    item = common.promptByte(function(item)
        name = lists.items[item]
        if name == nil then
            name = ''
        end
        return string.format("Get Item: %.2x %s", item, name)
    end)

    if item == -1 then
        return
    end

    -- Get item level
    level = common.promptByte(function(level)
        return string.format("Level/Amount: %.2x", level)
    end)

    if level == -1 then
        return
    end

    gb.call(giveTreasure, {a=item, c=level})
    memory.writebyte(wStatusBarNeedsRefresh, 0xff)
end


-- Cheat definitions
cheatTable = {}
cheatTable[1] = {name="WTW",  toggle=true,  key="NumberPad1", func=toggleWTW}
cheatTable[2] = {name="ITEM", toggle=false, key="NumberPad5", func=triggerItemMenu}

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
        common.textLine(string.format("%5s %5s: %s", keyname, name, status), color)
    else
        common.textLine(string.format("%5s %5s", keyname, name, status))
    end
end



-- Main code
console.clear()


--gb.call(giveTreasure, {a=0x05,c=0x01})

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
