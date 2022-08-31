#!/bin/bash

# Thanks to github.com/bio15anu/benchmarking for the script base.

# 1) run sherman 
# NEED TO USE A GENOME WITH ONLY [ACTGN] BASES TO WORK
# ELSE NEED TO REMOVE NON-ACTGN with command:

# zless <fastq>.fastq.gz | awk '{if(NR%4==2) {gsub("[RMYWKBSDHV]", "N", $0); print $0} else{print $0} }' | gzip -c > <result>.fq.gz
# less <genome>.fa | awk `{gsub("[RMYWKBSDHV]", "N", $0); print $0}' > Homo_sapiens.GRCh38_N.fa
  do for j in {1,5,20};
  NUMBER_SEQS=$((20666150*i));
  cmd="""#!/bin/bash
    module load mugqic_dev/Sherman &&
    cd ${j}/ &&
    Sherman --length 125 --number_of_seqs $NUMBER_SEQS --minfrag 0 --maxfrag 500 --genome_folder $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh38/genome/ --conversion_rate 99 --error_rate 0.5 --paired_end """
  echo "$cmd" | sbatch --account=def-bourqueg --time=72:00:00 -N 1 -c 2 --mem-per-cpu=4000M -J simulated_reads_${j}x -o simulated_reads_${j}x.out -e simulated_reads_${j}x.err

# 2) repair ID lines in fastq files	

  do for j in {1,5,20};
  ls | grep ${j}x/ | while read file;
  do for i in {1,2};
  do cat ${file}/simulated_${i}.fastq | awk '{if(NR%4==1) {split($0,ID,"_"); print ID[1]"_"ID[2]} else {print $0}' > ${file}/simulated_${i}.fixed.fastq;
  done; done; done;

# 3) compress files
  gzip --force */simulated*

#trim and filter with cutadapt
  do for j in {1,5,20};
  ls | grep ${j}x | while read file;
  do cutadapt -a AGCAGAAGACGGCATACGAGATCGGTCTCGGCATTCCTGCTGAACCGCTCTTCCGATCT -A AGATCGGAAGAGCGGTTCAGCAGGAATGCCGAGACCGATCTCGTATGCCGTCTTCTGCT \
  -q 20 -O 10 -m 100 -o ${file}/simulated_1.clipped.fastq.gz -p ${file}/simulated_2.clipped.fastq.gz \
  ${file}/simulated_1.fixed.fastq.gz ${file}/simulated_2.fixed.fastq.gz &> ${file}/cutadapt.log;
  done; done

# 4) make directories and split fastq files into chunks of 100000 ready for parallel processing
  mkdir {1,5,20}x/100000_{1,2}
  do for j in {1,5,20};
  ls | grep ${j}x | while read file;
  do for i in {1,2};
  do for n in $(seq 400000 400000 $)echo $(gunzip -c ${file}/simulated_${i}.fixed.fastq.gz | wc -l)+400000 | bc -l));
  do gunzip -c ${file}/simulated_${i}.fixed.fastq.gz | tail -n + $((${n}-399999) | head -400000 > ${file}/100000_${i}/$(echo "scale=0; ${n}/4" | bc -l).fastq;
  done; done; done done;

# 5) compress all chunk files
  gzip --force *x/100000*/*

# 7) make directories and generate bisulftie reads (99% conversion rate)
  do for j in {1,5,20};
  mkdir ${j}x/bisulfite
  ls | grep ${j}x | while read file;
  do for i in {1,2};
  do gunzip -c ${file}/simulated_${i}.fixed.fastq.gz > ${file}/bisulfite/simulated_${i}.fastq;
  bisulfite_transform.py ${file}/bisulfite/simulated_${i}.fastq 99 ${i};
  echo "finished ${file}/simulated_${i}.fastq";
  done; done; done

