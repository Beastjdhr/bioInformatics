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
    my $n= $1;
    $n=~ s/[\(\)']//g;
      push @orgs, $n;
  }
  $oL=~ /,(.*)/;
  if ($1) {
    my $m= $1;
    $m=~ s/[\(\)']//g;
      push @orgs, $m;
  }
}

open FILE, ">>orgs.txt" or die $!;
my @F= <FILE>;
foreach my $i (@orgs) {
  print FILE "$i\n";
}
close FILE;

my $bash= `cut -f 1 orgs.txt | uniq`;
my @uniq= split/\n/, $bash;
print scalar(@uniq);
