#!/bin/bash
#SBATCH -p copy
#SBATCH -n 1
#SBATCH --time=00:30:00
#SBATCH --mem=10MB


#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=fabien.voisin@student.adelaide.edu.au


# Executing script

./transfer_Moprarpfuofa.sh ${region}
