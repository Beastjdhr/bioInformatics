use warnings;
use strict;
use feature qw(say);

open LS, "faas.txt" or die $!;
my @ls= <LS>;
close LS;

foreach my $l (@ls) {
    open TXT, "input/$l.txt" or die $!;
    my @txt= <TXT>;
    close TXT;
    my @corregido;
    for (my $i=0; $i< scalar(@txt); $i++) {
        my $number=0;
        if ($i> 1) {
            my @pts= split/\t/, $txt[$i-1];
            my @rpP= split/\./, $pts[1];
            $number= $rpP[-1]; 
        }
        if ($txt[$i]=~ m/rna\.\d+/) {
            my $nn= $number+1;
            $txt[$i]=~ s/rna\.\d+/peg\.$nn/;
        }
        push @corregido, $txt[$i];
    }
    foreach my $c (@corregido) {
        open C, ">>inputCorregidos/$l.txt";
        print C $c;
        close C;
    }
}