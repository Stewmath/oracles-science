-- Displays helpful info to the screen, and does other stuff too.

local COL_PIXELS = 16
local ROW_PIXELS = 16

-- Memory constants for seasons (wram)
local wLoadedObjectGfx = 0xc07
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
    print('TOGGLE')
    memory.usememorydomain("ROM")

    addr = 0x4000*5 + 0x1c96 -- TODO: ages addr is 05:5da5
    if memory.readbyte(addr) == 0xaf then
        memory.writebyte(addr, 0x1a) -- ld a,(de)
        cheatEnabled['WTW'] = nil
    else
        memory.writebyte(addr, 0xaf) -- xor a
        cheatEnabled['WTW'] = true
    end

    memory.usememorydomain("WRAM")
end


-- Cheat definitions
cheatTable = {}
cheatTable["WTW"] = {"NumberPad1", toggleWTW}

cheatEnabled = {}


-- Display cheats and check for toggles
function handleCheat(cheat)
    local name = cheat
    local cheat = cheatTable[cheat]
    local key = cheat[1]
    local toggleFunc = cheat[2]

    if keysJustPressed[key] then
        toggleWTW()
    end

    local status
    if cheatEnabled[name] then
        status = "ON"
    else
        status = "OFF"
    end
    local keyname = string.gsub(key, 'NumberPad', 'NP')
    gui.text(x + COL_PIXELS, y, string.format("[%5s] %5s: %s", keyname, name, status))
    y = y+ROW_PIXELS
end


-- Main code
while true do
    handleInput()
    memory.usememorydomain("WRAM")

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

    table.foreach(cheatTable, handleCheat)

    emu.yield()
end
