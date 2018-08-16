#!/bin/bash

infile=$1
folder=$(basename ${infile} .txt)rpf
echo ${folder}
#This script check whether the file in the text has been downloaded successfully and will prinr whether there are files missing*/

list_of_files=($(cat ${infile}))

for (( i=0 ; i<${#list_of_files[@]} ; i++))
do 
    if [ ! -f ${HOMEMOPRADATA}/${folder}/${list_of_files[i]} ]
    then 
	echo "the file ${list_of_files[i]} needs to be downloaded"
    fi
done
