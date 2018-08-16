#!/bin/bash
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --time=15:00:00
#SBATCH --mem=500MB


#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=fabien.voisin@adelaide.edu.au
module load Miriad

# Executing script

srun -n 1 imcombfolder.sh ${folder} -600 300 20 1 0 
