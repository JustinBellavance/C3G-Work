#!/bin/bash

#bsimark methylation call
for sample in `awk 'NR>1{print $1}' readset.methylseq.txt`;
do
  cmd="""#!/bin/bash
  module purge && \
  module load mugqic/bismark/0.18.1 mugqic/samtools/1.14 && \
  bismark_methylation_extractor -p --no_overlap --comprehensive --gzip --multicore 4 --no_header --bedGraph --buffer_size 20G --cytosine_report --genome_folder $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh38/genome/bismark_index/ --ignore_r2 2 --output alignment_gem3_cpu/${sample} alignment_gem3_cpu/${sample}/${sample}.nsorted.dedup.bam"""
  	echo "$cmd" | sbatch --account=def-bourqueg --time=12:00:00 -N 1 -c 16 --mem-per-cpu=3900M -J ${sample}_methylation_call -o alignment_gem3_cpu/${sample}/${sample}_methylation_call.out -e alignment_gem3_cpu/${sample}/${sample}_methylation_call.err | grep "[0-9]"
done
