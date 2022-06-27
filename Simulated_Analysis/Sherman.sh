#!/bin/bash
cmd="""#!/bin/bash
  module load mugqic_dev/Sherman &&
  cd 1x/ && 
  Sherman --length 125 --number_of_seqs $((20666150*1)) --minfrag 0 --maxfrag 500 --genome_folder $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.GRCh38/genome/ --conversion_rate 0 --error_rate 0.5 --variable_length_adapter 250 --paired_end"""
echo "$cmd" | sbatch --account=def-bourqueg --time=06:00:00 -N 1 -c 16 --mem-per-cpu=4000M -J simulated_reads_1 -o simulated_reads.out -e simulated_reads.err
