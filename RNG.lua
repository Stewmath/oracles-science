-- Searches through the RNG sequence to find when the next big blue rupee will
-- come up.
--
-- Also displays the next 3 RNG values. Press "r" to advance to the next value.

local x = 0
local y = 5*16

local digX = 200
local digY = y

local howmany = 3
local howmanyitems = 3




local RNGlo = 0
local RNGhi = 0

local justpressed = false

memory.usememorydomain("System Bus")

function getRNG()
	RNGlo = memory.read_u8(0xff94)
	RNGhi = memory.read_u8(0xff95)
end

function getnextRNG()
	RNGhi = bit.band(bit.rshift(((bit.lshift(RNGhi, 8) + RNGlo)*3), 8), 0xff)
	RNGlo = bit.band(RNGlo + RNGhi, 0xff)
end

function advanceRNG(number)
	local n = 0
	while n < number do
		getnextRNG()
		n = n + 1
	end
end
function writeRNG()
	memory.write_u8(0xff94, RNGlo)
	memory.write_u8(0xff95, RNGhi)
end

function rngsearch(matchFuncs, len, maxdepth)
	local RNGloold = -1
	local RNGhiold = -1
	local depthold = -1
	
	local depth = 0
	local listpos = 1
	
	getnextRNG()
		
	while depth < maxdepth do
		if matchFuncs[listpos](RNGlo) then
			if listpos == 1 then
				RNGloold = RNGlo
				RNGhiold = RNGhi
				depthold = depth
			end
			listpos = listpos + 1
			if listpos == len+1 then
				return depthold
			end
		else
			if listpos ~= 1 then
				RNGlo = RNGloold
				RNGhi = RNGhiold
				depth = depthold
				listpos = 1
			end
		end
			
		depth = depth + 1
		getnextRNG()
	end
	return -1
end

function willItemSpawn(val2)
	local val = bit.band(val2, 0x3f)
	return val == 0x03 or val == 0x0c or val == 0x0e or val == 0x10
		or val == 0x13 or val == 0x1a or val == 0x1d or val == 0x23
		or val == 0x27 or val == 0x28 or val == 0x2f or val == 0x34
		or val == 0x35 or val == 0x37 or val == 0x39 or val == 0x3c
end
function isRareItem(val2)
	local val = bit.band(val2, 0x1f)
	return val == 0 or val == 1 or val == 2
end
function isBigBlueRupee(val)
	return val >= 0xe0
end

function isFairy(val)
	local val2 = bit.band(val, 0x1f)
	return val2 == 0x1f or val2 == 0x1e
end
function isCrit(val)
	return val == 0
end

RNGlo = memory.read_u8(0xff94)
RNGhi = memory.read_u8(0xff95)

-- Print result of a search to console
--print(rngsearch({willItemSpawn, isFairy}, 2, 256*50))
--print(rngsearch({isCrit}, 1, 256*50))
print(string.format('Next rupee in %d advances', rngsearch({willItemSpawn, isRareItem, isBigBlueRupee}, 3, 256*50)))
	
while true do
    memory.usememorydomain("System Bus")

	getRNG()
	
    local s = ""
    local n = 0
    local val = 0

    -- State when the next rupee is, on the screen. (This is way to slow to leave on.)
	--gui.text(digX, digY, string.format("Next rupee: %d", rngsearch({willItemSpawn, isRareItem, isBigBlueRupee}, 3, 256*50)))

    
    getRNG()
	gui.text(x, y, "RNG: ")
    
	local n = 0
	while n < howmany do
		getnextRNG()
		gui.text(x+4*10 + n*30, y, string.format("%.2X", RNGlo))
		n = n+1
	end
	
	keys = input.get()
	
	if keys["R"] then
		if not justpressed then
			getRNG()
			advanceRNG(1)
			writeRNG()
		end
		justpressed = true
	else
		justpressed = false
	end
	
    emu.yield()
end

