#!/bin/bash
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 5
#SBATCH --time=2:00:00
#SBATCH --mem=2GB

#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=fabien.voisin@student.adelaide.edu.au


# Executing script
echo ${SLURM_PROCID}
./imcombfolder.sh ${FOLDER} ${initialvelocity} ${finalvelocity} ${stepvelocity} ${SLURM_PROCID}
