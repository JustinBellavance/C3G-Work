#!/bin/bash

#cpu simulated
cmd="""#!/bin/bash
  module purge && \
  module load mugqic_dev/gem3-mapper/Master20200925 mugqic/sambamba && \
  mkdir -p alignment_gem3_cpu_simulated/ && \
  gem-mapper -I $MUGQIC_INSTALL_HOME_DEV/genomes/species/Homo_sapiens.GRCh38/genome/bisulfite/gem3-mapper_index_cpu/Homo_sapiens.GRCh38.gem -1 ~/scratch/large_paired/simulated_1.fastq -2 ~/scratch/large_paired/simulated_2.fastq -t 16 --report-file alignment_gem3_cpu_simulated/simulated_report.txt | \
  sambamba view -S -f bam \
  /dev/stdin \
  | \
  sambamba sort \
  /dev/stdin \
  --out alignment_gem3_cpu_simulated/simulated.sorted.bam \ """
       #echo "$cmd"
echo "$cmd" | sbatch --account=def-bourqueg --time=06:00:00 -N 1 -c 16 --mem-per-cpu=3900M -J simulated_gem3_cpu -o alignment_gem3_cpu_simulated/simulated_gem3_cpu.out -e alignment_gem3_cpu_simulated/simulated_gem3_cpu.err | grep "[0-9]"
