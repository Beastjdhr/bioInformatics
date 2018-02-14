use warnings;
use strict;
use feature qw(say);

open CONTEXTS, "TauDContextos" or die $!;
my @cont= <CONTEXTS>;
close   CONTEXTS;

foreach my $c (@cont) {
  $c=~ m/(\d+\.\d+)/;
  say $1;
  my $idsLine= `grep $1 Todos.ids`;
  say $idsLine;
  my @pts= split/\t/, $idsLine;
  say $pts[0];
  open IDS, ">>idsTaud" or die $!;
  print IDS "$pts[0].faa\n";
  close IDS;
}
