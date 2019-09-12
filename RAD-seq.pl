#!/usr/bin/perl
use strict;
use warnings;
use threads;
use Thread::Queue;

#RADseq analysis pipleline;

my $version =1.0;

my $author = "Shuqing Xu";
my $date="4/2/2013";
$version=2.0; ## use GATK piple line;
## make remove duplication optional;
## 4/22/2013;
print $version,"\n";
my %pool;
my %lane;
my %lib;
my %barcode;
my $path="/data/Genomes/RAD/MAP";
open (S, "/data/Genomes/RAD/RAWDATA/Sample_list.txt");
while (<S>) {
	if (/\d/) {
		$_=~tr/\n//d;
		$_=~tr/\r//d;
		my @tmp=split(/\t/,$_);
## sample info format:
#1	AzxUTF2-10	TACGT	Pool=P098	Lib=2048
		$_=~/^(\d)\tAzxUTF2\-(\d+)\t(\w+)\tPool\=(\S+)\tLib\=(\d+)/;
		$pool{$2}=$4;
		$lane{$2}=$1;
		$lib{$2}=$5;
		$barcode{$2}=$3;
#		print $2,"\n";
	}
}



## Path and sample informaiton##
my $path="/data/Genomes/RAD/RAWDATA";
my $map="/data/Genomes/RAD/MAP";
my $cleandata="/data/Genomes/RAD/CLEANDATA";
my $ref_bowtie="/data/Genomes/NIATT/NIATT30_v6_RAD";
my $ref="/data/Genomes/NIATT/NIATT30_v6_RAD.fa";
## bin ##
my @trim_shell;
my @map_shell;
my @sam2bam_shell;
my @merge_shell;
my @sort_shell;
my $n_process=20;
#my $bowtie_process=5;
## step 1 read the sample list and store the shell commands;

	my @file=`ls $path `;
	chomp(@file);
	for (my $i=0;$i<@file;$i++) {
		if ($file[$i]!~/Sample_list\.txt/) {
		my $name=$file[$i];
		$name=~s/Sample_//;
		$name=~tr/-/_/;
		$name=~s/AzxUTF2_//d;
		my @reads=`ls  $path/$file[$i]/*.gz `;
		chomp (@reads);
#		print "$file[$i]","/","$reads[0]\n";

		my $f_file="$reads[0]";
		my $r_file="$reads[1]";


		## triming;
		my $trim_sh= "
		AdapterRemoval --file1 <(zcat $f_file) --file2 <(zcat $r_file) --trimns --trimqualities --minquality 30 --minlength 36 --collapse --qualitybase 33 --output1 >(gzip > $cleandata/$name\_f_trim.fq.gz) --output2 >(gzip > $cleandata/$name\_r_trim.fq.gz) --singleton >(gzip > $cleandata/$name\_singleton_trim.fq.gz) --discarded /dev/null 
		";
		push (@trim_shell, $trim_sh);



		## mapping
		my $map_shell_pair="
		bowtie2-align -x /data/Genomes/NIATT/NIATT30_v6_RAD -1 <(zcat  $cleandata/$name\_f_trim.fq.gz ) -2 <(zcat $cleandata/$name\_r_trim.fq.gz ) -U <(zcat  $cleandata/$name\_singleton_trim.fq.gz ) -p 4 --phred33 -I 100 -X 700 | samtools view -bhS -q 1 - > $map/$name.bam
		";
		push (@map_shell, $map_shell_pair);


		my $add_group="
		java -Xmx30g -jar /home/likewise-open/ICE/sxu/soft-download/picard-tools-1.87/AddOrReplaceReadGroups.jar I=$map/$name.bam O=$map/$name.gs.bam SORT_ORDER=coordinate RGPL=illumina RGPU=DD61XKN1:152:C1DJHACXX:$lane{$name} RGLB=$lib{$name} RGID=RAD96 RGSM=$name VALIDATION_STRINGENCY=LENIENT 
		";
		push (@AddGroup,$add_group);


		my $marke_dup="
		java -jar /home/likewise-open/ICE/sxu/soft-download/picard-tools-1.87/MarkDuplicates.jar I=$map/$name.gs.bam O=$map/$name.gs.dedup.bam M=$map/$name.M AS=true MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 REMOVE_DUPLICATES=True
		";
		push (@MarkDup,$marke_dup);
		push (@bam_list_dedup,$map/$name.gs.dedup.bam);
		push (@bam_list_keepdup,$map/$name.gs.bam);

	}
}


my $n_process=15;

## all shell saved;
# run shell command

##==========================================
#print "Trim started\n";
##==========================================
#
##&RUNSHELL($n_process,\@trim_shell);
#
#print "
#########################################
#		Triming finished
#########################################
#\n";
##==========================================
#print "Mapping started\n";
##==========================================

#print join "\n", @map_shell;
#&RUNSHELL(5, \@map_shell);

#print "
#########################################
#		Mapping finished
#########################################
#\n";
#exit;


##==========================================
#print "Addgroop started\n";
##==========================================

#print join "\n", @AddGroup;
#&RUNSHELL(10, \@AddGroup);

#print "
#########################################
#		AddGroup finished
#########################################
#\n";



##==========================================
#print "Marke Duplicate started\n";
##==========================================

#print join "\n", @MarkDup;
#&RUNSHELL(10, \@MarkDup);

#print "
#########################################
#		Mark Duplicate finished
#########################################
#\n";



##==========================================
#print "Merge BAM\n";
##==========================================
## Merge BAM file with Picard tools;
my $bam_list_input_keepdup=join " I=" @bam_list_keepdup;
my $bam_list_input_depdup=join " I=" @bam_list_dedup;
my $merge_bam_bin_keepdup="
 java -jar /home/likewise-open/ICE/sxu/soft-download/picard-tools-1.87/MergeSamFiles.jar $bam_list_input_keepdup  SO=coordinate AS=true VALIDATION_STRINGENCY=SILENT USE_THREADING=true O=Keepdup.merged.bam
";
my $merge_bam_bin_depdup="
java -jar /home/likewise-open/ICE/sxu/soft-download/picard-tools-1.87/MergeSamFiles.jar $bam_list_input_depdup  SO=coordinate AS=true VALIDATION_STRINGENCY=SILENT USE_THREADING=true O=Dedup.merged.bam
";

system ($merge_bam_bin_keepdup);
system ($merge_bam_bin_keepdup);

#print "
#########################################
#		Merge bam finished
#########################################
#\n";



##==========================================
#print "Index BAM\n";
##==========================================
## Index BAM file with SAM tools;
my $index="
samtools index Keepdup.merged.bam &
samtools index Depdup.merged.bam &
";


system ($index);

#print "
#########################################
#		Index bam finished
#########################################
#\n";


##==========================================
#print "Realign BAM\n";
##==========================================
## Realign indels with GATK tools;
my $realign_keepdup="
java -Xmx60g -jar /home/likewise-open/ICE/sxu/soft-download/GenomeAnalysisTK-2.4-9-g532efad/GenomeAnalysisTK.jar -T IndelRealigner -R /data/Genomes/NIATT/NIATT30_v6_RAD.fa -I Keepdup.merged.bam -LOD 3.0 -o Keepdup.merged.realigned.bam 
";
my $realign_dedup="
java -Xmx60g -jar /home/likewise-open/ICE/sxu/soft-download/GenomeAnalysisTK-2.4-9-g532efad/GenomeAnalysisTK.jar -T IndelRealigner -R /data/Genomes/NIATT/NIATT30_v6_RAD.fa -I  Depdup.merged.bam -LOD 3.0 -o Depdup.merged.realigned.bam 
";

system ($realign_keepdup);
system ($realign_depdup);

#print "
#########################################
#		realign bam finished
#########################################
#\n";



##==========================================
#print "Call SNP from BAM\n";
##==========================================
## Call SNP with GATK tools;
my $SNP_keepdup="
java -Xmx40g -jar /home/likewise-open/ICE/sxu/soft-download/GenomeAnalysisTK-2.4-9-g532efad/GenomeAnalysisTK.jar -T UnifiedGenotyper -R /data/Genomes/NIATT/NIATT30_v6_RAD.fa -I Keepdup.merged.realigned.bam -gt_mode DISCOVERY -stand_call_conf 30 -stand_emit_conf 10 -nct 8 -o var.raw.keepdup.vcf
";
my $SNP_dedup="
java -Xmx40g -jar /home/likewise-open/ICE/sxu/soft-download/GenomeAnalysisTK-2.4-9-g532efad/GenomeAnalysisTK.jar -T UnifiedGenotyper -R /data/Genomes/NIATT/NIATT30_v6_RAD.fa -I Dedup.merged.realigned.bam  -gt_mode DISCOVERY -stand_call_conf 30 -stand_emit_conf 10 -nct 8 -o var.raw.dedup.vcf
";

system ($realign_keepdup);
system ($realign_depdup);

#print "
#########################################
#		realign bam finished
#########################################
#\n";



##==========================================
#print "Annotate SNP \n";
##==========================================
## Annotate SNP with GATK tools;
my $SNP_annotate_keepdup="
java -Xmx40g -jar /home/likewise-open/ICE/sxu/soft-download/GenomeAnalysisTK-2.4-9-g532efad/GenomeAnalysisTK.jar -T VariantAnnotator -R /data/Genomes/NIATT/NIATT30_v6_RAD.fa -I Keepdup.merged.bam -G StandardAnnotation -V:variant,VCF var.raw.keepdup.vcf -XA SnpEff -o  var.raw.keepdup.annotated.vcf
";
my $SNP_annotate_dedup="
java -Xmx40g -jar /home/likewise-open/ICE/sxu/soft-download/GenomeAnalysisTK-2.4-9-g532efad/GenomeAnalysisTK.jar -T VariantAnnotator -R /data/Genomes/NIATT/NIATT30_v6_RAD.fa -I Dedup.merged.bam -G StandardAnnotation -V:variant,VCF var.raw.dedup.vcf -XA SnpEff -o  var.raw.dedup.annotated.vcf
";
system ($SNP_annotate_keepdup);
system ($SNP_annotate_dedup);


java -Xmx40g -jar /home/likewise-open/ICE/sxu/soft-download/GenomeAnalysisTK-2.4-9-g532efad/GenomeAnalysisTK.jar -T -T UnifiedGenotyper -R /data/Genomes/NIATT/NIATT30_v6_RAD.fa -I Dedup.merged.realigned.bam -gt_mode DISCOVERY -glm INDEL -stand_call_conf 30 -stand_emit_conf 10 -o var.raw.dedup.indel.vcf


#print "
#########################################
#		SNP Annotation  finished
#########################################
#\n";


##==========================================
#print "Filter SNP calls around indels \n";
##==========================================
## Filter INDEL with GATK tools;
my $SNP_filter_keepdup="
java -Xmx40g -jar /home/likewise-open/ICE/sxu/soft-download/GenomeAnalysisTK-2.4-9-g532efad/GenomeAnalysisTK.jar -T VariantFiltration -R /data/Genomes/NIATT/NIATT30_v6_RAD.fa -V var.raw.keepdup.annotated.vcf --mask /data/Genomes/RAD/MAP/Parental.indel.flt.vcf --maskExtension 5 --maskName InDel --clusterWindowSize 10 --filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" --filterName "BadValidation" --filterExpression "QUAL < 30.0" --filterName "LowQual" --filterExpression "QD < 5.0" --filterName "LowVQCBD"  -o var.raw.keepdup.annotated.flt.vcf
";
my $SNP_filter_dedup="
java -Xmx40g -jar /home/likewise-open/ICE/sxu/soft-download/GenomeAnalysisTK-2.4-9-g532efad/GenomeAnalysisTK.jar -T VariantFiltration -R /data/Genomes/NIATT/NIATT30_v6_RAD.fa -V var.raw.dedup.annotated.vcf --mask /data/Genomes/RAD/MAP/Parental.indel.flt.vcf --maskExtension 5 --maskName InDel --clusterWindowSize 10 --filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" --filterName "BadValidation" --filterExpression "QUAL < 30.0" --filterName "LowQual" --filterExpression "QD < 5.0" --filterName "LowVQCBD"  -o var.raw.dedup.annotated.flt.vcf
";

system ($SNP_filter_keepdup);
system ($SNP_filter_depdup);

#print "
#########################################
#		SNP filtering finished
#########################################
#\n";






















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
		print $shell,"\n";
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

## Use GATK
# Step 1, remove PCR duplicates;
# ls -l *.bam | awk '{print "java -jar ~/soft-download/picard-tools-1.87/MarkDuplicates.jar I=" $8 " O="$8".dedup M="$8".M AS=true MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000" }' |sh
# Step 2, give Groups to each BAM file;
# 
