#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use IO::Handle;

##########Hardcoded constants
my $ACCEPTED_OVERLAP = 5; #percentage of overlap tolerated in hybrids   
my $MINIMUM_MATCHING_LENGTH = 75;
##########

##########Global variables
my $inputfile ="";
my $fh_inputfile=\*STDIN;
my $algorithm ="blat";
my @block;
my $block_count=0;
my $first = 1;
my $previous_id="";
my $previous_target="";
my $line=0;
my $run_usage = 0;

##########Subs

####SUB min returns the smaller of two values
sub min($$){
	return ($_[0]>$_[1])?$_[1]:$_[0];
}

####SUB max returns the greater of two values
sub max($$){
	return ($_[0]<$_[1])?$_[1]:$_[0];
}

####SUB usage checks for the correct initialization of parameters and prints a help message if false
sub usage{
	if( $run_usage || $algorithm eq "" ){
			print <<EOUSAGE
			Usage for $0
			
			$0 --infile --algorithm --usage
			
			--infile needs to be a sorted(-k10,10 -k1,1nr) mapping file without headers
			--algorithm is either blat or BLAST(not supported yet)
			--usage -? prints this help.
			For more information run perldoc $0			
			
EOUSAGE
;
		exit -1;
	}
	return 1;
}

####SUB process_stuff processes all datasets on global variable block. (one query at a time)
####	Compares all multiple mappings pairwise in terms of target and range of mapping.
####	If more than one target is hit and those targets are hit by different fragments of the
####	contig, the contig is considered chimera
sub process_stuff($){
			my $queryID = $block[0]->[1];
			my $output = ">$queryID\n";
			my $count = 0;
			my @nonOverlapping;
			$nonOverlapping[0]=1;
			for my $cVar (0 .. $#block) {$nonOverlapping[$cVar]=1};
			
			for (my $i = 0; $i<scalar(@block);$i++){
					for (my $j = 0; $j<scalar(@block);$j++){
						print STDERR "nonOverlapping before ".join(",",@nonOverlapping)."\n";
						if ($j > $i && $nonOverlapping[$j]){
						print STDERR "\t[$i,$j]\n";
						my $start1 = min($block[$i]->[3],$block[$i]->[4]);
						my $start2 = min($block[$j]->[3],$block[$j]->[4]);
						my $end1 = max($block[$i]->[3],$block[$i]->[4]);
						my $end2 = max($block[$j]->[3],$block[$j]->[4]);
						my $size1 = $block[$i]->[2];
						my $target1 = $block[$i]->[5];
						my $target2 = $block[$j]->[5];
						
						(my $parent1 = $target1) =~ s/([a-zA-Z0-9]+).[0-9]*/$1/; #Arabidopsis specific RegEx
						(my $parent2 = $target2) =~ s/([a-zA-Z0-9]+).[0-9]*/$1/; #Arabidopsis specific RegEx
						print STDERR ">$queryID\t".join("\t",($start1,$start2,$end1,$end2))."\n";
						print STDERR "$queryID:\t".($start2>$end1&&$end2>$end1)."\t".($start1>$end2&&$end1>$end2)."\t"."\n";
						print STDERR "Targets $target1 vs $target2 \n";
						
						print STDERR "\nboolean check start2 > end1-overlap: ".($start2 > ($end1-$size1*$ACCEPTED_OVERLAP/100))."\n";
						print STDERR "boolean check end2 < start1+overlap: ".($end2 < ($start1+$size1*$ACCEPTED_OVERLAP/100))."\n";
						print STDERR "numerical values\tStart2\tEnd2\tEnd1-overlap\tStart1+overlap\n" .
									 "                \t$start2\t$end2\t".($end1-$size1*$ACCEPTED_OVERLAP/100)."\t".($start1+$size1*$ACCEPTED_OVERLAP/100)."\n";
							
						unless (	(($start2 > ($end1-$size1*$ACCEPTED_OVERLAP/100)) 	# gene1 than gene2
									||													# or
									($end2 < ($start1+$size1*$ACCEPTED_OVERLAP/100)))	# gene2 than gene1
									&&
									($end2-$start2)>75
									&&
									($end1-$start1)>75
						){							
							print STDERR "Overlap of ${i}::$target1 and ${j}::$target2\n";
							$nonOverlapping[$j] *= 0;
							
							
							next;
							} #fi
						else {	print STDERR "Non-overlapping pair [${i},${j}]\t[$target1,$target2]\n";
								unless ($parent1 eq $parent2){$count++;}else{$nonOverlapping[$j] *= 0;}#ADDED120110-1050AM else to prevent chimera detection in isoforms
						}
					print STDERR "at [i,j] [$i,$j] nonOverlapping after ".join(",",@nonOverlapping)."\n";
					} #unless
					print STDERR "#NEXT#\n";
				} #for j
			} #for i
			
			if($count > 0){
				my $sum = 0;
				my $i = 0;
				foreach my $nonOV (@nonOverlapping){
					print STDERR "nonOV = $nonOV\tsum = $sum\n";
					print STDERR "join of block\t".join("\t",@{$block[$i]})."\n";
					if($nonOV){
						$output .= "\tTarget ".$block[$i]->[5]." mapping at: ".$block[$i]->[3]." to ".$block[$i]->[4]."\n";
					}
					$sum += $nonOV;
					$i++;
				}
				if ($sum > 1){print $output;}
				else {print ">$queryID not a hybrid :)\n";}
				print STDERR ($count+1)." targets hit by query ".$block[0]->[1]."\n";
			}
			else{print ">$queryID not a hybrid :)\n";}
			print STDERR "#################################FLUSH BLOCK\n";
			undef @block;
}
sub debug_block {
	foreach my $el (@block){
		print STDERR $block_count.":".join("\t",@$el)."\n";
	}
	$block_count++;
	
}
################ENDSUBS

GetOptions(
	'infile|in=s' => \$inputfile,
	'algorithm|alg=i' => \$algorithm,
	'usage|?' => \$run_usage	
	);
usage() or die("impossible error occurred");

if( $inputfile ne "" && -e $inputfile){
	open FH, "<$inputfile";
	$fh_inputfile=\*FH; 
}
elsif($inputfile ne ""){die("No such inputfile $inputfile\n");} #fi

while(<$fh_inputfile>){
my @relevant;
	if($algorithm eq "blat"){
		chomp;
#		my (		$matches,	#   1. matches - Number of bases that match that aren't repeats
#				undef,		#   2. misMatches - Number of bases that don't match
#				undef,		#   3. repMatches - Number of bases that match but are part of repeats
#				undef,		#   4. nCount - Number of 'N' bases
#				undef,		#   5. qNumInsert - Number of inserts in query
#				undef,		#   6. qBaseInsert - Number of bases inserted in query
#				undef,		#   7. tNumInsert - Number of inserts in target
#				undef,		#   8. tBaseInsert - Number of bases inserted in target
#				undef,		#   9. strand - '+' or '-' for query strand. For translated alignments, second '+'or '-' is for genomic strand
#				$query_id,	#  10. qName - Query sequence name
#				$query_size,	#  11. qSize - Query sequence size
#				$qStart,	#  12. qStart - Alignment start position in query
#				$qEnd,		#  13. qEnd - Alignment end position in query
#				$target_id,	#  14. tName - Target sequence name
#				undef,		#  15. tSize - Target sequence size
#				undef,		#  16. tStart - Alignment start position in target
#				undef,		#  17. tEnd - Alignment end position in target
#				undef,		#  18. blockCount - Number of blocks in the alignment (a block contains no gaps)
#				undef,		#  19. blockSizes - Comma-separated list of sizes of each block
#				undef,		#  20. qStarts - Comma-separated list of starting positions of each block in query
#				undef,		#  21. tStarts - Comma-separated list of starting positions of each block in target 
#			) = split("\t",$_);

		my @data = split("\t",$_);
		####DEBUG STATEMENT
		#unless ( $data[9] eq "11_CTTGTA_L007_R1_001contig10007" ||  $data[9] eq "11_CTTGTA_L007_R1_001contig10098") {next;}
		####END OF DEBUG STATEMENT
		
		
		undef @relevant;
					# Array relevant
					#	0: number of matches
					#	1: query ID
					#	2: query size
					#	3: query start
					#	4: query end
					#	5: target ID
		
		push(@relevant,($data[0],$data[9],$data[10],$data[11],$data[12],$data[13]));
		undef(@data);
		
		print STDERR "before debug_block\n";
		&debug_block;
		print STDERR "TEST: ".join("::",@relevant)."\n";

		if($relevant[1] eq $previous_id || $first == 1){
				print STDERR "query=previous, first=$first\n";
				$first=0;
			} #fi(previous_id eq current_id)
		else{	#if(query_id ne previous_id)
			print STDERR "query ne previous, first=$first\n";
			&process_stuff(\@relevant);
		} #esle
		push(@block,\@relevant);
$previous_id = $relevant[1];
	} #fi(algorithm == blat)
} #while	
print STDERR "out of while\n";
&debug_block;
&process_stuff unless (scalar(@block)<2);
exit 1;


__END__

=pod

=head1 NAME

Detect Hybrid Contigs

=head1 SYNOPSIS

This script is designed to detect hybrid assemblies from a sorted BLAT contig mapping to Arabidopsis. The output is FASTA-like as it uses FASTA headers and writes one mapping per line in the sequence area. Non-hybrids just consist of the header and are greppable by "not a hybrid".

Settable CONSTANTS:
 	ACCEPTED_OVERLAP=5 the percentage of mapping length accepted to overlap in mapping region: default 5
 	MINIMUM_MATCHING_LENGTH=75 Minimum length of mapping region to be considered at all: default 75

Example:
 	sort -k10,10 -k1,1nr | detect_hybrid_contigs.pl >hybrids.txt


=head1 COPYRIGHT

Copyright (c) 2012, Simon Schliesky (simon.schliesky@uni-duesseldorf.de)
All rights reserved.


Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:


    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.


THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
