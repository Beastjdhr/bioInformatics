use warnings;
use strict;
use feature qw(say);

my $out= `ls *input`;
my @inps= split/_\d+\.input/, $out;

foreach my $inp (@inps) {
    open IDS, ">>pseudomonas.ids" or die $!;
    print IDS $inp;
    close IDS;
}