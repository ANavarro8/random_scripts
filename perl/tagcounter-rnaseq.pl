#! /usr/bin/perl -w

# tagcounter.pl
# a simple script to parse a MAQ "pileup" file and count the number of reads mapping to each unigene
# normalise counts using RPKM (reads per kb per million reads)
# Ref: Mortazavi et al. Nature Methods 2008
# RPKM calculation takes into account the number of mapped reads and the length of the unigene
# outputs Arabidopsis homolog from BLAST file

# The pileup file output suppresses reported
# depth at low Q's so summing depth from pileup and dividing by k gives
# a read number a couple of percent off MAQ's summary statistics.

# Martin.Trick@bbsrc.ac.uk, 7/12/2009
# Janet.Higgins@bbsrc.ac.uk  25/03/2010


unless (@ARGV == 2) {
  print "Usage: tagcounter.pl <pileup file> <output file>\n";
  exit;
}

my %tags = ();
my %length = ();
my %hits = ();
my $mapped_bases = 0;
my $hits = 0;

my $directory = '/usr/users/cbu/higginsj';
my $read_length = 80; # Adjustable, but irrelevant to RPKM calculation

# Try to open all FH's
open (PILEUP, "<$ARGV[0]") or die "Couldn't open pileup file ($!)\n";
open (OUT, ">$ARGV[1]") or die "Couldn't open output file ($!)\n";
open (GFF, "<$directory/unigenes/unigenes.gff") or die "Couldn't open lookup file ($!)\n";

# Assemble the unigene/AGI correspondences
while (<GFF>) {
  if (my($agi,$unigene) = /^([\w\.]+)\t.*?\s(\w+)$/) {
    $hits{$unigene} = $agi;
  }
  elsif (($agi,$unigene) = /^([\w\.]+)\t.*?\s(\w+) ; Note /) {
    $hits{$unigene} = $agi;
  }
}
close GFF;

# Count all mapped bases for each unigene
while (<PILEUP>) {
  my @cols = split;
  $length{$cols[0]} = $cols[1];
  $tags{$cols[0]} += $cols[3];
}
close PILEUP;

foreach my $unigene(keys %length) {
  $transcriptome += $length{$unigene};
}

foreach my $unigene(keys %tags) {
  $mapped_bases += $tags{$unigene};
  $hits++ if ($tags{$unigene});
}

print "Reference sequence length $transcriptome\n";
print "Number of unigenes with mapped reads $hits\n";
print "Number of mapped $read_length" . "nt reads " . ($mapped_bases/$read_length) . "\n";

#print OUT "unigene\tAGI\tTAG\tRPKM\n";  #remove if you do not require column headings

foreach my $unigene(sort keys %tags) {
  print OUT "$unigene\t";
  if (exists $hits{$unigene}) {
    print OUT "$hits{$unigene}\t";
  }
  else {
    print OUT ".\t";
  }

 #This is absolute tag count
 $count = ($tags{$unigene})/$read_length;

 # This is R in RPKM (reads per kb per million reads) - NB read length cancels out
 $r = (1E9*($tags{$unigene}))/($mapped_bases*$length{$unigene});

 # This is X, absolute transcript number - remove for now
 # $x = ($r*$transcriptome)/1E9;

print OUT "$count\t$r\n";
}

close OUT;