#!/usr/bin/perl -w
use strict;

##################
#
# before using this script, cut and sort the blast tabular output (m8)
# cut -f1,2,11 blast_output.txt | sort -k1,1 -k3,3nr > somefile.txt

open FH ,"<".$ARGV[0];
my $previous = "";
while(<FH>){
	chomp;
	my ($query, $target, $eval) = split("\t",$_);
	$target =~ s/^([a-zA-Z0-9|_.]+)/$1/;
	unless ($query eq $previous){
		print "$query\t$target\t$eval\n";
		$previous = $query;
	}
}


