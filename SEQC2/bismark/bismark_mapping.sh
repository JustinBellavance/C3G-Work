#!/bin/bash

for READ in `awk -F "," 'NR>1{print $1}' metadata.csv`;
do
cmd="""#!/bin/bash
  module purge && \
  module load mugqic/bowtie2 mugqic/bismark mugqic/bismark mugqic/sambamba mugqic/samtools && \
  bismark --rg_tag HiSeqX -p 12 --genome_folder $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh38/genome/bismark_index -1 ../reads/${READ}/trimmed/${READ}_sra_2.trimmed.fastq.gz -2 ../reads/${READ}/trimmed/${READ}_sra_1.trimmed.fastq.gz -o output/${READ}"""
echo "$cmd" | sbatch --account=def-bourqueg --time=48:00:00 -N 1 -c 24 --mem-per-cpu=3900M -J bismark_mapping_${READ} -o bismark_mapping_${READ}.out -e bismark_mapping_${READ}.err | grep "[0-9]"
done

