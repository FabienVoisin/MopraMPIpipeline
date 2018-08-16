#!/bin/bash

FOLDER=$1

cd ${HOMEMOPRADATA}/${FOLDER}

FILELIST=($(ls *_final_*MEDIAN.fits))

for FILE in ${FILELIST[@]}
do
echo ${FILE}
writeaveragespectrum ${FILE}
done
