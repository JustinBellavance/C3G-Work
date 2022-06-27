#!/bin/bash

#do for i in {1,5,20};
cmd="""#!/bin/bash
	module purge && \
	module load mugqic_dev/gem3-mapper/Master20200925 && \
	gem-mapper  -l 250 -L 750 -t 8 -I $MUGQIC_INSTALL_HOME_DEV/genomes/species/Homo_sapiens.GRCh38/genome/bisulfite/gem3-mapper_index_cpu/Homo_sapiens.GRCh38.gem -1 1x/bisulfite/simulated_1.fastq -2 1x/bisulfite/simulated_2.fastq -o ./mapping/Gem3/simulated.gem-mapper.sam"""
	echo "$cmd" | sbatch --account=def-bourqueg --time=24:00:00 -N 1 -c 8 --mem-per-cpu=3900M -J simulated_gem3 -o simulated_gem3.out -e simulated.gem3.err
#done
