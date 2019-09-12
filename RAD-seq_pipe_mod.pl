#!/usr/bin/perl
use strict;
use warnings;
use threads;
use Thread::Queue;

#RADseq analysis pipleline;

my $version =1.0;
my $author = "Shuqing Xu";
my $date="4/2/2013";

## Path and sample information##
my $path="/data/RNAseq/Nicotiana/Allopolyploids";
my $map="/data/RNAseq/Nicotiana/Allopolyploids/map";
my $cleandata="/data/RNAseq/Nicotiana/Allopolyploids/CleanData";
## bin ##
my @trim_shell;
my @map_shell;
my @sam2bam_shell;
my @merge_shell;
my @sort_shell;
my $n_process=20;
my $bowtie_process=5;
## step 1 read the sample list and store the shell commands;

	my @file=`ls $path `;
	chomp(@file);
	for (my $i=0;$i<@file;$i++) {
		my $name=$file[$i];
		$name=~s/Sample_//;
		$name=~tr/-/_/;
		my @reads=`ls  $path/$file[$i]/*.gz `;
		chomp (@reads);
		print "$file[$i]","/","$reads[0]\n";

my $f_file="$reads[0]";
my $r_file="$reads[1]";


## trimming;
#my $trim_sh= "
#AdapterRemoval --file1 <(zcat $f_file) --file2 <(zcat $r_file) --trimns --trimqualities --minquality 30 --minlength 36 --collapse --qualitybase 33 --#output1 >(gzip > $cleandata/$name\_f_trim.fq.gz) --output2 >(gzip > $cleandata/$name\_r_trim.fq.gz) --singleton >(gzip > $cleandata/$name
#\_singleton_trim.fq.gz) --discarded /dev/null 
#";
#push (@trim_shell, $trim_sh);



## mapping
my $map_shell_pair="
bowtie2-align -x /data/Genomes/NIATT/NIATT30_v6 -1 <(zcat  $cleandata/$name\_1_trim.fq.gz ) -2 <(zcat $cleandata/$name\_2_trim.fq.gz ) -S $map/$name.pair.sam -p 4 --phred33 -I 100 -X 700 
";
my $map_shell_unpair="
bowtie2-align -x /data/Genomes/NIATT/NIATT30_v6 -U <(zcat  $cleandata/$name\_singleton_trim.fq.gz )  -S $map/$name.single.sam -p 4 --phred33 -I 100 -X 700 
";
push (@map_shell, $map_shell_pair,$map_shell_unpair);


## sam2bam;
my $sam2bam_single_sh="
samtools view -bhS -q 1  -T /data/Genomes/NIATT/NIATT30_v6.fa -q 10  $map/$name.single.sam | samtools sort - $map/$name.single
";
my $sam2bam_pair_sh="
samtools view -bhS -q 1  -T /data/Genomes/NIATT/NIATT30_v6.fa -q 10  $map/$name.pair.sam  | samtools sort - $map/$name.pair
";
push (@sam2bam_shell,$sam2bam_single_sh,$sam2bam_pair_sh);


## Merge;
my $merge_sh="
samtools merge  -f $map/$name.merged.bam $map/$name.single.bam $map/$name.pair.bam 
";
push (@merge_shell,$merge_sh);

## Sort;
my $sort_sh="
samtools sort $map/$name.merged.bam $map/$name.merged.sorted
";

push (@sort_shell,$sort_sh);
}

## all shell saved;
# run shell command

#
print "Trim started\n";

#&RUNSHELL($n_process,\@trim_shell);

print "
########################################
		Triming finished
########################################
\n";
print "Mapping started\n";

#&RUNSHELL(5, \@map_shell);

print "
########################################
		Mapping finished
########################################
\n";
#exit;
#print join "\t", @sam2bam_shell;

print "SAM2BAM started\n";


#&RUNSHELL($n_process, \@sam2bam_shell);

print "
########################################
		SAM2BAM finished
########################################
\n";
print "BAM merge started\n";


#print join "\n", @merge_shell;
#exit;
#&RUNSHELL($n_process, \@merge_shell);

print "
########################################
		Merge finished
########################################
\n";
print "BAM sort started\n";

#print join "\n", @sort_shell;
#exit;

&RUNSHELL($n_process, \@sort_shell);

print "
########################################
		BAM sort finished
########################################
\n";
print "RAD-seq mapping finished\n";









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
			system ( @args );
	}
}

for (0..$num_threads-1) { $queue->enqueue(undef); }
for (0..$num_threads-1) { @{$shell_ref}[$_]->join; } # finish up;
}



## command for SNP calling...
#
# ls -l *.sam | awk '{print "samtools view -bhS -q 1  -T /data/Genomes/NIATT/NIATT30_v6.fa -q 10  " $8 " | samtools sort - " $8".bam &"}'|sh
#samtools mpileup -ugDBQ10 -d1000 -f /data/Genomes/NIATT/NIATT30_v6.fa -b bamlist.txt | bcftools view -bvcgL - > var.sub.raw.bcf
#bcftools view var.sub.raw.bcf | vcfutils.pl varFilter -D100000000 -d 50 > var.sub.flt.vcf

