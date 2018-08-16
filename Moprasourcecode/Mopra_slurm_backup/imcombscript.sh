#!/bin/sh

####This script look for all the input and merge into a final file with the miriad task IMCOMB

declare -i count
initialfile=$1
initialvelocity=$2
finalvelocity=$3
stepvelocity=$4
core_id=$5
final=$6 #Depends whether the job is a full CO (1) map or a quicklook data analysis (0)
rm -rf op_${core_id}_*
rm -rf comfolder_${core_id}*
vel1=${initialvelocity}
vel2=$(echo "${initialvelocity}+ ${stepvelocity}" | bc -l)

echo ${vel1} ${vel2}
rootfile=$(basename ${initialfile} _${vel1}_${vel2}_IF7_MEDIAN.fits)
echo ${rootfile}
count=1
currentfile=${rootfile}_${vel1}_${vel2}_IF7_MEDIAN.fits
miriadoptionstring=""
while [ "${vel2}" -le "${finalvelocity}" ]
do


tmpfile=$(basename ${currentfile} .fits )
if [ -f ${tmpfile}_001.fits ]
then 
stitchpassfile.sh ${tmpfile}_001.fits
fi

echo ${currentfile}
fits in=${currentfile} out=op_${core_id}_${final}_${count} op=xyin
miriadoptionstring=$(echo "${miriadoptionstring}op_${core_id}_${final}_${count},")
count=$((count+1))
vel1=${vel2}
vel2=$(echo "${vel2} + ${stepvelocity}" | bc -l)
currentfile=${rootfile}_${vel1}_${vel2}_IF7_MEDIAN.fits
done
miriadoptionstring2=$(basename ${miriadoptionstring} ,)
imcomb in=${miriadoptionstring2} out=comfolder_${core_id}_${final}
fits in=comfolder_${core_id}_${final} out=${rootfile}_${initialvelocity}_${finalvelocity}_final_IF7_MEDIAN.fits op=xyout

