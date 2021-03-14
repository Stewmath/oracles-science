-- Gameboy stuff (mostly should work for any gameboy game)
local gb = {}
local common = dofile('lib\\common.lua')

function gb.useWram()
    memory.usememorydomain('WRAM')
    --memory.usememorydomain('Main RAM') -- For GBHawk
end
function gb.useSysBus()
    memory.usememorydomain('System Bus')
end

local function writeAndBackupMem(address, data)
    common.pushMemDomain()

    if address < 0x4000 then
        -- We need to set the memory domain to 'ROM' if we're writing to ROM,
        -- otherwise writes don't work.
        memory.usememorydomain('ROM')
    elseif address < 0x8000 then
        assert(false) -- Can probably be implemented if I need it
    else
        memory.usememorydomain('System Bus')
    end

    oldData = {}
    dataLen = table.getn(data)

    for i=1, dataLen do
        addr = address + i - 1
        oldData[i] = memory.readbyte(addr)
        memory.writebyte(addr, data[i])
        --print(string.format('%.4x = %.2x', addr, data[i])) -- Debug output
    end

    common.popMemDomain()
    return oldData
end

-- UNTESTED
function gb.setRegister(name, val)
    assert(val >= 0 and val <= 255)

    pc = emu.getregister('pc')
    if name == 'pc' then
        assert(false) -- TODO
    else
        opcodeTable = {
            a=0x3e,
            b=0x06,
            c=0x0e,
            d=0x16,
            e=0x1e
        }
        opcode = opcodeTable[name]
        assert(not (opcode == nil))

        code = {opcode, val, 0x18, 0xfc} -- ld {reg},val; jr -4
        backup = writeAndBackupMem(pc, code)
        event.onmemoryexecute(function()
            writeAndBackupMem(pc, backup)
            event.unregisterbyname('registerSetHook') -- TODO: unregisterbyguid
        end, pc, 'registerSetHook', 'System Bus')
    end
end

-- Save current registers and call to a function.
-- Gambatte doesn't support "emu.setregister", so we have to get tricky.
-- We overwrite the current code being executing with our payload, and
-- restore it to normal when we're done with it.
function gb.call(funcToCall, registers)
    -- temp location to write code to (it will be restored later)
    -- This was chosen to work well for the oracles, but it should work for any
    -- game as long as it's not something that's being called the moment this is
    -- executed...
    local scratchLocation = 0x3fe0

    if registers == nil then
        registers = {}
    end

    local registerList = {'a','b','c','d','e','h','l'}
    for _,r in pairs(registerList) do
        if registers[r] == nil then
            registers[r] = 0
        end
    end

    local pc = emu.getregister('pc')

    -- Save registers, set them to given values, push return address, jump to
    -- scratchLocation
    local callCode = {0xf5,0xc5,0xd5,0xe5, -- push all
        0x01, bit.band(scratchLocation, 0xff), bit.rshift(scratchLocation, 8), -- ld bc,scratchLocation
        0xc5, -- push bc
        0x3e, registers["a"],
        0x01, registers["c"], registers["b"],
        0x11, registers["e"], registers["d"],
        0x21, registers["l"], registers["h"],
        0xc3, bit.band(funcToCall,0xff), bit.rshift(funcToCall, 8),
    }

    -- Write code to current location
    local backupData = writeAndBackupMem(pc, callCode)

    -- Hook upon jumping to our target function
    event.onmemoryexecute(function()
        --print('HOOKED')
        event.unregisterbyname('callHook')
        writeAndBackupMem(pc, backupData) -- Restore what we just overwrote

        -- Hook upon returning to scratchLocation
        event.onmemoryexecute(function()
            --print('HOOK2')
            event.unregisterbyname('callHook2')

            local returnCode = { 0xe1, 0xd1, 0xc1, 0xf1, -- pop all
                0xc3, bit.band(pc, 0xff), bit.rshift(pc, 8) -- Jump back to original code position
            }
            local backup2 = writeAndBackupMem(scratchLocation, returnCode)

            -- Hook upon returning to original code position
            event.onmemoryexecute(function()
                --print('HOOK3')
                event.unregisterbyname('callHook3')
                writeAndBackupMem(scratchLocation, backup2)

            end, pc, 'callHook3', 'System Bus')

        end, scratchLocation, 'callHook2', 'System Bus')

    end, funcToCall, 'callHook', 'System Bus')
end

return gb
