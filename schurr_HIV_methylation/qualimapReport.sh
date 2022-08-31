#!/bin/bash

#qualimap report
for sample in `awk 'NR>1{print $1}' readset.methylseq.txt`;
do
  cmd="""#!/bin/bash
  module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/qualimap && \
  qualimap bamqc \
  -nt 15 \
  -gd HUMAN \
  -bam alignment_gem3_cpu/${sample}/${sample}.sorted.bam \
  --java-mem-size=80G \
  -outdir alignment_gem3_cpu/${sample} \
  --output-genome-coverage alignment_gem3_cpu/${sample}/${sample}_genome-coverage.txt"""
  #echo "$cmd"
  echo "$cmd" | sbatch --account=def-bourqueg --time=04:00:00 -N 1 -c 16 --mem-per-cpu=4000M -J ${sample}_qualimap -o  alignment_gem3_cpu/${sample}/${sample}_qualimap.out -e alignment_gem3_cpu/${sample}/${sample}_qualimap.err | grep "[0-9]"
done
