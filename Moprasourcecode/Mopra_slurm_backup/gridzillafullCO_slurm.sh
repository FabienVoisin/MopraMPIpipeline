#!/bin/bash
#SBATCH -p batch
#SBATCH -N 2
#SBATCH -n 6
#SBATCH --ntasks-per-node=3
#SBATCH --time=10:00:00
#SBATCH --mem=4GB

#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=fabien.voisin@adelaide.edu.au


# Executing script
export RAWDATA=${HOMEMOPRADATA}

if [ ! -d ${RAWDATA}/${val2} ] 
then
mkdir ${RAWDATA}/${val2}
fi
mpirun -np 6 ./gridzillaparallelCO ${val1} ${val2} -600 600 20 1 ${val3} ${val4}
${longitude} ${latitude}
