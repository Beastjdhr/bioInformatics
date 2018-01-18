use warnings;
use strict;

my $qry= `grep peg.7559 los1246/242391.txt`;

my @e= split/\t/, $qry;

open SEQ, ">>query.faa" or die $!;
print SEQ $e[12];
close SEQ;
