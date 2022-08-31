#!/bin/bash

#samtools sort -n
for sample in `awk 'NR>1{print $1}' readset.methylseq.txt`;
do
  cmd="""#!/bin/bash
  module purge && \
  module load mugqic/samtools/1.14 && \
  samtools sort -o alignment_gem3_cpu/${sample}/${sample}.nsorted.bam -n -@ 30 alignment_gem3_cpu/${sample}/${sample}.sorted.bam"""
       #echo "$cmd"
       echo "$cmd" | sbatch --account=def-bourqueg --time=20:00:00 -N 1 -c 32 --mem-per-cpu=3900M -J ${sample}_sort -o alignment_gem3_cpu/${sample}/${sample}_sort.out -e alignment_gem3_cpu/${sample}/${sample}_sort.err | grep "[0-9]"
done
