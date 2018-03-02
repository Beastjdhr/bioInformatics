use warnings;
use strict;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);
use feature qw(say);

GetOptions(
        'left=i'=> \my $genL,
        'right=i' => \my $genR,
        'contexts=s' => \my $contexts,
) or die "Invalid options passed to $0\n";

#directory where the .input files will be written to:
my $outputDir= "salida";
#directory where the .txt are located:
my $inputDir= "input";
#file path where the file matching genomes to rast numbers is located:
my $actinosFile="ids";
#file from which genomes are retrieved:
my $genomesFile= "genomes";
#blast file:
#my $blast= 'TAUD.blast';

#first, the genomes to retrieve must be stored in an array in order to
#be matched to their rast numbers
my @targetGenes= getGenes($genomesFile);

#now that the genomes have been obtained, they are matched to their rast numbers
my %genAndRast= matchGenomes($actinosFile, @targetGenes);

#get the context of each gene:
my @fileList=writeContexts($inputDir,$outputDir, $genL, $genR, \%genAndRast);

my $ls= join(',',@fileList);

open F, ">>tList.txt" or die $!;
print F $ls;
close F;
#_________________________________SUBS__________________________________
#this subroutine gets the genome and genes from which the contexts will be obtained
# i= file where the genomes are stored
# o= array where:
# each element= genome_gen
sub getGenes {
  my $file= shift;
  my @genOutput;

  open FILE, $file or die "Failure to open target file: $!\n";
  my @File= <FILE>;
  close FILE;

  foreach my $line (@File) {
    #initializing gene variable:
    my $gen= '';
    #this regex looks for the genome:
    $line=~ m/(\d+\.\d+)/;
    # $1 means the first match for the query
    $gen= $1 . "_";
    $line=~ m/\d+\.\d+\.(\d+)/;
    $gen= $gen . $1;
    #this element (genome_gen is stored in an array which is the output of this subroutine)
    # say $gen;
    push @genOutput, $gen;
  }
  return @genOutput;
}
#___________________________________________________________________

#this sub matches the genomes to their rast numbers
# i= genomes array and Actinos files
# o= hash where:
# genome_gen-> rast number
sub matchGenomes {
  my $actinos= shift;
  my @genomes= @_;
  my %matches;

  foreach my $genome (@genomes) {
    #get the genome:
    $genome=~ m/(\d+\.\d+)/;
    # say $1;
    #look for the genome in the file
    my $query= `grep "$1" "$actinos"`;
	chomp $query;
    if (length($query) < 2) {
      die "Search returned empty match on genome $genome; pattern: $1\n";
  }
	my @st=split(/\t/,$query);
    #print "query $query\n";  
    #get rast number:
    $query=~ m/(\d+)\t/;
    #assign a value to each rast Number:
    $matches{$genome}= $1;
#	print "genome $genome es $1\n";
    #getting org name:
#    $query=~ m/(\d+).(\d+)\t\d+\t(\w+)/;
    $matches{$genome} .= ".." . $st[2];
#	print "genome $genome es $1\n";
#	print "$st[2]\n";
#    say $genome;
#   say $matches{$genome};
  }
  return %matches;
}

#this sub gets the context of the central gene and it calls more subs to get the contexts of the genes to the left and right

sub writeContexts {
  my $inPath= shift;
  my $outPath= shift;
  my $left= shift;
  my $right= shift; 
  my $genes= shift;

  my %genes= %$genes;

  my @list;


#my $counter= 2473 *21;
  foreach my $gen (keys %genes) {
    my @lines;
    #print "$counter genes left\n";
#    $counter-= 21;
    #getting rast number:
    $genes{$gen}=~ m/(\d+)\.\./;
    my $rast= $1;
    my $txtFilePath= "$inPath/" . $rast . ".txt";


    #getting gene number:
    $gen=~ m/_(\d+)/;
    my $geN= $1;

    my $contig= 0;

    #getting $orgName:
    $genes{$gen}=~ m/\.\.(\w+)/;
    my $orgName= $1;

 #  print "$orgName\n";
#	print "pause";
#        my $pause=<STDIN>;

    #getting central gen info and central contig;
#    say "Getting central gene";
    $contig=getContext($txtFilePath, $geN, $contig, $orgName, \@lines);

    #calculating genes from left and right:
    my $leftSide= $geN - $left < 1 ? 1 : $geN - $left;
    my $leftLimit= $geN - 1;
    my @leftGenes= ($leftSide .. $leftLimit);

    my $rightSide= $geN + 1;
    my $rightLimit= $geN + $right;
    my @rightGenes= ($rightSide .. $rightLimit);

    my @edgeGenes= (@leftGenes, @rightGenes);
 #   say "Getting edge genes";
    foreach my $edgeGen (@edgeGenes) {
      getContext($txtFilePath, $edgeGen, $contig, $orgName, \@lines);
    }

    #writing contexts in .input file:
    push @list, "$rast\_$geN.input";
  #  say "About to enter for loop";

    foreach my $datum (@lines) {
     say "DATUM: $datum";
      open OUT, ">>$outPath/$rast\_$geN.input" or die "failure to create .input file: $!\n";
      print OUT $datum;
      close OUT;
    }

  }
  return @list;
}


#_________________________________________________
#this sub gets data for each gene
# i= .txt filepath, $gen, contig, array to write data to
# o= this sub pushes data to an array from the writeContexts sub
#if the contig passed to it equals 0 (meaning it is running with the central gene) it returns it
sub getContext {
  my $path= shift;
  my $gen= shift;
  my $contig= shift;
  my $org= shift;
  my $out= shift;


  #getting rastN:
  $path=~ m/\/(\d+)/;
  my $rast= $1;

  if (length($rast) <1 || length($gen) < 1) {
    die "Either rast no. or gen are empty at gen $gen\n;";
  }
  my $query= `grep "peg.$gen\t" $path`;
  #say $query;
  if (length($query)<1) {
    die "Lookup returned empty match for gen $gen in $path\n";
    }
  my @elements= split/\t/, $query;

  my $cont= $elements[0];
  my $startCoord=  $elements[4];
  my $endCoord= $elements[5];
  my $sign= $elements[6];
  my $number= looks_like_number($contig) ? 1 : 0;
  my $fig= $elements[1];
  my @Fig= split/[\._\|]/, $fig;
  my $Genome= $Fig[1] . "." . $Fig[2];
  my $molecFunction= $elements[7];
  my $id= $elements[1];
  my $percent=0;
  my $genomeGen= $Genome . "." . $gen;
  my $none= 'none';

#extracting genes from blast query:
#my $blast_genes= `cut -f 1 $blast | uniq`;
#my @blast_genes= split/\n/, $blast_genes;
#my $blastSearch= ' ';
#checking if gene is in blast file:
#$blastSearch= `grep "$Genome.peg.$gen" $blast`;
#if (length($blastSearch) > 2) {
  #say "match: $org";
 #   my @cols= split/\t/, $blastSearch;
 #     if ($cols[0] eq $blast_genes[0] && ! looks_like_number($contig)) {
 #       $number= 5;
 #     }
  #    elsif ($cols[0] eq $blast_genes[1] && ! looks_like_number($contig)) {
  #      $number= 2;
#      }
#      elsif ($cols[0] eq $blast_genes[2] && ! looks_like_number($contig)) {
#        $number= 3;
#      }
##      elsif ($cols[0] eq $blast_genes[3] && ! looks_like_number($contig)) {
##        $number= 4;
#      }
#      elsif ($cols[0] eq $blast_genes[4] && ! looks_like_number($contig)) {
#        $number= 6;
#      }
#      $percent= $cols[2];
#    }


# looking for gen functions:
#  my $actinosMatch= `grep $genomeGen\t ActinoSMASH`;
#  my @parts= split/[\t\s]/, $actinosMatch;
#  my $function= ' ';
#  $function= $parts[2];
#  unless (length($function) < 2) {
    # print "function found: $function\n at $rast\n";
#    $none= $function;
#  }

 my $datum= $startCoord . "\t" . $endCoord . "\t" . $sign . "\t" . $number . "\t" . "$rast:$org" . "\t" . $molecFunction . "\t" . $id . "\t" . $percent . "\t" . $none . "\n";


  if (looks_like_number($contig) || $contig eq $cont) {
    push @{$out}, $datum;
  }


 if (looks_like_number($contig)) {
    push @{$out}, $datum;
   print "$contig looks like number\n";
    return $cont;
  }
}
