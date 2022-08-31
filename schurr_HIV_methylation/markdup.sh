#!/bin/bash

#dedup
for sample in `awk 'NR>1{print $1}' readset.methylseq.txt`;
do
  cmd="""#!/bin/bash
  module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/sambamba && \
  sambamba markdup -r \
  -t 15 \
  alignment_gem3_cpu/${sample}/${sample}.sorted.bam \
  alignment_gem3_cpu/${sample}/${sample}.sorted.dedup.bam"""
  #echo "$cmd"
  echo "$cmd" | sbatch --account=def-bourqueg --time=06:00:00 -N 1 -c 16 --mem-per-cpu=3900M -J ${sample}_dedup -o  alignment_gem3_cpu/${sample}/${sample}_dedup.out -e alignment_gem3_cpu/${sample}/${sample}_dedup.err | grep "[0-9]"
done
