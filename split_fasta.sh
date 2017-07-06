#!/bin/bash
#Split fasta.gz files for preprocessing
gunzip *.fastq.gz

#rename the files for structured processing
COUNTER=1
for file in *.fastq; do
     mv $file my_unzipped_reads${COUNTER}.fastq
     let COUNTER=COUNTER+1
done
