# feb 26, 2018
# the purpose of this script is to create the files writeInputs.pl needs in order to do its job
# With this script, a file where each line is genomeID.centralGene will be created, in addition to 
# A file where each line is JobID \t GenomeID \t Organism 
use warnings;
use strict;
use feature qw(say);



my $out= `ls inputs/*`;
my @inps=  split/[\s\t]/, $out;


foreach my $inp (@inps) {
    my @pts= split/[\/_\.]/, $inp;
    my  $JobID= $pts[1];
    my $centralGene= $pts[2];

    my $validation= `grep $JobID pseudo.ids`;
    # checking if jobID actually needs to be rewritten
    unless (length($validation) < 2) {
        # to get the genome ID and the organism, each input file will be read;
        my $centralLine= `grep \t1\t $inp`;
        # this grep returns more than one line, so $centralLine is split and only the first line is grabbed
        my @cls= split/\n/, $centralLine;
        # this line is split to get the organism and genome id
        my @cps= split/\t/, $cls[0];
        my $org= $cps[4];
        my $fig= $cps[6];
        $fig=~ m/fig\|(.+)\.peg/;
        my $genomeID= $1;
        # Now all the needed data has been retrieved. Time to write to the goal files.
        my $orderLine= "$genomeID.$centralGene\n";
        my $actinosLine= "$JobID\t$genomeID\t$org\n";
        open GENOMES, ">>genomes" or die $!;
        print GENOMES $orderLine;
        close GENOMES;
        open IDS, ">>ids" or die $!;
        print IDS $actinosLine;
        close IDS;
    }

}