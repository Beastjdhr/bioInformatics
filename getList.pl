use warnings;
use strict;
use feature qw(say);


my $bash= `cut -f 1 fO.txt | uniq`;
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
