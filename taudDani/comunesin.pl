use warnings;
use strict;
use feature qw(say);

open MG, "missingGenomes.txt" or die $!;
my @missingGenomes= <MG>;
close MG;

foreach my $mg (@missingGenomes) {
    $mg=~ m/Genome\s(\d+)\_/;
    my $missingGenome= $1;
    $mg=~ m/\_(\d+)/;
    my $gen= $1;
    my $idQuery= `grep $missingGenome TODOS`;
    my @qP= split/[\t]/, $idQuery;
    say $qP[1];
    say $idQuery;

    open CR, ">>contextosRestantes" or die $!;
    print CR $qP[1] . ".$gen" . "\n";
    close CR;

    open IR, ">>comunesin.ids" or die $!;
    print IR $idQuery;
    close IR;

}