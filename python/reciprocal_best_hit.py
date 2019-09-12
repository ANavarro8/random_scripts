#! /usr/bin/env python
"""
Extracts reciprocal blast hits from a blastp run 

Requires former blastp:
blastp -in infile -db dbfile -outfmt 6 
   for file in *.out;do cat $file >> all_species_A_species_B.out;done 

Sample usage: ::
python reciprocal_best_hit.py all_species_A_species_B.out all_species_B_species_A.out reciprocal_best_hits.out "-pident 30;-evalue 1e-3;-bitscore F" 

-pident X takes hits that are at least X% identical
-evalue Y takes hits with max. Y e-value
-bitscore F indicates that e-values should be taken as sort criterium

Author: K. Ullrich
"""

import sys

species_A_infile = sys.argv[1]

species_B_infile = sys.argv[2]

outfile = sys.argv[3]

options = sys.argv[4]

options = options.split(';')

option_pident = options[0].split(' ')[1]

option_pident = float(option_pident)

option_evalue = options[1].split(' ')[1]

option_evalue = float(option_evalue)

if options[2].split(' ')[1]=='F':
    option_bitscore = 0

if options[2].split(' ')[1]=='T':
    option_bitscore = 1

##species A
blast_species_A_dict={}
blast_species_A = open(species_A_infile,'r')
for line in blast_species_A:
    parts = line.strip().split('\t')
    qseqid,sseqid,pident,length,mismatch,gapopen,qstart,qend,sstart,send,evalue,bitscore = parts
    evalue = float(evalue)
    bitscore = float(bitscore)
    pident = float(pident)
    if option_bitscore == 0:
        to_evaluate = evalue
        if evalue<=option_evalue and pident>=option_pident and qseqid in blast_species_A_dict and blast_species_A_dict[qseqid][1]>to_evaluate:
            print qseqid
            print "%f is smaller than %f" % (to_evaluate,blast_species_A_dict[qseqid][1])
            blast_species_A_dict[qseqid]=[sseqid,to_evaluate]
        if evalue<=option_evalue and pident>=option_pident and qseqid not in blast_species_A_dict:
            blast_species_A_dict[qseqid]=[sseqid,to_evaluate]
    if option_bitscore == 1:
        to_evaluate = bitscore
        if evalue<=option_evalue and pident>=option_pident and qseqid in blast_species_A_dict and blast_species_A_dict[qseqid][1]<to_evaluate:
            print qseqid
            print "%f is higher than %f" % (to_evaluate,blast_species_A_dict[qseqid][1])
            blast_species_A_dict[qseqid]=[sseqid,to_evaluate]
        if evalue<=option_evalue and pident>=option_pident and qseqid not in blast_species_A_dict:
            blast_species_A_dict[qseqid]=[sseqid,to_evaluate]

##species B
blast_species_B_dict={}
blast_species_B = open(species_B_infile,'r')
for line in blast_species_B:
    parts = line.strip().split('\t')
    qseqid,sseqid,pident,length,mismatch,gapopen,qstart,qend,sstart,send,evalue,bitscore = parts
    evalue = float(evalue)
    bitscore = float(bitscore)
    pident = float(pident)
    if option_bitscore == 0:
        to_evaluate = evalue
        if evalue<=option_evalue and pident>=option_pident and qseqid in blast_species_B_dict and blast_species_B_dict[qseqid][1]>to_evaluate:
            print qseqid
            print "%f is smaller than %f" % (to_evaluate,blast_species_B_dict[qseqid][1])
            blast_species_B_dict[qseqid]=[sseqid,to_evaluate]
        if evalue<=option_evalue and pident>=option_pident and qseqid not in blast_species_B_dict:
            blast_species_B_dict[qseqid]=[sseqid,to_evaluate]
    if option_bitscore == 1:
        to_evaluate = bitscore
        if evalue<=option_evalue and pident>=option_pident and qseqid in blast_species_B_dict and blast_species_B_dict[qseqid][1]<to_evaluate:
            print qseqid
            print "%f is higher than %f" % (to_evaluate,blast_species_B_dict[qseqid][1])
            blast_species_B_dict[qseqid]=[sseqid,to_evaluate]
        if evalue<=option_evalue and pident>=option_pident and qseqid not in blast_species_B_dict:
            blast_species_B_dict[qseqid]=[sseqid,to_evaluate]

reciprocal_besthit_pairs=[]
for aquery in blast_species_A_dict:
    #print aquery
    blast_species_A_query=aquery
    blast_species_A_besthit=blast_species_A_dict[blast_species_A_query][0]
    blast_species_A_evalue=blast_species_A_dict[blast_species_A_query][1]
    blast_species_B_query=blast_species_A_besthit
    if blast_species_B_query not in blast_species_B_dict:
        print "%s not in dictionary" % (blast_species_B_query)
    if blast_species_B_query in blast_species_B_dict:
        blast_species_B_besthit=blast_species_B_dict[blast_species_B_query][0]
        blast_species_B_evalue=blast_species_B_dict[blast_species_B_query][1]
        if blast_species_B_besthit==blast_species_A_query:
            reciprocal_besthit_pairs.append([blast_species_A_query,blast_species_A_besthit,blast_species_A_evalue,blast_species_B_evalue])

with open(outfile,'w') as handle:
	for record in reciprocal_besthit_pairs:
		handle.write("%s\t%s\t%s\t%s\n" % (record[0],record[1],record[2],record[3]))