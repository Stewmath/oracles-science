-- Gameboy stuff (realistically it may be oracles-specific)
local gb = {}
local common = dofile('lib\\common.lua')

wRamFunction = 0xc4b7  -- Location of a "jp" opcode to hook in "gb.call"
wTempLocation = 0xce00 -- "wTmpVramBuffer" (code is written here temporarily)

function gb.useWram()
    memory.usememorydomain('WRAM')
    --memory.usememorydomain('Main RAM') -- For GBHawk
end
function gb.useSysBus()
    memory.usememorydomain('System Bus')
end

function gb.push(val)
    memory.usememorydomain('System Bus')
    sp = emu.getregister('SP')
    s=sp-2
    memory.write_u16_le(sp, val)
    emu.setregister('SP', sp)
end

local function writeAndBackupMem(address, data)
    oldData = {}
    dataLen = table.getn(data)

    for i=1, dataLen do
        addr = address + i - 1
        oldData[i] = memory.readbyte(addr)
        memory.writebyte(addr, data[i])
    end

    return oldData
end

-- Hook a function call when a RAM function is called.
-- This may not work in menus. (the result will trigger after the menu.)
-- TODO: make this work in menus
function gb.call(funcToCall, registers)
    -- Gambatte doesn't support "emu.setregister", so we have to get tricky.
    -- We create a function in RAM, and overwrite a function pointer to jump
    -- there.

    if registers == nil then
        registers = {}
    end
    if registers["a"] == nil then
        registers["a"] = 0
    end
    if registers["b"] == nil then
        registers["b"] = 0
    end
    if registers["c"] == nil then
        registers["c"] = 0
    end
    if registers["d"] == nil then
        registers["d"] = 0
    end
    if registers["e"] == nil then
        registers["e"] = 0
    end
    if registers["h"] == nil then
        registers["h"] = 0
    end
    if registers["l"] == nil then
        registers["l"] = 0
    end

    local function hook()
        assert(emu.getregister('PC') == wRamFunction)
        event.unregisterbyname('ramCallHook')
        gb.useSysBus()

        oldJump = memory.read_u16_le(wRamFunction+1)
        print(wTempLocation)
        memory.write_u16_le(wRamFunction+1, wTempLocation)

        -- Save registers, set them to given values, call function, restore
        -- registers, return. (Technically should jump to the function call we
        -- hooked, but it's just a sprite drawing thing.)
        callCode = {0xf5,0xc5,0xd5,0xe5,
            0x3e, registers["a"],
            0x01, registers["c"], registers["b"],
            0x11, registers["e"], registers["d"],
            0x21, registers["l"], registers["h"],
            0xcd, bit.band(funcToCall,0xff), bit.rshift(funcToCall, 8),
            0xe1, 0xd1, 0xc1, 0xf1,
            0xc3, bit.band(oldJump, 0xff), bit.rshift(oldJump, 8)}

        backupData = writeAndBackupMem(wTempLocation, callCode)

        event.onmemoryexecute(function()
            event.unregisterbyname('ramCallHook2')
            gb.useSysBus()
            -- Restore what we just overwrote
            memory.write_u16_le(wRamFunction+1, oldJump)
            writeAndBackupMem(wTempLocation, backupData)
        end, oldJump, 'ramCallHook2', 'System Bus')
    end

    -- Replace a function in wram temporarily
    event.onmemoryexecute(hook, wRamFunction, 'ramCallHook', 'System Bus')
end


return gb
