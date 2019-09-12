#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Bio::SeqIO;
use FileHandle;
my $help;
my $usage = "\n$0 [-h] annotation_infile [sequence infile] [outfile]\n
This script appends funtcional annotations stored in annotation_file to the fasta headers of the sequence file.\n
if sequence_file and or oufile are not supplied STDIN and STDOUT will be used\n
Run perldoc $0 for more information\n
\n
";

GetOptions(	'h|help|?' => \$help);
if ($help || $#ARGV == -1) {die($usage);}

my $sequences_input_fh = \*STDIN;
my $output_fh = \*STDOUT;

my %annotations;

open ANNOT, "<$ARGV[0]" or die("No such file: $ARGV[0]");
while(<ANNOT>){
	chomp;
	my ($id,@functional) = split("\t",$_);
	$annotations{$id} = join(" ",@functional);
}
close ANNOT;
if ($#ARGV>0){$sequences_input_fh = FileHandle->new("<$ARGV[1]")};
my $seqfile = Bio::SeqIO->new(-fh => $sequences_input_fh,-format => "fasta");
if ($#ARGV >1) {$output_fh = FileHandle->new(">$ARGV[2]");}
while(my $seq = $seqfile->next_seq){
my $anno = "No annotation available";
	if($annotations{$seq->id}) {$anno = $annotations{$seq->id};}

	print $output_fh ">".$seq->id."\t".$anno."\n";
	print $output_fh $seq->seq."\n";
}

__END__

=pod

=head1 NAME

Append functional annotations to fasta header

=head1 SYNOPSIS

This script will take an annotation of the form: id [tab] annotation, and include it into the fasta headers of the inputfile or STDIN

Example:
 	AppendHeaderToFasta.pl annotation.txt sequences.fasta > annotated_sequences.fasta
	 
 	cat sequences.fasta | AppendHeaderToFasta.pl annotation.txt | less

=head1 COPYRIGHT

Copyright (c) 2012, Simon Schliesky (simon.schliesky@uni-duesseldorf.de)
All rights reserved.


Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:


    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.


THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
