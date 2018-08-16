#!/bin/bash
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --time=0:01:00
#SBATCH --mem=15MB



CURRENTDIR=$(pwd)

echo ${CURRENTDIR}
