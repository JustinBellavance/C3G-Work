#!/bin/bash

#cpu
for sample in `awk 'NR>1{print $1}' readset.methylseq.txt`;
do
	
  readset=`grep $sample readset.methylseq.txt | awk '{print $2}'`;
  PU=`grep $sample readset.methylseq.txt | awk '{print "run"$5"_"$6}'`;
  LB=`grep $sample readset.methylseq.txt | awk '{print $3}'`;

  cmd="""#!/bin/bash
  module purge && \
  module load mugqic_dev/gem3-mapper/Master20200925 mugqic/sambamba && \
  mkdir -p alignment_gem3_cpu/${sample} && \
  gem-mapper -I $MUGQIC_INSTALL_HOME_DEV/genomes/species/Homo_sapiens.GRCh38/genome/bisulfite/gem3-mapper_index_cpu/Homo_sapiens.GRCh38.gem --i1 trim/${sample}/${sample}.trim.pair1.fastq.gz --i2 trim/${sample}/${sample}.trim.pair2.fastq.gz -p --bisulfite-read inferred -t 16 --report-file alignment_gem3_cpu/${sample}/${sample}_report.json -r '@RG\tID:${readset}\tSM:${sample}:McGill Genome Centre\tPU:${PU}\tLB:${LB}\tPL:Illumina' --underconversion_sequence lambda --overconversion_sequence pUC19 | \
  sambamba view -S -f bam \
  /dev/stdin \
  | \
  sambamba sort \
  /dev/stdin \
  --out alignment_gem3_cpu/${sample}/${sample}.sorted.bam \ """
       #echo "$cmd"
       echo "$cmd" | sbatch --account=def-bourqueg --time=06:00:00 -N 1 -c 16 --mem-per-cpu=3900M -J ${sample}_gem3_cpu -o alignment_gem3_cpu/${sample}/${sample}_gem3_cpu.out -e alignment_gem3_cpu/${sample}/${sample}_gem3_cpu.err | grep "[0-9]"
done
