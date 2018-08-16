#!/bin/bash

infilefolder=$1
outfilefolder=$2
tempdir=$3
 
cd ${HOMEMOPRADATA}/${infilefolder}
pwd
infiles=($(ls *.rpf))

for file in "${infiles[@]}"
do
    rootname=$(basename ${file} .rpf)
    outputfilename=${HOMEMOPRADATA}/${outfilefolder}/${rootname}-IF7.sdfits
    if [ "$(ls ${HOMEMOPRADATA}/${outfilefolder}/${rootname}*IF7.sdfits)" ]
	then 
	echo "${outputfilename} exists, no need to reprocess the file"
	else 
	cp -v ${HOMEMOPRADATA}/${infilefolder}/${file} ${tempdir}
    fi
    
done
