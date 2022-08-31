#!/bin/bash

#bs_call
for sample in `awk -F "," 'NR>1{print $1}' gemBS/metadata.csv`;
do
  cmd="""#!/bin/bash
    module purge && module load mugqic/BisSNP/1.0.0 mugqic/java/openjdk-jdk1.8.0_72 && \
    java -Djava.io.tmpdir=/tmp/ -XX:ParallelGCThreads=2 -Xmx5G -jar $MUGQIC_INSTALL_HOME/software/BisSNP/BisSNP-1.0.0/BisSNP-1.0.0.jar \
    --analysis_type BisulfiteGenotyper \
    --reference_sequence $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh38/genome/bismark_index/Homo_sapiens.GRCh38.fa \
    --input_file gemBS/mapping/${sample}/${sample}.sorted.bam \
    --dbsnp $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh38/annotations/Homo_sapiens.GRCh38.dbSNP150.vcf.gz \
    --vcf_file_name_1 BisSNP/${sample}.cpg.vcf \
    --vcf_file_name_2 BisSNP/${sample}.snp.vcf \
    --num_threads 15"""
echo "$cmd" | sbatch --account=def-bourqueg --time=12:00:00 -N 1 -c 16 --mem-per-cpu=3900M -J ${sample}_bissnp -o ${sample}_bissnp.out -e ${sample}_bissnp.err | grep "[0-9]"
done
