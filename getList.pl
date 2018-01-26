use warnings;
use strict;
use feature qw(say);

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

open TL, ">>tList.txt" or die $!;
foreach my $u (@uniq) {
  $u=~ s/_/ /g;
  my @orgPts= split/ /, $u;
  my $l= pop @orgPts;
  $u= join(' ', @orgPts);
  if ($u=~ /NC /) {
    $u=~ s/NC /NC_/;
  }
  elsif ($u=~ /NZ /) {
    $u=~ s/NZ /NZ_/;
  }
    say $u;
  my $rastLine= `grep "$u" Actinos.ids`;
  my @pts= split/\t/, $rastLine;
  my $rast= $pts[0];
  my $genome= $pts[1];
  say $genome;
  my $genLine= `grep "$genome" LivipeptineHits`;
  $genLine=~ m/\.peg\.(\d+)/;
  my $geNum= $1;
  my $file= $rast . "_" . $geNum . ".input,";
  print TL $file;
}
close TL;
