#!/bin/bash

#bs_call bismark
for sample in `awk 'NR>1{print $1}' readset.methylseq.txt`;
do
  cmd="""#!/bin/bash
  module load mugqic_dev/bs_call && \
  bs_call \
  --output-type v \
  --report-file alignment_bismark/${sample}/${sample}_bs_call_report.json \
  --sample ${sample} \
  --reference $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh38/genome/bismark_index/Homo_sapiens.GRCh38.fa \
  -o alignment_bismark/${sample}/${sample}.sorted.dedup.vcf \
  alignment_bismark/${sample}/${sample}.sorted.dedup.bam"""
  echo "$cmd" | sbatch --account=def-bourqueg --time=03:00:00 -N 1 -c 4 --mem-per-cpu=3900M -J ${sample}_bscall_bismark -o alignment_gem3_cpu/${sample}/${sample}_bscall_bismark.out -e alignment_gem3_cpu/${sample}/${sample}_bscall_bismark.err | grep "[0-9]"
done
