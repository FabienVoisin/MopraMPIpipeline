#!/bin/bash
#SBATCH -p batch
#SBATCH -N 6
#SBATCH -n 12
#SBATCH --ntasks-per-node=2
#SBATCH --time=6:00:00
#SBATCH --mem=6GB


#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=fabien.voisin@student.adelaide.edu.au


# Executing script
module swap OpenMPI/1.10.3-GCC-5.4.0-2.26

export RAWDATA=${HOMEMOPRADATA}

if [ ! -d ${RAWDATA}/${val2} ] 
then
mkdir ${RAWDATA}/${val2}
fi

mpirun -np 12 ./livedataquickCMZ ${val1} ${val2} 1

