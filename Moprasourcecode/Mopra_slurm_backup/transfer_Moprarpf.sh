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
count=0
COPYLIST=''
ssh -fN -l voi00a -L 2222:kaputar.atnf.csiro.au:22 orion.atnf.csiro.au 

for file in "${FILELIST[@]}"
do


CURRENTFULLFILEPATH=$(echo "/data/ARCHIVE_1/Mopra/${file}")
COPYLIST=$(echo ${COPYLIST} ${CURRENTFULLFILEPATH}) 

count=$((count + 1 ))
if [ ${count} -eq 10 ] ; then
count=0
echo rsync -au --progress --rsh="ssh -p2222 -o StrictHostKeyChecking=no" "voi00a@localhost:${COPYLIST}" ${HOMEMOPRADATA}/${regionname}rpf 
rsync -au --progress --rsh="ssh -p2222 -o StrictHostKeyChecking=no" "voi00a@localhost:${COPYLIST}" ${HOMEMOPRADATA}/${regionname}rpf 
COPYLIST=''
fi



done

rsync -au --progress --rsh="ssh -p2222 -o StrictHostKeyChecking=no" "voi00a@localhost:${COPYLIST}" ${HOMEMOPRADATA}/${regionname}rpf 



 

CONNECTIONNUMBER=$(ps -aux | grep "ssh -fN" | awk  'NR==1{print $2}')

echo ${CONNECTIONNUMBER}
kill ${CONNECTIONNUMBER}  




