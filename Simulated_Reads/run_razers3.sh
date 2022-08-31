#!/bin/bash

#SBATCH --account=def-bourqueg
#SBATCH --time=72:00:00
#SBATCH -N 1 -c 32
#SBATCH --mem-per-cpu=4000M
#SBATCH -J razres3_map
#SBATCH -o razers3_map.out
#SBATCH -e razers3_map.err

module load mugqic_dev/razers3
ls | grep 20x | while read file; do parallel -j 30 --noswap --nice 10 < ${file}/razers3.txt; done
