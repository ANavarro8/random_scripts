#!/usr/bin/perl
use strict;
use warnings;
#script to open multiple sequence files and put into fdnadist

my $version =1.0;
my $author = " ANQ";
my $date="11/20/2013";

## Path and sample information##
my $seqdata="~/Copia_LTRs/test/alignments/";
my $infile="~/Copia_LTRs/test/alignments/";
my $outfile="~/Copia_LTRs/test/";

## bin ##
#

my @sample=` ls  $seqdata `;
chomp(@sample);
for (my $i=0;$i<@sample;$i++) {
	if ($sample[$i]=~/.fasta/) {
	my $filename=(split(/.fasta/,$sample[$i]))[0];
	my $outfile=$filename.".fdnadist";
	my $infile=$filename.".fasta";
	#my $file_r=$cleandata."/".$filename."_2_trim.fq.gz";
#print $filename,"\n";

print " 
fdnadist -lower Yes -method f -sequences $infile -outfile $outfile &
	";
}


}
