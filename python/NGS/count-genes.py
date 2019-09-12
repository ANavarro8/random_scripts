#! /usr/bin/env python
"""
Count the number of reads assigned to each gene in a bowtie mapping.
"""

import sys
mapfile = open(sys.argv[1])

# count 1 for each time a contig is mentioned in a mapping line
count_d = {}
for line in mapfile:
    contig_name = line.split('\t')[2]
    count_d[contig_name] = count_d.get(contig_name, 0) + 1

# output counts
for contig_name in count_d:
    print count_d[contig_name], contig_name