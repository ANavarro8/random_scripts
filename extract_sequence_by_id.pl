#!/usr/bin/perl -w

use strict;
use Bio::SeqIO;
use Getopt::Long;

my $help  = '';
my $exclude_list = '';
my $idfile = '';
my $seqfile = '';
my $format = 'fasta';
my $outputfile = '';

GetOptions(
					'help|?' => \$help,
					'exclude' => \$exclude_list,
					'ID|file1=s' => \$idfile,
					'sequences|file2=s' => \$seqfile,
					'fileformat|ff|format=s' => \$format,
					'outfile=s' => \$outputfile
					);

usage() if($help);
usage() unless($idfile && $seqfile && $outputfile);



my %allowed;
if($format eq "txt"){
	open IN, "<$idfile";
	while(<IN>){
		chomp($_);
		$allowed{$_} = 1;
	}
	close IN;
}
else {
	my $id_file = Bio::SeqIO->new(-format => 'fasta', -file => $idfile);
	while (my $seq = $id_file->next_seq){
		$allowed{$seq->id} = 1;
	}
	undef $id_file;
}   


if($outputfile){open OUT, ">$outputfile";};
my $sequences = Bio::SeqIO->new(-format => 'fasta', -file => $seqfile);
while (my $seq = $sequences->next_seq){
	if($exclude_list){
		unless($allowed{$seq->id}){
			print OUT ">".$seq->id."\n";
			print OUT $seq->seq."\n";
		}
	}
	else{
		if ($allowed{$seq->id}){
                print OUT ">".$seq->id."\n";
                print OUT $seq->seq."\n";
            }
    }
}
undef $sequences;

close OUT;

sub usage{
	print "Usage of $0\n$0 [-? -e] --ID=<inputfile1> --sequences=<inputfile2> --outfile=<outputfile1> --ff=(txt|fasta) \n\n";
	print "This program creates a .fasta sequence file with selected sequences only\n\nParameters:\n";
	print "--help or -? shows this usage\n";
	print "--exclude or -e if used the program will return all sequences that are NOT in ID file\n";
	print "--ID path to inputfile containing IDs\n";
	print "--sequences path to fasta formatted inputfile containing sequences\n";
	print "--outfile path to outputfile\n";
	print "--fileformat or --ff file format of the ID file (either txt or fasta[default]) fasta-formatted ID files must have leading \">\"-characters\n";
	print "\n";
	exit(0);
}

__END__

=pod

=head1 NAME

Extract_Sequence_by_ID

=head1 SYNOPSIS

This script was created to either extract fasta sequences for a list of identifiers or to extract all fasta sequences except those in the list from a regular formatted fasta file. 

Usage: Extract_Sequence_by_ID [-?e] --ID=<identifier_list_file> --sequences=<source_sequence_file> --outfile=<output_target> --ff=<txt|fasta>

Examples:

 	Extracting the sequences for all identifiers in ID.txt from seq.fasta
 	extract_sequence_by_id.pl --ID=ID.txt --sequences=seq.fasta --outfile=chosen_seqs.fasta --ff=txt

 	Extracting all sequences that are not listed in ID.txt(with leading ">" characters) from seq.fasta
 	extract_sequence_by_id.pl --exclude --ID=ID.txt --sequences=seq.fasta --outfile=chosen_seqs.fasta --ff=fasta

=head1 COPYRIGHT

 Copyright (c) 2012, Simon Schliesky (simon.schliesky@uni-duesseldorf.de)
 All rights reserved.


Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:


    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.


THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
