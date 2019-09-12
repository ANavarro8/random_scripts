#! /usr/bin/env python
import sys
import csv

in_file = sys.argv[1]                   # input file: first argument

# output in csv format
output = csv.writer(sys.stdout)

# for all lines of csv input, load them in, filter, and output.
for (query_name, subject_name, score, expect) in csv.reader(open(in_file)):
    # filter HERE.
    if float(expect) < 1e-3:            # e.g. keep only good matches
        row = [query_name, subject_name, score, expect]
        output.writerow(row)