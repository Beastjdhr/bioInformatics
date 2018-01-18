use warnings;
use strict;

my @ids;

open HITS, "los1246/LivipeptineHits" or die "$!\n";
my @hits= <HITS>;
close HITS;

foreach my $hit (@hits) {
  $hit=~ m/\|(\d+\.\d+)/;
  my $qry= `grep $1 los1246/Actinos.ids`;
  $qry=~ m/(\d+)\t/;
  push @ids, $1;
}

 foreach my $id (@ids) {
   open JOBS, ">>jobs.txt" or die $!;
   print JOBS "$id ";
   close JOBS;
 }
