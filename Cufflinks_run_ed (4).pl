#!/usr/bin/perl
use strict;
use warnings;


my $version =1.0;
my $author = "Shuqing Xu, modified by ANQ";
my $date="3/23/2013";

## Path and sample informaiton##
my $mappeddata="/data/RNAseq/Nicotiana/Allopolyploids/tophat";
my $genome="/data/Genomes/NIATT/NIATT30_v6_clean";
my $outfile="/data/RNAseq/Nicotiana/Allopolyploids/cufflinks";

## bin ##
%my $cufflinks="/usr/local/bin/tophat2";

my @sample=` ls  $mappeddata `;
chomp(@sample);
for (my $i=0;$i<@sample;$i++) {
	if ($sample[$i]=~/_tophat/) {
	my $filename=(split(/_tophat/,$sample[$i]))[0];
	my $outfile=$filename."_cufflinks";
	my $tophat_out=$mappeddata."/".$filename."accepted_hits.bam";
	#my $file_r=$cleandata."/".$filename."_2_trim.fq.gz";
print $filename,"\n";

print " 
cufflinks  -o $outfile $genome $bowtie_out &
	";
}
#if ($filename =~/1506/ or $filename =~/1507/ or $filename =~/1508/ or $filename =~/1509/ or $filename =~/1510/ or $filename =~/1511/ or $filename =~/1512/ or $filename =~/1513/ or $filename =~/1514/ or $filename =~/1515/ or $filename =~/1516/ or $filename =~/1517/) {
#print " 
#$tophat2  -I 50000  -p 4 -r 40 --mate-std-dev 40 -o $outfile $genome $file_f $file_r &
#	";
#}
#if ($filename =~/1717/) {
#print " 
#$tophat2  -I 50000  -p 4 -r 40 --mate-std-dev 40 -o $outfile $genome $file_f $file_r &
#	";
#}
#if ($filename =~/1821/) {
#print " 
#$tophat2  -I 50000  -p 4 -r 100 --mate-std-dev 50 -o $outfile $genome $file_f $file_r &
#	";
#}

#if ($filename =~/1498/) {
#print " 
#$tophat2  -I 50000  -p 10 -r 130 --mate-std-dev 60 -o $outfile $genome $file_f $file_r &
#	";
#}



#	}

}
