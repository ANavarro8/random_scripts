#!/usr/bin/perl
use strict;
use warnings;

## select fasta file from a given list, output sequence and size
my $version="1.0";
my $date='11/12/2012';
my $author="Shuqing Xu";
use Getopt::Std;
our ($opt_i, $opt_o, $opt_c, $opt_d);
getopts("i:o:d:c:");

my $usage="
######################################################################
perl -i input_list (tab) -c column_number -d fasta_data -o out_put
######################################################################
";

unless ($opt_i) {
	print $usage;
	exit;
}
unless ($opt_c) {
	$opt_c = 1;
}

$opt_c=$opt_c-1;

unless ($opt_d) {
	print $usage;
	exit;
}
unless ($opt_o) {
	$opt_o=$opt_i.".out";
}

my %hash;
open (I,"$opt_i");## tab format;
open (O,">$opt_o");## output;

while (<I>) {
	if (/\d+/) {
		my @tmp=split /\t/,$_;
		$hash{$tmp[$opt_c]}=$_;
		print O ">",$tmp[$opt_c],"\n";
		my $seq=RetrieveSeqLocal($tmp[$opt_c],$opt_d);
		print O $seq,"\n";
		

	}
	my $size=length($seq);
		print $size,"\n";
}

close (I);
close (O);

sub RetrieveSeqLocal{
use Bio::DB::Fasta;
my  $retrieve_id=shift;
my	$retrieve_database=shift;
my  $seq;
my $db = Bio::DB::Fasta->new($retrieve_database);
$seq	= $db->seq($retrieve_id);
return ($seq);	
}

