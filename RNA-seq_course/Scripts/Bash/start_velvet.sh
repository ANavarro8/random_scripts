#!/bin/bash

#Bash to output Oases To sequentially start the assembly programs unsupervised

touch time.log
echo ‘start of velveth: ‘`date` >>time.log
velveth asm_sample001 25 -fasta ~/Sample001/Sample001_final.fasta >>velvet.log 2>>velvet.err
echo ‘start of velvetg: ‘`date` >>time.log
velvetg asm_sample001 -read_trkg yes >>velvet.log 2>>velvet.err
echo ‘start of oases: ‘`date` >>time.log
../oases-0.2.06/oases asm_sample001 >>velvet.log 2>>velvet.err
echo ‘finished assembly: ‘`date` >>time.log
#End of file