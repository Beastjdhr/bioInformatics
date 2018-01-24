use warnings;
use strict;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);

GetOptions(
        'left=i'=> \my $genL,
        'right=i' => \my $genR,
        'contexts=s' => \my $contexts,
) or die "Invalid options passed to $0\n";

#directory where the .input files will be written to:
my $outputDir= "salida";
#directory where the .txt are located:
my $inputDir= "../los1246";
#file path where the file matching genomes to rast numbers is located:
my $actinosFile="$inputDir/Actinos.ids";
#file from which genomes are retrieved:
my $genomesFile= "$inputDir/LivipeptineHits";
#blast file:
my $blast= 'output.txt';

#first, the genomes to retrieve must be stored in an array in order to
#be macthed to their rast numbers
my @targetGenes= getGenes($genomesFile);

#now that the genomes have been obtained, they are matched to their rast numbers
my %genAndRast= matchGenomes($actinosFile, @targetGenes);

#get the context of each gene:
my @fileList=writeContexts($inputDir,$outputDir, $genL, $genR, $blast, \%genAndRast);

my $ls= join(',',@fileList);

# open F, ">>tList.txt" or die $!;
# print F $ls;
# close F;
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
    $line=~ m/peg\.(\d+)/;
    $gen= $gen . $1;
    #this element (genome_gen is stored in an array which is the output of this subroutine)
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
    #look for the genome in the file
    my $query= `grep $1 $actinos`;
    #get rast number:
    $query=~ m/(\d+)\t/;
    #assign a value to each rast Number:
    $matches{$genome}= $1;
    #getting org name:
    $query=~ m/\d+\t(\D+)/;
    $matches{$genome} .= ".." . $1;
  }
  return %matches;
}

#this sub gets the context of the central gene and it calls more subs to get the contexts of the genes to the left and right

sub writeContexts {
  my $inPath= shift;
  my $outPath= shift;
  my $left= shift;
  my $right= shift;
  my $blastF= shift;
  my $genes= shift;

  my %genes= %$genes;

  my @list;


my $counter= 139 *21;
  foreach my $gen (keys %genes) {
    my @lines;
    print "$counter genes left\n";
    $counter-= 21;
    #getting rast number:
    $genes{$gen}=~ m/(\d+)\.\./;
    my $rast= $1;
    my $txtFilePath= "$inPath/" . $rast . ".txt";


    #getting gene number:
    $gen=~ m/_(\d+)/;
    my $geN= $1;

    my $contig= 0;

    #getting $orgName:
    $genes{$gen}=~ m/\.\.(\D+)/;
    my $orgName= $1;

    #getting central gen info and central contig;
    $contig=getContext($txtFilePath, $geN, $contig, $orgName, $blastF, \@lines);

    #calculating genes from left and right:
    my $leftSide= $geN - $left;
    my $leftLimit= $geN - 1;
    my @leftGenes= ($leftSide .. $leftLimit);

    my $rightSide= $geN +1;
    my $rightLimit= $geN + $right;
    my @rightGenes= ($rightSide .. $rightLimit);

    my @edgeGenes= (@leftGenes, @rightGenes);

    foreach my $edgeGen (@edgeGenes) {
      getContext($txtFilePath, $edgeGen, $contig, $orgName, $blastF, \@lines);
    }

    #writing contexts in .input file:
    push @list, "$rast\_$geN.input";

    foreach my $datum (@lines) {
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
  my $blast= shift;
  my $out= shift;



  #getting rastN:
  $path=~ m/\/(\d+)/;
  my $rast= $1;

  my $query= `grep "peg.$gen\tpeg" $path`;

  my @elements= split/\t/, $query;

  my $cont= $elements[0];
  my $startCoord=  $elements[4];
  my $endCoord= $elements[5];
  my $sign= $elements[6];
  my $number= looks_like_number($contig) ? 1 : 0;
  my $fig= $elements[1];
  my @Fig= split/[\.\|]/, $fig;
  my $Genome= $Fig[1] . "." . $Fig[2];
  my $molecFunction= $elements[7];
  my $id= $elements[1];
  my $percent=0;
  my $genomeGen= $Genome . "." . $gen;
  my $none= 'none';

#extracting genes from blast query:
my $blast_genes= `cut -f 1 $blast | uniq`;
my @blast_genes= split/\n/, $blast_genes;
my $blastSearch= ' ';
#checking if gene is in blast file:
$blastSearch= `grep "$fig" $blast`;
if (length($blastSearch) > 2 && ! looks_like_number($contig)) {
    my @cols= split/\t/, $blastSearch;
    unless ( $cols[0] eq $cols[1]) {
      if ($cols[0] eq $blast_genes[0]) {
        $number= 5;
      }
      elsif ($cols[0] eq $blast_genes[1]) {
        $number= 2;
      }
      elsif ($cols[0] eq $blast_genes[2]) {
        $number= 3;
      }
      elsif ($cols[0] eq $blast_genes[3]) {
        $number= 4;
      }
      elsif ($cols[0] eq $blast_genes[4]) {
        $number= 6;
      }
      $percent= $cols[2];
    }
  }

# looking for gen functions:
  my $actinosMatch= `grep $genomeGen\t ../los1246/ActinoSMASH`;
  my @parts= split/[\t\s]/, $actinosMatch;
  my $function= ' ';
  $function= $parts[2];
  unless (length($function) < 2) {
    # print "function found: $function\n at $rast\n";
    $none= $function;
  }

  my $datum= $startCoord . "\t" . $endCoord . "\t" . $sign . "\t" . $number . "\t" . "$rast:$org" . "\t" . $molecFunction . "\t" . $id . "\t" . $percent . "\t" . $none . "\n";


  if (looks_like_number($contig) || $contig eq $cont) {
    push @{$out}, $datum;
  }


  if (looks_like_number($contig)) {
    # print "$contig looks like number\n";
    return $cont;
  }
}
