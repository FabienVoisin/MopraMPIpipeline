#!/bin/bash
#SBATCH -p batch
#SBATCH -N 3
#SBATCH -n 6
#SBATCH --time=8:00:00
#SBATCH --mem=1200MB
#SBATCH --gres=tmpfs:150GB


#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=fabien.voisin@adelaide.edu.au


# Executing script
export RAWDATA=${TMPDIR}
mkdir ${TMPDIR}/${val1}
mkdir ${TMPDIR}/${val2}

is_sdfits_processed ${val1} ${TMPDIR}/${val1}  

mpirun -np 6 ./livedataquickCO ${val1} ${val2} 1

cp  ${TMPDIR}/${val2}/* ${HOMEMOPRADATA}/${val2}
