#!/bin/bash
#Set number of CPUs you want to spend
NUMBER_OF_CPUS=15

#FILE that should be BLATed goes as first parameter to the script
#The reference file goes as second parameter to the script
FILE_TO_BLAT=$1
REFERENCE=$2

#Rest of the script sets variables automatically

#Number of lines per split is being calculated here
NUMBER=`wc -l $FILE_TO_BLAT | cut -f1 -d" "`
let NUMBER=$NUMBER/$NUMBER_OF_CPUS

#if the number is odd, add 1, so that the split is not between header and sequence
if [ $(($NUMBER % 2)) -eq 1 ]; then
	let NUMBER=$NUMBER+1
fi

#Starting the actual split
echo "starting split: "`date`
echo "Number:	$NUMBER"
split -d -a3 -l $NUMBER $FILE_TO_BLAT ${FILE_TO_BLAT}_split

#starting BLAT
echo "starting BLAT: "`date`
for file in ${FILE_TO_BLAT}_split*
do
	blat $REFERENCE $file -q=dnax -t=dnax ${file}.psl &
done
wait

#after waiting for BLATs to finish, merge the result
echo "start merging: "`date`
cat ${FILE_TO_BLAT}_split*.psl > ${FILE_TO_BLAT}.psl

#finally clean up the folder
rm ${FILE_TO_BLAT}_split*
echo "done: "`date`


