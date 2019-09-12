#!/usr/bin/perl
use warnings;
use strict;
use FileHandle;

# Thomas Mullick Jul.2010
# edited Tue Sep 14 2010 by Simon Schliesky

####THIS VERSION RETURNS ONLY A SINGLE HIT PER READ!!!

# Usage for: this script is to get the bestBLAT hits from a given blat .psl file.
# First get the required columns only of that file via linux command
# "cut -f 1,10,14 file.psl | sort -k2,2 -k1,1nr > sorted_file".
# That takes out the column 1,10 and 14. The result of that is sorted then
# first of column 3 and afterwards to column 1 in numerical decreasing order.
# That resulting file is the input for this script which gives then as result
# the best BLAT hits. Also giving as output different queries which hit the
# same target with the same score ONLY (the elsif below). After running
# this script a "uniq -u" with the output file of this script can be used
# to clean the output a bit more and remove duplicate lines.

#edit: supports more than 3 columns if the first three are as described. Piping out enabled
#edit2: Piping in enabled
my $input_fh = \*STDIN;
if($ARGV[0]){$input_fh=FileHandle->new("<$ARGV[0]");}

my $prev_query = "";
my $prev_match = "";
my $prev_target = "";
#my $prev_digit = "";
my $sum = 0;

my @result = "";

while (<$input_fh>) {
	
	if (m/^(\d+)\t(\S+)\t(\S+)(.*)/){
#	m/^(\d+)\t(\w+)\t(\w+)/;
		if ($2 ne $prev_query) {
			chomp;
			#print OF "$_\n";
			print "$_\n";
			$prev_match = $1;
			$prev_target = $3;
			$prev_query = $2;
			#$prev_digit = $4;
		
		}
		
#		elsif ($2 eq $prev_query && $1 eq $prev_match && $3 ne $prev_target) {
#			chomp;
#			print "$_\n";
#			#print OF "$_\n";
#			$sum++;
#			
#		}
		

		
	
	}

	
}
die("number of duplicates for the same target with same matching bases: $sum\n");










