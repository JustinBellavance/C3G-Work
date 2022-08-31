#!/bin/bash

#do for i in {1,5,20};
cmd="""#!/bin/bash
	module purge && \
	module load mugqic_dev/MethylDackel && \
	MethylDackel extract -@ 8 Homo_sapiens.GRCh38.fa mapping/1x/gem-mapper_alt/simulated.gem-mapper.pre-converted3.sorted.dedup.bam"""
	echo "$cmd" | sbatch --account=def-bourqueg --time=04:00:00 -N 1 -c 16 --mem-per-cpu=3900M -J methyldackel-gem-mapper -o methyldackel-gem-mapper.out -e methyldackel-gem-mapper.err
#done
