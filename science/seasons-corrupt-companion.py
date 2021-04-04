#!/usr/bin/python3

# Looking for ways to achieve ACE with a corrupted animal companion in Seasons
# (because this can be done through the link cable).
#
# Opening the map with an invalid animal companion can corrupt certain ranges of
# memory, this will list the rough memory regions that get corrupted for
# a particular companion. Addresses below 0xc000 are ignored since they rarely
# do anything useful when written to, except for range 0x2000-0x2fff which
# changes the ROM bank.
#
# Parameters:
# - 1: JP Seasons ROM location
# - 2: Companion index to test (value of address c610)

import sys

f = open(sys.argv[1], 'rb') # Pass in a Seasons JP rom
rom = f.read()
f.close()

table_addr = 2*0x4000 + 0x2a44



def getAddr(companion):
    index = companion - 12
    addr = table_addr + index
    addr = addr + rom[addr]
    return addr

addrs = {}

def getAddrRanges():
    for companion in range(12, 256):
        addr = getAddr(companion)
        if not addr in addrs:
            addrs[addr] = []
        addrs[addr].append(companion)

    #for k in sorted(addrs):
    #    print(hex(k) + ": " + str([hex(x) for x in addrs[k]]))


def printCompanionInfo(companion):
    addr = getAddr(companion)
    subIndex = 0

    while True:
        startAddr = addr
        if addr >= 0xc000:
            print('EXCEEDED BANK LIMIT.')
            break
        if subIndex != 0 and addr in addrs:
            print('Rest is the same as ' + hex(addr) + ' ' + str([hex(x) for x in addrs[addr]]) + '...')
            break

        size = rom[addr]
        if size == 0:
            break
        addr+=1

        height = size & 0x0f
        width = size >> 4

        dest = rom[addr] | (rom[addr+1]<<8)
        addr+=2
        src = rom[addr] | (rom[addr+1]<<8)
        addr+=2

        minDest = (dest & ~0x0400)
        maxDest = (dest | 0x0400) + height * 0x20
        if maxDest >= 0xc000 or (maxDest >= 0x2000 and minDest < 0x3000):

            print("(%d)" % subIndex)
            print(hex(startAddr))
            print("===============================")
            print("Size: " + str(width) + "," + str(height))
            #print("Src:  " + hex(src))
            #print("Dest: " + hex(dest))

            def printRange(val):
                minimum = val & ~0x0400
                maximum = val |  0x0400
                print(hex(minimum) + "<->" + hex(maximum + height * 0x20))

            print('Src range:  ', end='')
            printRange(src)
            print('Dest range: ', end='')
            printRange(dest)

            print("===============================\n")

        subIndex += 1


# Print values that will jump to address 0xf81a, useful for ACE.
def getValuesForACE():
    finalValues = [0x7e, 0x6d, 0x6a, 0x5d, 0x4d, 0x9d, 0x9e]

    ret = []

    for companion in range(0x10, 0x100):
        addr = getAddr(companion)

        while True:
            if addr in addrs and any(x in addrs[addr] for x in finalValues):
                ret.append(companion)
                break
            size = rom[addr]
            if size == 0:
                break
            addr+=1

            height = size & 0x0f
            width = size >> 4

            dest = rom[addr] | (rom[addr+1]<<8)
            addr+=2
            src = rom[addr] | (rom[addr+1]<<8)
            addr+=2

            minDest = (dest & ~0x0400)
            maxDest = (dest | 0x0400) + height * 0x20

            # Ignore any which write to ROM bank
            if maxDest >= 0x2000 and minDest < 0x3000:
                break

    print([hex(x) for x in ret])



getAddrRanges()
printCompanionInfo(int(sys.argv[2]))
#getValuesForACE()
