#!/bin/bash
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 6
#SBATCH --time=10:00:00
#SBATCH --mem=1200MB
#SBATCH --gres=tmpfs:220GB


#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=fabien.voisin@adelaide.edu.au



# Executing script


export RAWDATA=${TMPDIR}
mkdir ${TMPDIR}/${val1}
mkdir ${TMPDIR}/${val2}

is_sdfits_quickprocessed.sh ${val1} ${val2} ${TMPDIR}/${val1}   


mpirun -np 6 ./livedataquickCMZ ${val1} ${val2} 1

cp -r  ${TMPDIR}/${val2}/* ${HOMEMOPRADATA}/${val2}
