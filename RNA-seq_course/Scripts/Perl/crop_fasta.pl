use strict;
use Bio::SeqIO;

my $crop_length = 300;
unless ($ARGC > -1){
	print "Usage: $0 <fasta_file> <minimum_length>\n";
}
if($ARGC >0)$crop_length=$ARGV[1];
my $file = Bio::SeqIO->new(-file => $ARGV[0],-format => 'fasta');
while(my $seq = $file->next_seq)
{
unless($seq->length < $crop_length)
{
print ">".$seq->id."\n";
print $seq->seq."\n";
}
}

__END__

=pod

=head1 NAME

Crop Fasta Script

=head1 SYNOPSIS

The script was written to crop a fasta file by only keeping sequences longer than 300bp. The crop_length is variable now and can be supplied as second parameter to the script

Example:
	Crop the fasta file with minimum length 300bp
 	crop_fasta.pl my_sequence.fasta
	 
	Crop fasta file with minimum length of 200bp
 	crop_fasta.pl my_sequence.fasta 200

=head1 COPYRIGHT

Copyright (c) 2012, Simon Schliesky (simon.schliesky@uni-duesseldorf.de)
All rights reserved.


Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:


    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.


THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
