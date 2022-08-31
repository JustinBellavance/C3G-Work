#!/bin/bash

#gpu
for sample in `awk 'NR>1{print $1}' readset.methylseq.txt`;
do
  cmd="""#!/bin/bash
  module purge && \
  module load mugqic_dev/gem3-mapper/Master20200925 mugqic/sambamba && \
  mkdir -p alignment_gem3_gpu/${sample} && \ 
  gem-mapper -I $MUGQIC_INSTALL_HOME_DEV/genomes/species/Homo_sapiens.GRCh38/genome/bisulfite/gem3-mapper_index_gpu/Homo_sapiens.GRCh38.gem -z -1 trim/${sample}/${sample}.trim.pair1.fastq.gz -z -2 trim/${sample}/${sample}.trim.pair2.fastq.gz --gpu -t 8 --report-file alignment_gem3_gpu/${sample}/${sample}_report.txt | \
  sambamba view -S -f bam \
  /dev/stdin \
  | \
  sambamba sort \
  /dev/stdin \
  --tmpdir ${SLURM_TMPDIR} \
  --out alignment_gem3_gpu/${sample}/${sample}.sorted.bam"""
       #echo "$cmd"
	echo "$cmd" | sbatch --account=def-bourqueg --time=06:00:00 -N 1 -c 16 --gres=gpu:2 --mem-per-cpu=3900M -J ${sample}_gem3_gpu -o alignment_gem3_gpu/${sample}/${sample}_gem3_gpu.out -e alignment_gem3_gpu/${sample}/${sample}_gem3_gpu.err | grep "[0-9]"
done
