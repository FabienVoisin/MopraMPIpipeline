#!/bin/bash


infilefolder=$1
outfilefolder=$2
sdfitstempdir=$3
rm -rf ${HOMEMOPRADATA}/${sdfitstempdir}
mkdir ${HOMEMOPRADATA}/${sdfitstempdir}
cd ${HOMEMOPRADATA}/${infilefolder}
pwd
infiles=($(ls *IF7.sdfits))

for file in "${infiles[@]}"
do
    rootname=$(basename ${file} -IF7.sdfits)
   
    if [ "$(ls ${HOMEMOPRADATA}/${outfilefolder}/${rootname}*IF7*.fits)" ]
	then 
	echo " ${file} has already been processed"
	else 
	cp -v ${HOMEMOPRADATA}/${infilefolder}/${rootname}*.sdfits ${HOMEMOPRADATA}/${sdfitstempdir}
    fi
    
done
