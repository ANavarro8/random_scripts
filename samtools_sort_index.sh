#!/bin/bash

sample=$1
describer=$(echo ${sample} | sed 's/.bam//')  
   
# Sort BAM file  
#samtools sort ${describer}.bam ${describer}.out   
   
# index the bam file  
samtools index ${describer}.bam  
   
# Revove intermediate files  
#rm ${describer}.uns.bam  

#command line is ls *.bam | parallel -j4 -k bash samtools_index.sh