#!/bin/bash

#bissnp
for sample in `awk -F "," 'NR>1{print $1}' metadata.csv`;
do
  cmd="""#!/bin/bash
  module load mugqic_dev/bs_call && \
  bs_call \
  --output-type v \
  --report-file BS_call/${sample}/${sample}_bs_call_report.json \
  --sample ${sample} \
  --reference $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh38/genome/bismark_index/Homo_sapiens.GRCh38.fa \
  -o BS_call/${sample}/${sample}.vcf \
  output/${sample}/${sample}_sra_2.trimmed_bismark_bt2_pe.sorted.bam"""
echo "$cmd" | sbatch --account=def-bourqueg --time=24:00:00 -N 1 -c 8 --mem-per-cpu=3900M -J ${sample}_bscall -o ${sample}_bscall.out -e ${sample}_bscall.err | grep "[0-9]"
done
