-- Displays helpful info to the screen, and does other stuff too.

-- Don't use require because it's wonky with bizhawk? (need to reset bizhawk for
-- changes to propogate, it seems)
local gb = dofile('lib\\gb.lua')
local common = dofile('lib\\common.lua')
local lists = dofile('lib\\lists.lua')

local COL_PIXELS = 16
local ROW_PIXELS = 16

local PROMPT_ROW = 20

-- Memory constants for seasons (rom)
local giveTreasure = 0x16eb -- TODO: ages is 171c
-- Memory constants for seasons (wram)
local wLoadedObjectGfx = 0xc07
local wStatusBarNeedsRefresh = 0xbea
--

keysPressed = {}
keysPressedLastFrame = {}
keysJustPressed = {}


-- Update the "keysJustPressed" structure
function handleInput()
    keysPressedLastFrame = keysPressed
    keysPressed = input.get()
    keysJustPressed = {}

    local function testKey(k)
        if keysPressedLastFrame[k] == nil then
            keysJustPressed[k] = true
            --print(string.format('PRESSED %s', k)) -- uncomment to see key names
        end
    end

    table.foreach(keysPressed, testKey)
end


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
    while true do
        handleInput()

        if keysJustPressed['NumberPad8'] and item < 255 then
            item = item+1
        end
        if keysJustPressed['NumberPad2'] and item > 0 then
            item = item-1
        end
        if keysJustPressed['NumberPadEnter'] then
            break
        end
        if keysJustPressed['Escape'] then
            return
        end

        name = lists.items[item]
        if name == nil then
            name = ''
        end
        gui.text(0, PROMPT_ROW * ROW_PIXELS, string.format("Get Item: %.2x %s", item, name))
        emu.yield()
    end

    level = 0
    -- Get item level (TODO: factor out into function)
    while true do
        handleInput()

        if keysJustPressed['NumberPad8'] and level < 255 then
            level = level+1
        end
        if keysJustPressed['NumberPad2'] and level > 0 then
            level = level-1
        end
        if keysJustPressed['NumberPadEnter'] then
            break
        end
        if keysJustPressed['Escape'] then
            return
        end

        gui.text(0, PROMPT_ROW * ROW_PIXELS, string.format("Level/Amount: %.2x", level))
        emu.yield()
    end

    gb.call(giveTreasure, {a=item, c=level})
    memory.writebyte(wStatusBarNeedsRefresh, 0xff)
end


-- Cheat definitions
cheatTable = {}
cheatTable[1] = {"WTW",  "NumberPad1", toggleWTW}
cheatTable[2] = {"ITEM", "NumberPad5", triggerItemMenu}

cheatEnabled = {}


-- Display cheats and check for toggles
function handleCheat(cheat)
    local cheat = cheatTable[cheat]
    local name = cheat[1]
    local key = cheat[2]
    local toggleFunc = cheat[3]

    if keysJustPressed[key] then
        toggleFunc()
    end

    local status
    if cheatEnabled[name] then
        status = "ON "
    else
        status = "OFF"
    end
    local keyname = string.gsub(key, 'NumberPad', 'NP')
    gui.text(x + COL_PIXELS, y, string.format("[%5s] %5s: %s", keyname, name, status))
    y = y+ROW_PIXELS
end



-- Main code
console.clear()


--gb.call(giveTreasure, {a=0x05,c=0x01})

while true do
    handleInput()
    gui.clearGraphics()

    gb.useWram()
    local numLoadedObjGfx = 0
    for addr = wLoadedObjectGfx, wLoadedObjectGfx+0x10, 2 do
        if not (memory.read_u8(addr) == 0) then
            numLoadedObjGfx = numLoadedObjGfx+1
        end
    end

    -- Display variables
    x = 0
    y = 8*ROW_PIXELS

    gui.text(x, y, string.format("X: %.2x <%.2x>", memory.read_u8(0x100d), memory.read_u8(0x100c)))
    y = y+ROW_PIXELS
    gui.text(x, y, string.format("Y: %.2x <%.2x>", memory.read_u8(0x100b), memory.read_u8(0x100a)))
    y = y+ROW_PIXELS
    gui.text(x, y, string.format("Knockback timer: %.2x", memory.read_u8(0x102d), memory.read_u8(0x100a)))
    y = y+ROW_PIXELS
    gui.text(x, y, string.format("Knockback angle: %.2x", memory.read_u8(0x102c), memory.read_u8(0x100a)))
    y = y+ROW_PIXELS

    y = y+ROW_PIXELS

    -- This can cause lag when unpausing
    gui.text(x, y, string.format("# loaded obj gfx: %d", numLoadedObjGfx))
    y = y+ROW_PIXELS
    --gui.text(x, y, string.format("%s", input.get()["NumberPad1"] == nil))

    -- Cheats
    y = y+ROW_PIXELS
    gui.text(x, y, "CHEATS")
    y = y+ROW_PIXELS

    for cheat in pairs(cheatTable) do
        handleCheat(cheat)
    end

    emu.yield()
    --emu.frameadvance()
end
