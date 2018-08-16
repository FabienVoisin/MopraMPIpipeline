#!/bin/sh

##### This script recursively catzilla the file of a given file. It needs 4 arguments

initialfile=$1
initialvelocity=$2
finalvelocity=$3
stepvelocity=$4


vel1=${initialvelocity}
vel2=$(echo "${initialvelocity}+ ${stepvelocity}" | bc -l)
vel3=$(echo "${vel2}+ ${stepvelocity}" | bc -l)

rootfile=$(basename ${initalfile} _${vel1}_${vel2}_MEDIAN.fits)

while [ "${vel3}" .le. "100" ]
do
catzilla ${initialfile} ${rootfile}_${vel2}_${vel3}_MEDIAN.fits
vel2=${vel3}
vel3=vel3=$(echo "${vel3}+ ${stepvelocity}" | bc -l)
done
