#!/bin/bash

#bs_call
for sample in `awk -F "," 'NR>1{print $1}' gemBS/metadata.csv`;
do
  cmd="""#!/bin/bash
    module load mugqic_dev/MethylDackel && \
    MethylDackel extract -@ 16 $MUGQIC_INSTALL_HOME_DEV/genomes/species/Homo_sapiens.GRCh38/genome/bisulfite/Homo_sapiens.GRCh38.fa gemBS/mapping/${sample}/${sample}.bam -o MethylDackel/${sample}/${sample}"""
echo "$cmd" | sbatch --account=def-bourqueg --time=12:00:00 -N 1 -c 16 --mem-per-cpu=3900M -J ${sample}_MethylDackel -o ${sample}_MethylDackel.out -e ${sample}_MethylDackel.err | grep "[0-9]"
done
