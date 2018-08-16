#!/bin/bash
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --time=30:00:00
#SBATCH --mem=10GB


#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=fabien.voisin@adelaide.edu.au

# Executing script

srun -n 1 averagedspectrumfolder.sh ${folder}
