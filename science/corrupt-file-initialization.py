#!/usr/bin/python3
# When linking a file over the link cable, corrupt the "wFileIsLinkedGame" or
# "wFileIsHeroGame" variable to totally screw up the file initialization code.
# When the values are invalid, it will overwrite various values in the c6xx
# range; these values represent critical file information (ie. link's position,
# items, some event flags, etc).
#
# Pass a ROM file as a parameter.
#
# Each index represents the value: [wFileIsLinkedGame] + [wFileIsHeroGame] * 2.
# This determines where it will read from memory to overwrite file variables.

from common import *
import sys

f = open(sys.argv[1], 'rb')
rom = f.read()
f.close()

fileBank = 0x07

if romIsSeasons(rom) and getRomRegion(rom) == 'JP':
    tableAddr = bankedAddress(fileBank, 0x417a)
else:
    print('Unsupported region')
    sys.exit(1)


def printAllSources():
    for i in range(256):
        source = read16(rom, tableAddr + i * 2)
        print(myhex(i, 2) + ': ' + myhex(source, 4))
        print('==================')

        while True:
            if source >= 0x7fff:
                print('Points to RAM, can\'t analyze')
                break
            if source >= 0x4000:
                trueAddr = bankedAddress(fileBank, source)
            else:
                trueAddr = source
            b = rom[trueAddr]
            if b == 0:
                break
            v = rom[trueAddr+1]
            print('c6' + myhex(b, 2) + ' <- ' + myhex(v, 2))
            source += 2

        print('==================\n')

printAllSources()
