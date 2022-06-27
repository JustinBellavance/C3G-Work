#!/bin/bash

#genomeCoverageBed
for sample in `awk 'NR>1{print $1}' readset.methylseq.txt`;
do
  cmd="""#!/bin/bash
  module load mugqic/bedtools/2.29.2 && \
  genomeCoverageBed -bg -split \
  -ibam alignment_gem3_cpu/${sample}/${sample}.sorted.dedup.bam \
  -g $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh38/genome/bismark_index/Homo_sapiens.GRCh38.fa.fai > \
  alignment_gem3_cpu/${sample}/tracks/${sample}.bedGraph"""
  #echo "$cmd"
  echo "$cmd" | sbatch --account=def-bourqueg --time=02:00:00 -N 1 -c 4 --mem-per-cpu=3900M -J ${sample}_coverageBed -o  alignment_gem3_cpu/${sample}/${sample}_coverageBed.out -e alignment_gem3_cpu/${sample}/${sample}_coverageBed.err | grep "[0-9]"
done
