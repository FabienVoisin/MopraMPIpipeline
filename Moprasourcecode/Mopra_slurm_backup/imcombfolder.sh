#!/bin/sh

####Perform the combination script over an entire folder
FOLDER=$1
initialvelocity=$2
finalvelocity=$3
stepvelocity=$4
nextvelocity=$(echo "${initialvelocity}+ ${stepvelocity}" | bc -l)
core_id=$5
final=$6
echo ${nextvelocity}
echo ${HOMEMOPRADATA}
cd ${HOMEMOPRADATA}/${FOLDER}
pwd
FILELIST=($(ls *${initialvelocity}_${nextvelocity}*IF7*MEDIAN.fits))
echo ${initialvelocity} ${finalvelocity} ${stepvelocity}
for file in ${FILELIST[@]}
do
echo ${file}
imcombscript.sh ${file} ${initialvelocity} ${finalvelocity} ${stepvelocity} ${core_id} ${final}
done
 
