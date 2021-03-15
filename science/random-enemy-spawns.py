#!/usr/bin/python3

# Script which simulates the random placement of enemies in rooms.
#
# Made this to investigate a bug in the US/EU versions of Ages/Seasons where
# enemies don't clear their ID/SubID values properly if they fail to spawn in
# due to not finding valid positions. This applies only to "random-position
# enemy" objects.
#
# Since the SubID doesn't get cleared, there are rare cases where other enemy
# objects never set the subid (or else increment it assuming it starts at 0),
# meaning those enemies could spawn in with an invalid SubID value if they use
# that corrupted object slot.
#
# Sadly, as I wrote this program I discovered that it is extremely rare for the
# game to fail to find a valid tile to place an enemy on, meaning this bug is
# basically impossible to exploit. It's completely impossible in small rooms,
# and is only possible in large rooms where most of the room consists of tiles
# that they can't spawn on. The game must attempt to place the enemy on 63
# distinct solid tiles in the room (screen edges not counted) before it gives
# up. This condition is extremely hard to meet.
#
# That's not to say there are no cases where this can happen; just that there
# are no cases where the bug is exploitable. In order for it to be exploitable,
# there must be an enemy with a nonzero subid that can fail to load, IN ADDITION
# to an enemy that will become corrupted if it spawns in that object slot. Both
# of these things must be within the same floor of a dungeon (object memory gets
# cleared whenever entering a warp).
#
# Enemies which respond to the corruption include moldorms, pincers,
# wallmasters/floormasters, iron masks, baris, and many bosses/minibosses.
# (Mostly, these are objects consisting of multiple components that are manually
# spawned in by their code.) Of these, I found moldorms were the most promising
# exploit target for ACE. But I was unable to trigger the object slot corruption
# that would be necessary to exploit moldorms.
#
# Note: The JP version doesn't have this glitch, but instead it has a glitch
# where it places enemies that fail to spawn at position 0,0. This program could
# help find the rare cases where that can be done, even if it's useless.
#
# This program was also used to study Octogon's despawning behaviour. He is
# treated like a "normal enemy" and the game tries to place him on land; since
# there is so little land, this can result in him failing to spawn at all. (Not
# a problem on the JP version because it would just put him at position 0,0,
# before correcting his position to where he should be)

class RNGState:
    def __init__(self):
        self.rng1 = 0x37
        self.rng2 = 0x0d

    def advance(self):
        word = self.rng1 | (self.rng2 << 8)
        word = word * 3
        self.rng2 = (word >> 8) & 0xff
        self.rng1 = (self.rng2 + self.rng1) & 0xff
        return self.rng1

    def get(self):
        return self.rng1

    def copy(self):
        ret = RNGState()
        ret.rng1 = self.rng1
        ret.rng2 = self.rng2
        return ret

    def __eq__(self, other):
        return self.rng1 == other.rng1 and self.rng2 == other.rng2

    def __hash__(self):
        return self.rng1 + (self.rng2<<8)


# Generate the full RNG sequence. (It loops.)
rngSequence = []
rngSet = set()

rng = RNGState()
rngSet.add(rng)
while True:
    rngSequence.append(rng.copy())
    rng.advance()

    if rng in rngSet:
        # Looped
        assert(rng.rng1 == 0x37)
        assert(rng.rng2 == 0x0d)
        break
    rngSet.add(rng)


# Search for a particular sequence. The parameter "sequence" is actually a list
# of functions to match against the RNG state.
def findSequence(sequence):
    rng = RNGState()
    pos = 0
    while True:
        oldRng1 = rng.rng1
        oldRng2 = rng.rng2
        ok = True
        rngCopy = rng.copy()
        for j in range(len(sequence)):
            if not sequence[j](rngCopy):
                ok = False
                break
        if ok:
            # Return either the position relative to RNG start, or the actual
            # RNG values
            #yield pos
            yield (hex(oldRng1), hex(oldRng2))

        rng.advance()
        pos+=1
        if pos >= len(rngSequence):
            break


# Seasons D5 gibdo room
gibdoRoom = (4, 1, '''
111111111111111
111111111111111
111110000011111
111100000001111
111001000100111
000000010000000
111001000100111
111100000001111
111110000011111
111111111111111
111111111111111
'''.strip().replace('\n', ''),
[])

# Minecart switch room in Ages d4 (this is SO CLOSE to being useful for
# corrupting Armos Knight, if only one extra column were a wall...)
d4Room = (4, 3, '''
111111111111111
111111110000001
111111110000001
111111110000001
111111110000001
111111110001111
111111110001001
111111110001111
111111110001001
111111110001101
111111111111111
'''.strip().replace('\n', ''),
[])

# Flying tile room in Seasons d7
d7Room = (1, 1, '''
111111111111111
000000111011011
000001111011111
000001111011001
111111111111111
111011011011011
111111111111011
111011001011011
111111011111111
111011011001001
100111111111111
'''.strip().replace('\n', ''),
[])

octogonRoom = (1, # Number of random enemies
0, # Direction entered from
'''
111111111111111
111111111111111
111111111111111
111111111111111
111110101011111
111111000111111
111110101011111
111111111111111
111111111111111
111111111111111
111111111111111
'''.strip().replace('\n', ''),
[0x55, 0x59] # Locations of fixed-position enemy objects (can't spawn there)
)

# spike room in seasons d7, on the way to the cape.
# Assuming Link spawns in on the bottom rightmost hole, anything within 3 tiles
# is an invalid spot (that's reflected on the map below). Haven't 100% verified
# if that's totally accurate.
d7SpikeRoom = (2, # Number of random enemies
-1, # Direction entered from
'''
111111111111111
111100000111111
100000000111111
111111110111111
111111110111111
111111110111111
111111110111111
111111110111111
111111110111111
111111110111111
111111111111111
'''.strip().replace('\n', ''),
[]
)

# Desert pit in seasons with like-likes
desertPitRoom = (4, # Number of random enemies
-1, # Direction entered from
'''
111111111111111
111111111111111
111111111111111
111101111101111
111001111100111
111011111100111
111001111101111
111101111101111
111111111111111
111111111111111
111111111111111
'''.strip().replace('\n', ''),
[]
)

roomIsLarge = True

if roomIsLarge:
    width = 15
    height = 11
else:
    width = 10
    height = 8


def convertRoomLayout(roomMap):
    ret = []
    i = 0
    for y in range(height):
        row = roomMap[i : i + width]
        ret.append(row)
        i += width
    return ret


class RandomBuffer:
    def __init__(self, state):
        buf = [i for i in range(256)]

        i = 255
        j = state.advance()
        buf[i], buf[j] = buf[j], buf[i]
        for i in range(255, 0, -1):
            j = (i * state.advance()) >> 8
            buf[i], buf[j] = buf[j], buf[i]
        self.buf = buf
        self.index = 0

    def nextValue(self):
        self.index += 1
        return self.buf[self.index]


# Simulate spawning of enemies in a room, return their positions (-1 if failed
# to find a valid position)
def spawnEnemiesInRoom(state, room, verbose=False):
    count = room[0]
    direction = room[1]
    layout = convertRoomLayout(room[2])
    fixedEnemies = room[3]
    usedPositions = set()
    randomBuffer = RandomBuffer(state)
    if verbose:
        print([hex(x) for x in randomBuffer.buf])

    def getCandidatePosition():
        if roomIsLarge:
            while True:
                p = randomBuffer.nextValue()
                #print('TRY ' + hex(p))
                if p >= 0xb0:
                    continue
                if (p & 0xf0) == 0: # First row not allowed
                    continue
                if (p >> 4) == 10: # Last row not allowed
                    continue
                if (p & 0x0f) == 0: # First column not allowed
                    continue
                if (p & 0x0f) >= 14: # Last column not allowed
                    continue
                if p in usedPositions:
                    continue
                if p in fixedEnemies:
                    continue
                break
        else:
            raise "NOT SUPPORTED"
        if verbose:
            print('CANDIDATE: ' + hex(p))
        return p

    def checkValidPosition(pos):
        if direction == -1:
            return True
        if roomIsLarge:
            table = [
                    [1, height-3, 1, width-1],
                    [1, height-1, 3, width-1],
                    [3, height-1, 1, width-1],
                    [1, height-1, 1, width-4],
                    ]

        else:
            table = [
                    [0, height-3, 0, width]  ,
                    [0, height,   3, width]  ,
                    [3, height,   0, width]  ,
                    [0, height,   0, width-3],
                    ]

        table = table[direction]
        y = pos >> 4
        x = pos & 0xf
        if y < table[0]:
            return False
        if y >= table[1]:
            return False
        if x < table[2]:
            return False
        if x >= table[3]:
            return False
        return True

    def checkValidTile(pos):
        y = pos >> 4
        x = pos & 0xf
        return layout[y][x] == '0'

    retList = []
    for i in range(count):
        succeeded = False
        for attempt in range(0x3f):
            p = getCandidatePosition()
            if not checkValidPosition(p):
                continue
            if not checkValidTile(p):
                continue
            succeeded = True
            break

        #if verbose:
        #    print(str(i) + ': ', end='')
        if succeeded:
            usedPositions.add(p)
            retList.append(p)
            if verbose:
                print("POS: " + hex(p) + " (%d, %d)" % ((p & 0xf, p >> 4)))
        else:
            retList.append(-1)
    return retList


# Predict locations of enemies in a room with a given RNG seed
#rng = RNGState()
#rng.rng1 = 0x9b
#rng.rng2 = 0xfd
#print([hex(x) for x in spawnEnemiesInRoom(rng, d4Room)])

# Look for a seed where a like-like fails to spawn in the samasa desert pit
print(list(findSequence([lambda s: -1 in spawnEnemiesInRoom(s, desertPitRoom)])))

# Look for a seed where Octogon doesn't spawn when entering room from bottom
#print(list(findSequence([lambda s: -1 in spawnEnemiesInRoom(s, octogonRoom)])))
