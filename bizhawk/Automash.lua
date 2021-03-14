-- Mash through all the text

local bDown = false

while true do
    local menuOpen = not (mainmemory.read_u8(0xbcb) == 0)

    if not menuOpen then
        if mainmemory.read_u8(0x0ba0) == 1 then
            local buttons = joypad.get()
            if buttons["B"] then
                buttons["A"] = "True"
                buttons["B"] = "False"
                joypad.set(buttons)
            else
                buttons["A"] = "False"
                buttons["B"] = "True"
                joypad.set(buttons)
            end
        else
            bDown = false
        end
    end
	emu.frameadvance()
end
