#! /usr/bin/env python
"""
Adjust counts to RKPM, reads-per-thousand-bases-of-mRNA.
"""
import sys
import screed

sequence_database = sys.argv[1]
counts_file = sys.argv[2]

seqdb = screed.ScreedDB(sequence_database)

for line in open(counts_file):
    count, name = line.strip().split()  # parse lines like '1523 geneX'
    count = int(count)

    # look up the sequence in the seqdb dictionary-like database.
    sequence_length = len(seqdb[name].sequence)

    # calculate the appropriate divisor
    div = float(sequence_length) / 1000.

    # divide!
    print float(count) / div, name