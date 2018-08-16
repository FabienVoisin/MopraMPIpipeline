#!/bin/bash

FITSFOLDER=$1

FILELIST=($(ls ${HOMEMOPRADATA}/${FITSFOLDER}/*final*moment*.fits))

for FILE in ${FILELIST[@]}
do 
rootfile=$(basename ${FILE} .fits)
ds9 ${FILE} -zoom to fit -scale mode 95 -print destination file -print filename ${HOMEMOPRADATA}/${FITSFOLDER}/${rootfile}.ps -print -quit  
done 
