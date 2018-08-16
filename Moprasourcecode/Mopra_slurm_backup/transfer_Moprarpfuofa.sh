#!/bin/bash

#This code is aimed to copy a file from a given region
regionname=$1 #256
echo $HOMEMOPRADATA
if [ ! -d  "${HOMEMOPRADATA}/${regionname}rpf" ] 
then
mkdir ${HOMEMOPRADATA}/${regionname}rpf;
fi

if [ ! -f "${regionname}.txt" ] 
then 
echo "Unable to find file ${regionname}.txt";
exit 0
fi


#Now we obtain all the files within that regions
FILELIST=($(cat ${regionname}.txt))

for file in "${FILELIST[@]}"
do

cp -uv //uofaresstor/mopra_cmz/rblackwell/RAWDATA/2017/${file} ${HOMEMOPRADATA}/${regionname}rpf/ 

done





 





