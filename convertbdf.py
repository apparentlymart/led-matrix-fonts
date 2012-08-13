
# Note well: for the moment this is designed only to support
# the tom-thumb-tall font, since it's got lots of widths/heights/offsets
# hardcoded into it that only apply to this font. (or, I suppose,
# to any other 3x8 monospaced bitmap font.)

import freetype
import sys
import math
import numpy

face = freetype.Face('tom-thumb-tall.bdf')
face.set_char_size(8 * 64)

print "char tom_thumb_tall[][4] = {"

for char_idx in xrange(32, 127):
    face.load_glyph(char_idx - 1)
    top = face.glyph.bitmap_top
    left = face.glyph.bitmap_left
    row_idx = 0
    bits = numpy.zeros((4, 8), numpy.uint8)
    dst_bit = top
    for row in face.glyph.bitmap.buffer:
        row = row >> 4
        for src_bit in xrange(0, 4):
            on = row & (1 << src_bit)
            if on:
                bits[3 - src_bit + left][dst_bit] = 1
        dst_bit = dst_bit - 1
    print "    { // %i %s" % (char_idx, chr(char_idx))
    for out_row in bits:
        print "        0b%s," % ''.join((str(x) for x in out_row))
    print "    },"

print "    {0,0,0,0}"
print "};"
