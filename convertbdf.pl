# Converts the tom-thumb.bdf font file into a packed binary format encoded
# as a C++ (well, C really, but who's counting) variable declaration.
# This is only intended to parse this particular font file.
# The tom-thumb.bdf is a 4x6 pixel bitmap font that was created by
# Robey Pointer, by tweaking an earlier font of the same size made by
# Brian Swetland.
# For more information see:
#     http://robey.lag.net/2010/01/23/tiny-monospace-font.html

use strict;
use warnings;
use Data::Dumper;

open(IN, "tom-thumb.bdf");
open(OUT, ">", "tom-thumb.cpp");

# During processing we'll have one integer
# per row in the font, but since each row in
# the font actually takes only 4 bits we'll
# eventually pack it such that there's two
# rows per byte.
my @chars = map { [ 0, 0, 0, 0, 0, 0 ] } 0 .. 127;

# As noted in the comment above, this is not intended to be a robust
# parser of BDF files, it just extracts the minimum information necessary
# to handle this particular font file.
my $char_idx = 0;
my $top_margin = 0;
while (my $l = <IN>) {
    chomp $l;
    if ($l =~ m!^ENCODING (\d+)!) {
        $char_idx = int($1);
        $top_margin = 0;
        if ($char_idx < 32 || $char_idx > 127) {
            # Not interested in characters outside this range.
            $char_idx = 0;
        }
        else {
            warn "Now in character $char_idx\n";
        }
    }
    elsif ($l =~ m!^BBX \d+ (\d+) \d+ (\d+)!) {
        $top_margin = 6 - $1 - $2;
    }
    elsif ($l eq 'BITMAP') {
        if ($char_idx != 0) {
            my $row_idx = $top_margin;
            while (my $bl = <IN>) {
                chomp $bl;
                if ($bl ne 'ENDCHAR') {
                    my $bitmap = hex(substr($bl, 0, 1));
                    $chars[$char_idx][$row_idx] = $bitmap;
                    $row_idx++;
                }
                else {
                    last;
                }
            }
        }
    }
}

# Now that we've loaded the data we can write it out
# as one big C array literal with three bytes per character.

#select OUT;

print "int font[] = {\n";

# Start from 32 to skip over all of the control characters.
for (my $char_idx = 32; $char_idx < 128; $char_idx++) {
    my $char = $chars[$char_idx];
    print "\n/*\n    ";
    for my $i (0 .. 5) {
        my $bitmap = $char->[$i];
        for (my $b = 3; $b > -1; $b--) {
            my $set = $bitmap & (1 << $b);
            print $set ? "@" : ".";
        }
        print "\n    ";
    }
    print "*/\n";

    printf "   0x%1X%1X, 0x%1X%1X, 0x%1X%1X, // %3i %s\n", @$char, $char_idx, chr($char_idx);
    print "\n";
}

print "}\n";

