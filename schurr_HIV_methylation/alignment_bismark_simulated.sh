#!/bin/bash

#bismark simulated
cmd="""#!/bin/bash
  module purge && \
  module load mugqic/bismark mugqic/samtools mugqic/bowtie2 &&\
  mkdir -p alignment_bismark_simulated/ && \
  bismark -q -N 0 -L 20 -p 2 $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh38/genome/bismark_index -1 ~/scratch/large_paired/simulated_1.fastq -2 ~/scratch/large_paired/simulated_2.fastq"""
#echo "$cmd"
echo "$cmd" | sbatch --account=def-bourqueg --time=48:00:00 -N 1 -c 32 --mem-per-cpu=3900M -J simulated_bismark -o alignment_bismark_simulated/simulated_bismark.out -e alignment_bismark_simulated/simulated_bismark.err | grep "[0-9]"
