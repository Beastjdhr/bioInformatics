use warnings;
use strict;

my $tree= 'livi.tre';
my @orgs;

open TRE, "$tree" or die $!;
my @lines= <TRE>;
close TRE;

my $orgsLine= $lines[2];
my @orgLines= split/\[/, $orgsLine;

foreach my $oL (@orgLines) {
  $oL=~ /'(.*)'/;
  if ($1) {
    print "$1\n";
  }
  $oL=~ /,(.*)/;
  if ($1) {
    print "$1\n";
  }
}
