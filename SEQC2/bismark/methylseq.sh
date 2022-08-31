#!/bin/bash
# Exit immediately on error

set -eu -o pipefail

#-------------------------------------------------------------------------------
# MethylSeq SLURM Job Submission Bash script
# Version: 4.1.2
# Created on: 2022-08-01T14:08:24
# Steps:
#   picard_sam_to_fastq: 0 job... skipping
#   trimmomatic: 4 jobs
#   TOTAL: 4 jobs
#-------------------------------------------------------------------------------

OUTPUT_DIR=/lustre04/scratch/justb11/SEQC2/bismark
JOB_OUTPUT_DIR=$OUTPUT_DIR/job_output
TIMESTAMP=`date +%FT%H.%M.%S`
JOB_LIST=$JOB_OUTPUT_DIR/MethylSeq_job_list_$TIMESTAMP
export CONFIG_FILES="/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.3.0/pipelines/methylseq/methylseq.base.ini"
mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR

                    sed -i "s/\"submission_date\": \"\",/\"submission_date\": \"$TIMESTAMP\",/" /lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC12_cont_chr19.json

                    sed -i "s/\"submission_date\": \"\",/\"submission_date\": \"$TIMESTAMP\",/" /lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC12_treat_chr19.json

                    sed -i "s/\"submission_date\": \"\",/\"submission_date\": \"$TIMESTAMP\",/" /lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC10_treat_chr19.json

                    sed -i "s/\"submission_date\": \"\",/\"submission_date\": \"$TIMESTAMP\",/" /lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC10_cont_chr19.json

#------------------------------------------------------------------------------
# Print a copy of sample JSONs for the genpipes dashboard
#------------------------------------------------------------------------------
cp "/lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC10_cont_chr19.json" "$PORTAL_OUTPUT_DIR/$USER.methylseq_AMC10_cont_chr19.29648264-6ad6-44ba-ab81-5001fd3a158b.json"
cp "/lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC10_treat_chr19.json" "$PORTAL_OUTPUT_DIR/$USER.methylseq_AMC10_treat_chr19.aa990b18-33b3-470b-a9ae-37474d8d0198.json"
cp "/lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC12_cont_chr19.json" "$PORTAL_OUTPUT_DIR/$USER.methylseq_AMC12_cont_chr19.58317ee3-2348-4689-b027-63f772df406e.json"
cp "/lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC12_treat_chr19.json" "$PORTAL_OUTPUT_DIR/$USER.methylseq_AMC12_treat_chr19.411aca82-db86-43e7-84f5-a4a0bc2f6938.json"

#-------------------------------------------------------------------------------
# STEP: trimmomatic
#-------------------------------------------------------------------------------
STEP=trimmomatic
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: trimmomatic_1_JOB_ID: trimmomatic.AMC10_cont_chr19
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic.AMC10_cont_chr19
JOB_DEPENDENCIES=
JOB_DONE=job_output/trimmomatic/trimmomatic.AMC10_cont_chr19.7ca8eda85e17657baefed7c19e33e009.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'trimmomatic.AMC10_cont_chr19.7ca8eda85e17657baefed7c19e33e009.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/trimmomatic/0.36 && \
mkdir -p trim/methylseq_AMC10_cont_chr19 && \
`cat > trim/methylseq_AMC10_cont_chr19/AMC10_cont_chr19.trim.adapters.fa << END
>Prefix/1
ACACTCTTTCCCTACACGACGCTCTTCCGATCT
>Prefix/2
GTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT
END
` && \
java -XX:ParallelGCThreads=6 -Xmx20000M -jar $TRIMMOMATIC_JAR PE \
  -threads 4 \
  -phred33 \
  /cvmfs/soft.mugqic/CentOS6/testdata/methylseq/raw_data/AMC10_cont.R1.fastq.gz \
  /cvmfs/soft.mugqic/CentOS6/testdata/methylseq/raw_data/AMC10_cont.R2.fastq.gz \
  trim/methylseq_AMC10_cont_chr19/AMC10_cont_chr19.trim.pair1.fastq.gz \
  trim/methylseq_AMC10_cont_chr19/AMC10_cont_chr19.trim.single1.fastq.gz \
  trim/methylseq_AMC10_cont_chr19/AMC10_cont_chr19.trim.pair2.fastq.gz \
  trim/methylseq_AMC10_cont_chr19/AMC10_cont_chr19.trim.single2.fastq.gz \
  ILLUMINACLIP:trim/methylseq_AMC10_cont_chr19/AMC10_cont_chr19.trim.adapters.fa:2:30:15 \
  TRAILING:30 \
  MINLEN:50 \
  2> trim/methylseq_AMC10_cont_chr19/AMC10_cont_chr19.trim.log
trimmomatic.AMC10_cont_chr19.7ca8eda85e17657baefed7c19e33e009.mugqic.done
chmod 755 $COMMAND
trimmomatic_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.14
/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.1.2/utils/job2json.py \
  -u \"$USER\" \
  -c \"/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.3.0/pipelines/methylseq/methylseq.base.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC10_cont_chr19.json\" \
  -f \"running\"
module unload mugqic/python/2.7.14 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.14
/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.1.2/utils/job2json.py \
  -u \"$USER\" \
  -c \"/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.3.0/pipelines/methylseq/methylseq.base.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC10_cont_chr19.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.14 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch -m ae -M $JOB_MAIL -W umask=0002 -d $OUTPUT_DIR -j oe -o $JOB_OUTPUT -N $JOB_NAME --time=24:00:00 --mem 20G -c 4 -N 1 -q sw  | grep "[0-9]")
echo "$trimmomatic_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$trimmomatic_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: trimmomatic_2_JOB_ID: trimmomatic.AMC10_treat_chr19
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic.AMC10_treat_chr19
JOB_DEPENDENCIES=
JOB_DONE=job_output/trimmomatic/trimmomatic.AMC10_treat_chr19.9f458a234450a46968d500601c47e9a2.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'trimmomatic.AMC10_treat_chr19.9f458a234450a46968d500601c47e9a2.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/trimmomatic/0.36 && \
mkdir -p trim/methylseq_AMC10_treat_chr19 && \
`cat > trim/methylseq_AMC10_treat_chr19/AMC10_treat_chr19.trim.adapters.fa << END
>Prefix/1
ACACTCTTTCCCTACACGACGCTCTTCCGATCT
>Prefix/2
GTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT
END
` && \
java -XX:ParallelGCThreads=6 -Xmx20000M -jar $TRIMMOMATIC_JAR PE \
  -threads 4 \
  -phred33 \
  /cvmfs/soft.mugqic/CentOS6/testdata/methylseq/raw_data/AMC10_treat.R1.fastq.gz \
  /cvmfs/soft.mugqic/CentOS6/testdata/methylseq/raw_data/AMC10_treat.R2.fastq.gz \
  trim/methylseq_AMC10_treat_chr19/AMC10_treat_chr19.trim.pair1.fastq.gz \
  trim/methylseq_AMC10_treat_chr19/AMC10_treat_chr19.trim.single1.fastq.gz \
  trim/methylseq_AMC10_treat_chr19/AMC10_treat_chr19.trim.pair2.fastq.gz \
  trim/methylseq_AMC10_treat_chr19/AMC10_treat_chr19.trim.single2.fastq.gz \
  ILLUMINACLIP:trim/methylseq_AMC10_treat_chr19/AMC10_treat_chr19.trim.adapters.fa:2:30:15 \
  TRAILING:30 \
  MINLEN:50 \
  2> trim/methylseq_AMC10_treat_chr19/AMC10_treat_chr19.trim.log
trimmomatic.AMC10_treat_chr19.9f458a234450a46968d500601c47e9a2.mugqic.done
chmod 755 $COMMAND
trimmomatic_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.14
/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.1.2/utils/job2json.py \
  -u \"$USER\" \
  -c \"/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.3.0/pipelines/methylseq/methylseq.base.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC10_treat_chr19.json\" \
  -f \"running\"
module unload mugqic/python/2.7.14 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.14
/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.1.2/utils/job2json.py \
  -u \"$USER\" \
  -c \"/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.3.0/pipelines/methylseq/methylseq.base.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC10_treat_chr19.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.14 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch -m ae -M $JOB_MAIL -W umask=0002 -d $OUTPUT_DIR -j oe -o $JOB_OUTPUT -N $JOB_NAME --time=24:00:00 --mem 20G -c 4 -N 1 -q sw  | grep "[0-9]")
echo "$trimmomatic_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$trimmomatic_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: trimmomatic_3_JOB_ID: trimmomatic.AMC12_cont_chr19
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic.AMC12_cont_chr19
JOB_DEPENDENCIES=
JOB_DONE=job_output/trimmomatic/trimmomatic.AMC12_cont_chr19.040457594f8ae684ccc8c85fbc5925a0.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'trimmomatic.AMC12_cont_chr19.040457594f8ae684ccc8c85fbc5925a0.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/trimmomatic/0.36 && \
mkdir -p trim/methylseq_AMC12_cont_chr19 && \
`cat > trim/methylseq_AMC12_cont_chr19/AMC12_cont_chr19.trim.adapters.fa << END
>Prefix/1
ACACTCTTTCCCTACACGACGCTCTTCCGATCT
>Prefix/2
GTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT
END
` && \
java -XX:ParallelGCThreads=6 -Xmx20000M -jar $TRIMMOMATIC_JAR PE \
  -threads 4 \
  -phred33 \
  /cvmfs/soft.mugqic/CentOS6/testdata/methylseq/raw_data/AMC12_cont.R1.fastq.gz \
  /cvmfs/soft.mugqic/CentOS6/testdata/methylseq/raw_data/AMC12_cont.R2.fastq.gz \
  trim/methylseq_AMC12_cont_chr19/AMC12_cont_chr19.trim.pair1.fastq.gz \
  trim/methylseq_AMC12_cont_chr19/AMC12_cont_chr19.trim.single1.fastq.gz \
  trim/methylseq_AMC12_cont_chr19/AMC12_cont_chr19.trim.pair2.fastq.gz \
  trim/methylseq_AMC12_cont_chr19/AMC12_cont_chr19.trim.single2.fastq.gz \
  ILLUMINACLIP:trim/methylseq_AMC12_cont_chr19/AMC12_cont_chr19.trim.adapters.fa:2:30:15 \
  TRAILING:30 \
  MINLEN:50 \
  2> trim/methylseq_AMC12_cont_chr19/AMC12_cont_chr19.trim.log
trimmomatic.AMC12_cont_chr19.040457594f8ae684ccc8c85fbc5925a0.mugqic.done
chmod 755 $COMMAND
trimmomatic_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.14
/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.1.2/utils/job2json.py \
  -u \"$USER\" \
  -c \"/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.3.0/pipelines/methylseq/methylseq.base.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC12_cont_chr19.json\" \
  -f \"running\"
module unload mugqic/python/2.7.14 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.14
/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.1.2/utils/job2json.py \
  -u \"$USER\" \
  -c \"/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.3.0/pipelines/methylseq/methylseq.base.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC12_cont_chr19.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.14 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch -m ae -M $JOB_MAIL -W umask=0002 -d $OUTPUT_DIR -j oe -o $JOB_OUTPUT -N $JOB_NAME --time=24:00:00 --mem 20G -c 4 -N 1 -q sw  | grep "[0-9]")
echo "$trimmomatic_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$trimmomatic_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: trimmomatic_4_JOB_ID: trimmomatic.AMC12_treat_chr19
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic.AMC12_treat_chr19
JOB_DEPENDENCIES=
JOB_DONE=job_output/trimmomatic/trimmomatic.AMC12_treat_chr19.14afacf8db18087bab9cb33997379fca.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'trimmomatic.AMC12_treat_chr19.14afacf8db18087bab9cb33997379fca.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/trimmomatic/0.36 && \
mkdir -p trim/methylseq_AMC12_treat_chr19 && \
`cat > trim/methylseq_AMC12_treat_chr19/AMC12_treat_chr19.trim.adapters.fa << END
>Prefix/1
ACACTCTTTCCCTACACGACGCTCTTCCGATCT
>Prefix/2
GTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT
END
` && \
java -XX:ParallelGCThreads=6 -Xmx20000M -jar $TRIMMOMATIC_JAR PE \
  -threads 4 \
  -phred33 \
  /cvmfs/soft.mugqic/CentOS6/testdata/methylseq/raw_data/AMC12_treat.R1.fastq.gz \
  /cvmfs/soft.mugqic/CentOS6/testdata/methylseq/raw_data/AMC12_treat.R2.fastq.gz \
  trim/methylseq_AMC12_treat_chr19/AMC12_treat_chr19.trim.pair1.fastq.gz \
  trim/methylseq_AMC12_treat_chr19/AMC12_treat_chr19.trim.single1.fastq.gz \
  trim/methylseq_AMC12_treat_chr19/AMC12_treat_chr19.trim.pair2.fastq.gz \
  trim/methylseq_AMC12_treat_chr19/AMC12_treat_chr19.trim.single2.fastq.gz \
  ILLUMINACLIP:trim/methylseq_AMC12_treat_chr19/AMC12_treat_chr19.trim.adapters.fa:2:30:15 \
  TRAILING:30 \
  MINLEN:50 \
  2> trim/methylseq_AMC12_treat_chr19/AMC12_treat_chr19.trim.log
trimmomatic.AMC12_treat_chr19.14afacf8db18087bab9cb33997379fca.mugqic.done
chmod 755 $COMMAND
trimmomatic_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.14
/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.1.2/utils/job2json.py \
  -u \"$USER\" \
  -c \"/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.3.0/pipelines/methylseq/methylseq.base.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC12_treat_chr19.json\" \
  -f \"running\"
module unload mugqic/python/2.7.14 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.14
/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.1.2/utils/job2json.py \
  -u \"$USER\" \
  -c \"/cvmfs/soft.mugqic/CentOS6/software/genpipes/genpipes-4.3.0/pipelines/methylseq/methylseq.base.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/justb11/SEQC2/bismark/json/methylseq_AMC12_treat_chr19.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.14 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch -m ae -M $JOB_MAIL -W umask=0002 -d $OUTPUT_DIR -j oe -o $JOB_OUTPUT -N $JOB_NAME --time=24:00:00 --mem 20G -c 4 -N 1 -q sw  | grep "[0-9]")
echo "$trimmomatic_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$trimmomatic_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# Call home with pipeline statistics
#-------------------------------------------------------------------------------
LOG_MD5=$(echo $USER-'10.74.73.1-MethylSeq-methylseq_AMC10_cont_chr19.AMC10_cont_chr19,methylseq_AMC10_treat_chr19.AMC10_treat_chr19,methylseq_AMC12_cont_chr19.AMC12_cont_chr19,methylseq_AMC12_treat_chr19.AMC12_treat_chr19' | md5sum | awk '{ print $1 }')
if test -t 1; then ncolors=$(tput colors); if test -n "$ncolors" && test $ncolors -ge 8; then bold="$(tput bold)"; normal="$(tput sgr0)"; yellow="$(tput setaf 3)"; fi; fi
wget --quiet 'http://mugqic.hpc.mcgill.ca/cgi-bin/pipeline.cgi?hostname=beluga1.int.ets1.calculquebec.ca&ip=10.74.73.1&pipeline=MethylSeq&steps=picard_sam_to_fastq,trimmomatic&samples=4&md5=$LOG_MD5' -O /dev/null || echo "${bold}${yellow}Warning:${normal}${yellow} Genpipes ran successfully but was not send telemetry to mugqic.hpc.mcgill.ca. This error will not affect genpipes jobs you have submitted.${normal}"
