#!/bin/bash

#methyldackel
for sample in `awk 'NR>1{print $1}' readset.methylseq.txt`;
do
  cmd="""#!/bin/bash
  module load mugqic_dev/MethylDackel/0.6.1 && \
  MethylDackel extract \
  --CHG --CHH -@ 15 \
  $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh38/genome/Homo_sapiens.GRCh38.fa \
  alignment_gem3_cpu/${sample}/${sample}.sorted.dedup.bam"""
  #echo "$cmd"
  echo "$cmd" | sbatch --account=def-bourqueg --time=02:00:00 -N 1 -c 4 --mem-per-cpu=3900M -J ${sample}_methyldackel -o alignment_gem3_cpu/${sample}/${sample}_methyldackel.out -e alignment_gem3_cpu/${sample}/${sample}_methyldackel.err | grep "[0-9]"
done
