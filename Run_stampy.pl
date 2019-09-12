#!/usr/bin/perl
use strict;
use warnings;
use threads;
use Thread::Queue;


## Run Stampy for different species;
my $stampy_bin="/home/likewise-open/ICE/sxu/Projects/Transcriptome/Species_variation/stampy-1.0.21/stampy.py";
my $stampy_fold="/data/RNAseq/Nicotiana/Interspecies/Stampy";
my $bwa_bin="/usr/bin/bwa";
my $genome="/data/Genomes/NIATT/NIATT30_v7mc.fa";
my $genome_hash="/data/Genomes/NIATT/NIATT30_v7mc";

my $cleandata="/data/RNAseq/Nicotiana/Interspecies/CleanData";

my @sample=` ls $cleandata `;
chomp(@sample);
my @bwa_aln_array;
my @bwa_sample_array;
my @stampy_array;
for (my $i=0;$i<@sample;$i++) {
#	print $sample[$i],"\n";
	if ($sample[$i]=~/_f_trim/ and $sample[$i]!~/Natt/) {
	my $filename=(split(/_f_trim/,$sample[$i]))[0];
#	my $outfile=$filename."sam";
	my $file_f=$cleandata."/".$filename."_f_trim.fq.gz";
	my $file_r=$cleandata."/".$filename."_r_trim.fq.gz";
	my $file_f_sai=$filename."f.sai" ;
	my $file_r_sai=$filename."r.sai" ;
#print $filename,"\n";
	my $bwa_aln=" 
	bwa aln -q10 -t4 $genome $file_f > $file_f_sai 
	bwa aln -q10 -t4 $genome $file_r > $file_r_sai 
	";
	my $bwa_sample="
	bwa sampe $genome $file_f_sai $file_r_sai  <(zcat $file_f) <(zcat $file_r )| samtools view -Sb - > $filename.bam
	";
	push (@bwa_aln_array,$bwa_aln);
	push (@bwa_sample_array,$bwa_sample);
	my $substitutionrate;
	if ($filename=~/Nob/)
		{
		$substitutionrate=0.05;
	}
	else{
	$substitutionrate=0.03
	}

	my $stampy="
	$stampy_bin -g $genome_hash -h $genome_hash --substitutionrate=$substitutionrate --insertsize=200 --insertsd=60 --bamkeepgoodreads -o $stampy_fold/$filename.1.sam --processpart=1/8 -M $filename.bam
	$stampy_bin -g $genome_hash -h $genome_hash --substitutionrate=$substitutionrate --insertsize=200 --insertsd=60 --bamkeepgoodreads -o $stampy_fold/$filename.2.sam --processpart=2/8 -M $filename.bam
	$stampy_bin -g $genome_hash -h $genome_hash --substitutionrate=$substitutionrate --insertsize=200 --insertsd=60 --bamkeepgoodreads -o $stampy_fold/$filename.3.sam --processpart=3/8 -M $filename.bam
	$stampy_bin -g $genome_hash -h $genome_hash --substitutionrate=$substitutionrate --insertsize=200 --insertsd=60 --bamkeepgoodreads -o $stampy_fold/$filename.4.sam --processpart=4/8 -M $filename.bam
	$stampy_bin -g $genome_hash -h $genome_hash --substitutionrate=$substitutionrate  --insertsize=200 --insertsd=60 --bamkeepgoodreads -o $stampy_fold/$filename.5.sam --processpart=5/8 -M $filename.bam
	$stampy_bin -g $genome_hash -h $genome_hash --substitutionrate=$substitutionrate --insertsize=200 --insertsd=60 --bamkeepgoodreads -o $stampy_fold/$filename.6.sam --processpart=6/8 -M $filename.bam
	$stampy_bin -g $genome_hash -h $genome_hash --substitutionrate=$substitutionrate --insertsize=200 --insertsd=60 --bamkeepgoodreads -o $stampy_fold/$filename.7.sam --processpart=7/8 -M $filename.bam
	$stampy_bin -g $genome_hash -h $genome_hash --substitutionrate=$substitutionrate --insertsize=200 --insertsd=60 --bamkeepgoodreads -o $stampy_fold/$filename.8.sam --processpart=8/8 -M $filename.bam
	";
	push (@stampy_array,$stampy);
	}
}


### run shell
#my $n_thread=8;
#&RUNSHELL(3, \@bwa_aln_array);

#&RUNSHELL(12, \@bwa_sample_array);

#print join "\n", @stampy_array;


&RUNSHELL(12, \@stampy_array);

##




sub RUNSHELL{
    my $num_threads = shift;
	my $shell_ref=shift;
    my $queue = new Thread::Queue;

## save all the shell command in the queue;
    while ($_ = shift @{$shell_ref}) {
            $queue->enqueue($_);
    }


# run command;
for (0..$num_threads-1) {
		@{$shell_ref}[$_] = new threads(\&worker);
    }

sub worker() {
	while (my $shell = $queue->dequeue) {
		my @args=("bash","-c",$shell);
		print join " ", @args,"\n";
			system ( @args );
	}
}

for (0..$num_threads-1) { $queue->enqueue(undef); }
for (0..$num_threads-1) { @{$shell_ref}[$_]->join; } # finish up;
}
