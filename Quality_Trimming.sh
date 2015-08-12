#!/bin/env bash

#PBS -l mem=1gb,nodes=1:ppn=8,walltime=20:00:00
#PBS -m abe
#PBS -M user@example.com
#PBS -q lab

set -e
set -u
set -o pipefail

module load parallel

#   This script is a QSub submission for quality trimming a batch of files.
#   To use, on line 5, change the 'user@example.com' to your own email address
#       to get notifications on start and completion for this script
#   Place the full directory path to your Seqqs installation on line 54
#       This should look like:
#           SEQQS_DIR=${HOME}/software/seqqs
#       Use ${HOME}, as it is a link that the shell understands as your home directory
#   Add the full file path to list of samples on the 'SAMPLE_INFO' field on line 59
#       This should look like:
#           SAMPLE_INFO=${HOME}/Directory/list.txt
#   Specify the forward and reverse file extensions in the 'FORWARD_NAMING'
#       and 'REVERSE_NAMING' fields on lines 65 and 66
#       This should look like:
#           FORWARD_NAMING=_1_sequence.txt.gz
#           REVERSE_NAMING=_2_sequence.txt.gz
#   Name the project in the 'PROJECT' field on line 69
#       This should look lke:
#           PROJECT=Genetics
#   Put the full directory path for the output in the 'SCRATCH' field on line 72
#       This should look like:
#           SCRATCH="${HOME}/Out_Directory"
#       Adjust for your own out directory.
#   Specify the directory where samples are stored in the 'WORKING' field on line 75
#       This should look like:
#           WORKING=${HOME}/Working_Directory
#   Run this script using the qsub command
#       qsub Quality_Trimming.sh
#   This script outputs gzipped FastQ files with the extension fq.qz
#   In the stats directory, there are text files with more details about the trim
#       as well as a plots directory
#   In the plots directory, there are PDFs showing graphs of the quality before and after the trim
#   Finally, this script outputs a list of all trimmed FastQ files for use in the Read_Mapping.sh script
#       This is stored in ${SCRATCH}/${PROJECT}/Quality_Trimming, whatever you happen to name these fields.


#   The trimming script runs seqqs, scythe, and sickle
#   The script is heavily modified from a Vince Buffalo original
#   Most important modification is the addition of plotting of read data before &
#   after. Leave the value for TRIM_SCRIPT as is unless you are not using seqqs,
#   sickle, and scythe for quality trimming
SEQQS_DIR=
TRIM_SCRIPT=${SEQQS_DIR}/wrappers/trim_autoplot.sh

#   List of samples to be processed
#   Need to hard code the file path for qsub jobs
SAMPLE_INFO=

#   Extension on forward and reverse read names to be trimmed by basename
#       Example:
#           _1_sequence.txt.gz  for forward
#           _2_sequence.txt.gz  for reverse
FORWARD_NAMING=
REVERSE_NAMING=

#   Project name
PROJECT=

#   Output directory
SCRATCH=

#   Directory where samples are stored
WORKING=

#   Load the R Module
module load R

#   Test to see if there are equal numbers of forward and reverse reads
FORWARD_COUNT="`grep -cE "$FORWARD_NAMING" $SAMPLE_INFO`"
REVERSE_COUNT="`grep -cE "$REVERSE_NAMING" $SAMPLE_INFO`"

if [ "$FORWARD_COUNT" = "$REVERSE_COUNT" ]; then
    echo Equal numbers of forward and reverse samples
else
    exit 1
fi

#   Create lists of forward and reverse samples
OUT=${SCRATCH}/${PROJECT}/Quality_Trimming
mkdir -p ${OUT}
grep -E "$FORWARD_NAMING" $SAMPLE_INFO > ${OUT}/forward.txt
FORWARD_SAMPLES=${OUT}/forward.txt
grep -E "$REVERSE_NAMING" $SAMPLE_INFO > ${OUT}/reverse.txt
REVERSE_SAMPLES=${OUT}/reverse.txt

#   Create a list of sample names
for i in `seq $(wc -l < $FORWARD_SAMPLES)`
do
    s=`head -"$i" "$FORWARD_SAMPLES" | tail -1`
    basename "$s" "$FORWARD_NAMING" >> "${OUT}"/samples.txt
done

SAMPLE_NAMES=${OUT}/samples.txt


#   Change to program directory
#   This is necessary to call the R script (used for plotting) from the trim_autoplot.sh script
cd ${SEQQS_DIR}/wrappers/


#   Run the job in parallel
parallel --xapply ${TRIM_SCRIPT} {1} {2} {3} ${OUT}/{4} :::: $SAMPLE_NAMES :::: $FORWARD_SAMPLES :::: $REVERSE_SAMPLES :::: $SAMPLE_NAMES

#   Create a list of outfiles to be used by read_mapping_start.sh
find ${OUT} -regex ".*_R[1-2]_trimmed.fq.gz" | sort > ${OUT}/"${PROJECT}"_samples_trimmed.txt
echo "List for read_mapping_start.sh can be found at"
echo "${OUT}"/"${PROJECT}"_samples_trimmed.txt
