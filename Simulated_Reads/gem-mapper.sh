#!/bin/bash

#do for i in {1,5,20};
cmd="""#!/bin/bash
	module purge && \
	module load mugqic_dev/gem3-mapper/Master20200925 && \
	gem-mapper -l 0 -L 500 -t 16 --bisulfite-read inferred --underconversion_sequence lambda --overconversion_sequence pUC19 -I $MUGQIC_INSTALL_HOME_DEV/genomes/species/Homo_sapiens.GRCh38/genome/bisulfite/gem3-mapper_index_cpu/Homo_sapiens.GRCh38.gem -1 5x/bisulfite/simulated_1.fastq.bs.fastq -2 5x/bisulfite/simulated_2.fastq.bs.fastq -o ./mapping/1x/gem-mapper/simulated.gem-mapper.bam"""
	echo "$cmd" | sbatch --account=def-bourqueg --time=06:00:00 -N 1 -c 16 --mem-per-cpu=3900M -J simulated_gem-mapper -o simulated-gem-mapper.out -e simulated-gem-mapper.err
#done
