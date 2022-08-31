#!/bin/bash

#do for i in {1,5,20};
cmd="""#!/bin/bash
	module purge && \
	module load mugqic/bismark mugqic/bowtie2 mugqic/samtools && \
	bismark  -I 0 -X 500 --bowtie2 -p 4 --genome_folder $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh38/genome/bismark_index -1 5x/bisulfite/simulated_1.fastq.bs.fastq -2 5x/bisulfite/simulated_2.fastq.bs.fastq -o ./mapping/5x/bismark/"""
	echo "$cmd" | sbatch --account=def-bourqueg --time=60:00:00 -N 1 -c 16 --mem-per-cpu=3900M -J simulated_bismark -o simulated_bismark.out -e simulated_bismark.err
#done
