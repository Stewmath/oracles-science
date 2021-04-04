#!/usr/bin/python3
# Helper functions
def read16(buf, index):
    return buf[index] | (buf[index+1]<<8)


def read16BE(buf, index):
    return (buf[index]<<8) | (buf[index+1])


# Read: bank number, then pointer
def read3BytePointer(buf, index):
    return bankedAddress(buf[index], read16(buf, index+1))


# Read: pointer, then bank number
def readReversed3BytePointer(buf, index):
    return bankedAddress(buf[index+2], read16(buf, index))


def toGbPointer(val):
    return (val&0x3fff)+0x4000


def bankedAddress(bank, pos):
    return bank*0x4000 + (pos&0x3fff)


def myhex(val, length=1):
    if val < 0:
        return "-" + myhex(-val, length)
    out = hex(val)[2:]
    while len(out) < length:
        out = '0' + out
    return out

def romIsSeasons(rom):
    return rom[0x134:0x13d].decode() == "ZELDA DIN"
def romIsAges(rom):
    return rom[0x134:0x13f].decode() == "ZELDA NAYRU"
def getRomRegion(rom):
    c = chr(rom[0x142])
    if c == 'P': return "EU"
    if c == 'E': return "US"
    if c == 'J': return "JP"
    assert False, "Invalid region for ROM"
def getGameType(rom):
    if romIsSeasons(rom):
        return "SEASONS" + getRomRegion(rom)
    elif romIsAges(rom):
        return "AGES" + getRomRegion(rom)
    assert False, "Invalid game type (rom isn't seasons or ages?)"


def wlahex(val, length=1):
    if val < 0:
        return "-" + wlahex(-val, length)
    return '$'+myhex(val, length)

def wlahexSigned(val, length):
    highBit = 1<<(length*4-1)
    if val&highBit != 0:
        return '-$'+myhex((highBit*2)-val, length)
    else:
        return '$'+myhex(val, length)

def wlabin(val, length=8):
    out = bin(val)[2:]
    while len(out) < length:
        out = '0' + out
    return '%' + out

def isHex(c):
    return (c >= '0' and c <= '9') or (c >= 'a' and c <= 'f') or (c >= 'A' and c <= 'F')

# Parses wla-like formatted numbers.
# ex. $10, 16
def parseVal(s):
    s = str.strip(s)
    if s[0] == '$':
        return int(s[1:], 16)
    elif s[0:2] == '0x':
        return int(s[2:], 16)
    else:
        return int(s)


def rotateRight(val):
    return (val>>1) | ((val&1)<<7)


def getGame(rom):
    return str(rom[0x134:0x143])
