#!/bin/bash
#SBATCH -p batch
#SBATCH -N 15
#SBATCH -n 15
#SBATCH --ntasks-per-node=1
#SBATCH --time=6:00:00
#SBATCH --mem=3GB
#SBATCH --gres=tmpfs:100GB

#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=fabien.voisin@adelaide.edu.au


# Executing script

export RAWDATA=${TMPDIR}
mkdir ${TMPDIR}/${val1}
mkdir ${TMPDIR}/${val2}

cp -r ${HOMEMOPRADATA}/${val1} ${TMPDIR}/${val1}


mpirun -np 15 ./livedataparallel_CMZ ${val1} ${val2} 2

cp -r ${TMPDIR}/${val2} ${HOMEMOPRADATA}/${val2}
