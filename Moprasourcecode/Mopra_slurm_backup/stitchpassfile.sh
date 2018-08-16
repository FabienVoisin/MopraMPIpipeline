#!/bin/bash

initialfile=$1
final=$2
# The idea here is to stitch up the passes if required as it is necessary to combine them in the right order, the initial file must be a _001.fits file for the program to work
initialroot=$(basename ${initialfile} "_001.fits" )
rm -rf ol_${final}_* total_${final}

list_of_passes=( $(ls ${initialroot}_*.fits) )
TOTALSTRING=''
for (( i=0 ; i< ${#list_of_passes[@]} ; i++ ))
do 
fits in=${list_of_passes[i]} out=ol_${final}_${i} op=xyin
TOTALSTRING="${TOTALSTRING}ol_${final}_${i},"
done
TOTALSTRING=$(basename ${TOTALSTRING} ,)
imcomb in=${TOTALSTRING} out=total_${final} 
fits in=total_${final} out=${initialroot}.fits op=xyout
  

