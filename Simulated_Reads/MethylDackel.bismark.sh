#!/bin/bash

#do for i in {1,5,20};
cmd="""#!/bin/bash
	module purge && \
	module load mugqic_dev/MethylDackel && \
	MethylDackel extract -@ 8 Homo_sapiens.GRCh38.fa mapping/1x/bismark_alt/simulated.bismark.sorted.dedup.bam"""
	echo "$cmd" | sbatch --account=def-bourqueg --time=04:00:00 -N 1 -c 16 --mem-per-cpu=3900M -J methyldackel-bismark -o methyldackel-bismark.out -e methyldackel-bismark.err
#done
