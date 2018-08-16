#!/bin/sh

#SBATCH -p batch
#SBATCH -N 1 
#SBATCH -n 2
#SBATCH --time=00:10:00
#SBATCH --mem=6GB

#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=fabien.voisin@adelaide.edu.au

#Look for folder to go to 
cd ${HOMEMOPRADATA}/${folder}

# Note: rp2sdfits is a standard in the livedata package
#

for file in *.rpf; do
  echo "$file"
  rp2sdfits ./"$file" "./$(basename ${file} .rpf).sdfits"
done
#
###

