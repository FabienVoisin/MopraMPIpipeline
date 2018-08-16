#!/bin/bash
#SBATCH -p batch
#SBATCH -N 2
#SBATCH -n 16
#SBATCH --ntasks-per-node=8
#SBATCH --time=3:00:00
#SBATCH --mem=4GB

#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=fabien.voisin@adelaide.edu.au


# Executing script
mpirun -np 16 ./gridzillaquick7mm SdfitJ1809 J1809 -50 100 10 2
