#!/usr/bin/python3

# This is used for converting bytes into names to use with ACE, or for
# generating names that do certain things.
#
# Commands:
# - hex: Create a name with the given bytes. Example:
#     ./name-ace.py hex 6061626364
#
# - writemem: Create a name which overwrites a memory address with a specific
#   value. This can be used as soon as the ACE is set up, but both address bytes
#   must be enterable characters (between 60-ff), so the things it can overwrite
#   are a bit limited.
#
#   Prerequisites for using this:
#     - Ages only (for now?)
#     - Link's name should be ズモゲフフ
#     - The child's initial name should be えヌフコオ. This will write the
#       return byte ($ff) to c611, and also sets c60f (wChildStatus) = $02
#     - You must not have interacted with the child or blossom after naming him
#       (this will modify wChildStatus)
#     - Animal companion (c610) must not be corrupted (it might work anyway,
#       or it might not; non-corrupt values 00, 0b, 0c, 0d will all work)
#
#   Example, setting the active ring to the 1st-gen ring (ages):
#     ./name-ace.py writemem c6cb 2e
#

import sys, binascii


# Characters starting from $60 and going up to $ff.
# Also, $20 (space) and $2d (ー) are enterable characters.
# Spaces at the end of the name are converted to null ($00).
jpKanaTable = """
あいうえお
かきくけこ
さしすせそ
たちつてと
なにぬねの
はひふへほ
まみむめも
やゆよ
らりるれろ
わをん
ぁぃぅぇぉっゃゅょ
がぎぐげご
ざじずぜぞ
だぢづでど
ばびぶべぼ
ぱぴぷぺぽ

アイウエオ
カキクケコ
サシスセソ
タチツテト
ナニヌネノ
ハヒフヘホ
マミムメモ
ヤユヨ
ラリルレロ
ワヲン
ァィゥェォッャュョ
ガギグゲゴ
ザジズゼゾ
ダヂヅデド
バビブベボ
パピプペポ
""".replace('\n', '')


def myhex(val, length=1):
    if val < 0:
        return "-" + myhex(-val, length)
    out = hex(val)[2:]
    while len(out) < length:
        out = '0' + out
    if len(out) != length:
        raise Exception("Number \"0x%x\" was too long." % val)
    return out

def byteToCharacter(b):
    if b == 0x20: # NOTE: MAY BE REPLACED BY NULL, must account for this elsewhere!
        return '　'
    elif b == 0x2d:
        return 'ー'
    elif b >= 0x60:
        return jpKanaTable[b - 0x60]
    else:
        return -1

# Input: hex string
# Output: name
def hexStringToName(h):
    name = ''
    for b in binascii.unhexlify(h):
        c = byteToCharacter(b)
        if c == -1:
            raise Exception("Couldn't convert byte 0x%.2x to character." % b)
        name += c
    if name[-1] == '　':
        raise Exception("Name can't end with space.")
    return name


if len(sys.argv) < 2:
    print('No arguments.')
    sys.exit(1)

if sys.argv[1] == 'hex':
    print(hexStringToName(sys.argv[2]))

elif sys.argv[1] == 'writemem':
    # Ages register values upon executing child name:
    # - a: 07 (set from link's name ズモゲフフ)
    # - bc: 0003
    # - de: ccdb
    # - hl: fad5
    #
    # We also assume that:
    # - c608 is 01 ("ld bc" opcode, this is always true in ages unless corrupted)
    # - c60f is 02 ("ld (bc),a" opcode in wChildStatus)
    # - c611 is ff (effectively "returns"; initial child name should set this)


    assert(len(sys.argv[2]) == 4)
    addr = int(sys.argv[2], 16)

    code = myhex(addr & 0xff, 2)
    code += myhex(addr >> 8, 2)

    val = int(sys.argv[3], 16)
    b = 0xff & (val - 7)
    if byteToCharacter(b) != -1:
        code += 'c6' # add a,XX
    else:
        code += 'd6' # sub a,XX
        b = 0xff & (7 - val)
        assert(byteToCharacter(b) != -1)

    code += myhex(b, 2)

    print(hexStringToName(code))

else:
    print('Unknown argument "%s".' % sys.argv[1])
    sys.exit(1)
