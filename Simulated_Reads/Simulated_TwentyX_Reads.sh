#!/bin/bash

#SBATCH --account=def-bourqueg
#SBATCH --time=:00:00
#SBATCH -N 1 -c 4
#SBATCH --mem-per-cpu=4000M
#SBATCH -J 20_simulate
#SBATCH -o 20x_simulate.out
#SBATCH -e 20x_simulate.err

ls | grep 20x | while read file;
do for i in {1,2};
do for j in $(seq 400000 400000 $(echo $(gunzip -c ${file}/simulated_${i}.clipped.fastq.gz | wc -l)+400000 | bc -l));
do gunzip -c ${file}/simulated_${i}.clipped.fastq.gz | tail -n +$((${j}-399999)) | head -400000 > ${file}/100000_${i}/$(echo "scale=0; ${j}/4" | bc -l).fastq;
done; done; done
