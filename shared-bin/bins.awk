#!/usr/bin/awk -f
#
# Bin count using thresholds given at argv. E.g.
# 
#   ./bin_count 0.1 0.01 0.001 0.0001 <./data | sort
#   < 0.000100: 3
#   < 0.001000: 12
#   < 0.010000: 56
#   < 0.100000: 100

BEGIN {
    for (i=1; i<ARGC; i++) counts[ARGV[i]] = 0
    delete ARGV    # <<<<< important
}
{
    $1 = $1 < 0 ? -$1 : $1
    for (bin in counts) {
        if ($1 < bin) { counts[bin]++; }
    }
}
END {
    for (bin in counts) {
        printf("< %f: %d\n", bin, counts[bin])
    }
}