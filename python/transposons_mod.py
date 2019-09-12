#!/usr/bin/python3

##### Program description #######
#
# Title:     transposon.py
# Author(s): Thomas Brockmoeller
# Description:
#   finds the next transposon to a geneID
#
# Example:
#
##################################

import sys
import os
import re

#unique
geneListFile1 = sys.argv[1]
#singletons
geneListFile2 = sys.argv[2]
newFile = sys.argv[3]

transposonCutoff = 20000
scaffoldCutoff = 20000

# only LTR Types (by AURA)
transposonTypes = ['LTR', 'LTR/Copia', 'LTR/Gypsy', 'LINE/L1', 'LINE/L2', 'LINE/RTE-BovB', 'SINE', 'SINE/ID', 'SINE/tRNA', 'SINE/tRNA-Glu', 'SINE/tRNA-RTE', 'SINE?'] 

# all Transposon Types (by AURA)
#transposonTypes = ['DNA', 'DNA/CMC-EnSpm', 'DNA/En-Spm', 'DNA/Harbinger', 'DNA/hAT', 'DNA/hAT-Ac', 'DNA/hAT-Tag1', 'DNA/hAT-Tip100', 'DNA/MuDR', 'DNA/MULE-MuDR', 'DNA/P', 'DNA/PIF-Harbinger', 'DNA/TcMar-Stowaway', 'DNA/TcMar-Tc4', 'LINE/L1', 'LINE/L2', 'LINE/RTE-BovB', 'LTR', 'LTR/Copia', 'LTR/Gypsy', 'RC/Helitron', 'SINE', 'SINE/ID', 'SINE/tRNA', 'SINE/tRNA-Glu', 'SINE/tRNA-RTE', 'SINE?', 'Unknown']

transposonFile = '~/database/Nobtusifolia/NIOBT.version3.fa.out_ed'
gffFile = '/data4/Genomes/NIOBT5/NIATT_combined_annotation.final.function.aa.solar.genewise.gff'
scaffoldFastaFile = '/data/Genomes/NIOBT/NIOBT_V3/NIOBT.version3.fa'



############# READ GENELIST FILE #############
print('READ GENELIST FILE')

geneList1 = set([])

f = open(geneListFile1, 'r')
for line in f:
  geneList1.add(line.strip().split('.')[0])
f.close()

############# READ GENELIST FILE #############
print('READ GENELIST FILE')

geneList2 = set([])

f = open(geneListFile2, 'r')
for line in f:
  geneList2.add(line.strip().split('.')[0])
f.close()

############# READ SCAFFOLD FILE #############
print('READ SCAFFOLD FILE')

scaffolds = {}
name = ''
seq = ''

f = open(scaffoldFastaFile, 'r')
for line in f:
  if line[0] == '>':
    scaffolds[name] = len(seq)
    seq = ''
    tmp = line.strip().split()[0]
    name = tmp[1:]
    name = "scaffold%06d" % int(name[8:])
  else:
    seq += line.strip()
scaffolds[name] = len(seq)
f. close() 

############# READ GFF FILE #############
print('READ GFF FILE')

geneCoordinates = {}

f = open(gffFile, 'r')
for line in f:
  values = line.strip().split('\t')
  
  if values[2] == 'mRNA':
    chromosom = values[0]
    [start, end] = sorted([int(values[3]), int(values[4])])
    
    matchObj = re.finditer('Parent=(.*?);', values[8])
    for m in matchObj:
      gene = m.group(1)
      
      if gene in geneCoordinates:
        print("WARNING")
      else:
        geneCoordinates[gene] = {'chr': chromosom, 'start': start, 'end': end}
f.close()


############# PREDICT SCAFFOLD ENDS #############
print('PREDICT SCAFFOLD ENDS')

geneScaffolds = {}

for gene in sorted(geneCoordinates):
  chromosom = geneCoordinates[gene]['chr']
  start = geneCoordinates[gene]['start']
  end = geneCoordinates[gene]['end']
  
  geneScaffolds[gene] = {}
  if start < scaffoldCutoff:
    geneScaffolds[gene]['Before'] = start
  else:
    geneScaffolds[gene]['Before'] = 'NA'
    
  if scaffolds[chromosom] - end < scaffoldCutoff:
    geneScaffolds[gene]['After'] = scaffolds[chromosom] - end
  else:
    geneScaffolds[gene]['After'] = 'NA'
    
  
  
  #geneScaffolds[gene] = {'Before': start, 'After': scaffolds[chromosom] - end}


############# READ TRANSPOSON FILE #############
print('READ TRANSPOSON FILE')

transposons = {}

f = open(transposonFile, 'r')
next(f, None)
next(f, None)
next(f, None)
for line in f:
  values = line.strip().split()
  
  chromosom = values[4]
  start = int(values[5])
  end = int(values[6])
  transposonType = values[10]
  
  if chromosom in transposons:
    if start in transposons[chromosom]:
      if end in transposons[chromosom][start]:
        if not transposonType in transposons[chromosom][start][end]:
          transposons[chromosom][start][end].append(transposonType)
      else:
        transposons[chromosom][start][end] = [transposonType]
    else:
      transposons[chromosom][start] = {end: [transposonType]}
  else:
    transposons[chromosom] = {start: {end: [transposonType]}}
f.close()


############# FIND TRANSPOSONS #############
print('FIND TRANSPOSONS')

foundedAfter = set([])
foundedBefore = set([])

geneTransposons = {}

for gene in sorted(geneCoordinates):
  chromosom = geneCoordinates[gene]['chr']
  start = geneCoordinates[gene]['start']
  end = geneCoordinates[gene]['end']
  
  if chromosom in transposons:
    chrTrans = chromosom
    for startTrans in sorted(transposons[chrTrans]):
      for endTrans in sorted(transposons[chrTrans][startTrans]):
        for typeTrans in sorted(transposons[chrTrans][startTrans][endTrans]):
          if typeTrans in transposonTypes:
      
            if (startTrans>=end and (startTrans - end) <= transposonCutoff):
            
              if gene in geneTransposons:
                if 'After' in geneTransposons[gene]:
                  if geneTransposons[gene]['After'] > startTrans - end:
                    geneTransposons[gene]['After'] = startTrans - end
                else:
                  geneTransposons[gene]['After'] = startTrans - end
                  
              else:
                geneTransposons[gene] = {'After': startTrans - end}
            
              #if not gene in foundedAfter:
              #  foundedAfter.add(gene)
        
            if (endTrans<=start and (start - endTrans) <= transposonCutoff):
              if gene in geneTransposons:
                if 'Before' in geneTransposons[gene]:
                  if geneTransposons[gene]['Before'] > start - endTrans:
                    geneTransposons[gene]['Before'] = start - endTrans
                else:
                  geneTransposons[gene]['Before'] = start - endTrans
                  
              else:
                geneTransposons[gene] = {'Before': start - endTrans}
            
            
            
            
              #if not gene in foundedBefore:
              #  foundedBefore.add(gene)
  
############# WRITE NEW FILE #############
print('WRITE NEW FILE')


f = open(newFile, 'w')
f.write('geneType\tgeneID\tscaffoldBefore\tscaffoldAfter\ttransposonBefore\ttransposonAfter\n')
for gene in sorted(geneCoordinates):
  chromosom = geneCoordinates[gene]['chr']

  if gene in geneList1:
    f.write('unique\t')
  elif gene in geneList2:
    f.write('singletons\t')
  else:
    f.write('control\t')
  
  f.write(gene + '\t')
  
  if gene in geneScaffolds:
    f.write(str(geneScaffolds[gene]['Before']) + '\t' + str(geneScaffolds[gene]['After']) + '\t')
  else:
    print('WARNING: scaffolds : ' + gene) 
  
  if gene in geneTransposons:
    if 'Before' in geneTransposons[gene]:
      f.write(str(geneTransposons[gene]['Before']))
    else:
      f.write('NA')
    f.write('\t')
    
    if 'After' in geneTransposons[gene]:
      f.write(str(geneTransposons[gene]['After']))
    else:
      f.write('NA')
  else:
    f.write('NA\tNA')
  f.write('\n')
f.close()


#print('After:')
#print(len(foundedAfter))

#print('Before:')
#print(len(foundedBefore))




