#!/bin/bash

#The aim of this script is to launch all the jobs to quickly reduce some date 

RPFFOLDER=$1

LONGITUDE=$2

LATITUDE=$3

SDFITSFOLDER="$(basename ${RPFFOLDER} rpf)sdfits"

FITSFOLDER="$(basename ${RPFFOLDER} rpf)fits"

FINALFILEPREFIX="$(basename ${RPFFOLDER} rpf)final"

echo ${RPFFOLDER} ${SDFITSFOLDER} ${FITSFOLDER} ${FINALFILEPREFIX}

#Now let 's launch quicklivedata

LIVEDATAJOBID=( $(sbatch --export=ALL,val1=${RPFFOLDER},val2=${SDFITSFOLDER} livedataquickCMZ_slurm.sh) )



echo ${LIVEDATAJOBID[3]}
sleep 5

# From there we launch gridzilla
QUICKGRIDZILLAJOBID=( $(sbatch --dependency=afterok:${LIVEDATAJOBID[3]} --export=ALL,val1=${SDFITSFOLDER},val2=${FITSFOLDER} gridzillaquickCMZ_slurm.sh) )

echo ${QUICKGRIDZILLAJOBID[3]}

FULLCOGRIDZILLAJOBID=( $(sbatch --dependency=afterok:${LIVEDATAJOBID[3]} --export=ALL,val1=${SDFITSFOLDER},val2=${FITSFOLDER},val3=1,val4=${FINALFILEPREFIX},longitude=${LONGITUDE},latitude=${LATITUDE} gridzillafullCMZ_slurm.sh ) )

echo ${FULLCOGRIDZILLAJOBID[3]}

sleep 5

#Now for each gridzilla, we launch the imcomb slurm script #

IMCOMBINDIVIDUALJOBID=( $(sbatch --dependency=afterok:${QUICKGRIDZILLAJOBID[3]} --export=ALL,folder=${FITSFOLDER} imcomb_slurm.sh) )

echo ${IMCOMBINDIVIDUALJOBID[3]}

IMCOMBTOTALJOBID=( $(sbatch --dependency=afterok:${FULLCOGRIDZILLAJOBID[3]} --export=ALL,folder=${FITSFOLDER},initialfile=${FINALFILEPREFIX}_raw_CO1-0_-600_-580_IF7_MEDIAN.fits imcombscript_slurm.sh) )

echo ${IMCOMBTOTALJOBID[3]}

sleep 5

#Finally after each job is completed you can obtain the averaged spectrum towards each file

AVERAGESPECTRUMJOBID=( $(sbatch --dependency=afterok:${IMCOMBINDIVIDUALJOBID[3]}:${IMCOMBTOTALJOBID[3]} --export=ALL,folder=${FITSFOLDER} averagedspectrumfolder_slurm.sh) )
