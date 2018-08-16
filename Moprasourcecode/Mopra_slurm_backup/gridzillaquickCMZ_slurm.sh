#!/bin/bash
#SBATCH -p batch
#SBATCH -N 3
#SBATCH -n 6
#SBATCH --ntasks-per-node=2
#SBATCH --time=16:30:00
#SBATCH --mem=5GB

#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=fabien.voisin@adelaide.edu.au


# Executing script

export RAWDATA=${HOMEMOPRADATA}

if [ ! -d ${RAWDATA}/${val2} ] 
then
mkdir ${RAWDATA}/${val2}
fi
TEMPFOLDER=$(basename ${val1} sdfits)temp
is_fits_quickprocessed.sh ${val1} ${val2} ${TEMPFOLDER}
mpirun -np 6 ./gridzillaquickCMZ ${TEMPFOLDER} ${val2} -600 400 20 
