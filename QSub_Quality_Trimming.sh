#!/bin/env bash

#PBS -l mem=1gb,nodes=1:ppn=4,walltime=8:00:00 
#PBS -m abe 
#PBS -M 
#PBS -q lab

set -e
set -u
set -o pipefail

module load parallel

#   The trimming script runs seqqs, scythe, and sickle, and plots_seqqs.R
#   The script is heavily modified from a Vince Buffalo original
#   Most important modification is the addition of plotting of read data before &
#   after 
SEQQS_DIR=
TRIM_SCRIPT=${SEQQS_DIR}/wrappers/trim_autoplot.sh

#   Extension on forward and reverse read names to be trimmed by basename
#       Example:
#           _1_sequence.txt.gz  for forward
#           _2_sequence.txt.gz  for reverse
FORWARD_NAMING=
REVERSE_NAMING=

#   Project name
PROJECT=SCN

#   Output directory, currently writing full processed directory to scratch
#   Need a symlink at ${HOME} to a scratch directory
OUTDIR=

#   Directory where samples are stored
WORKING=

#   List of samples to be processed
#   Need to hard code the file path for qsub jobs
SAMPLE_INFO=

#   Test to see if there are equal numbers of forward and reverse reads
FORWARD_COUNT="`grep -cE "$FORWARD_NAMING" $SAMPLE_INFO`"
REVERSE_COUNT="`grep -cE "$REVERSE_NAMING" $SAMPLE_INFO`"

if [ "$FORWARD_COUNT" = "$REVERSE_COUNT" ]; then
    echo Equal numbers of forward and reverse samples
else
    exit 1
fi

#   Create lists of forward and reverse samples
grep -E "$FORWARD_NAMING" $SAMPLE_INFO > ${OUTDIR}/forward.txt
FORWARD_SAMPLES=${OUTDIR}/forward.txt
grep -E "$REVERSE_NAMING" $SAMPLE_INFO > ${OUTDIR}/reverse.txt
REVERSE_SAMPLES=${OUTDIR}/reverse.txt

#   Create a list of sample names
for i in `seq $(wc -l < $FORWARD_SAMPLES)`
do
    s=`head -"$i" "$FORWARD_SAMPLES" | tail -1`
    basename $s $FORWARD_NAMING >> ${OUTDIR}/samples.txt
done

SAMPLE_NAMES=${OUTDIR}/samples.txt


#   Change to program directory
#   This is necessary to call the R script (used for plotting) from the trim_autoplot.sh script
cd ${SEQQS_DIR}/wrappers/


#   Run the job in parallel
parallel ${TRIM_SCRIPT} {3} {1} {2} ${OUTDIR}/${PROJECT}/{3} ::: `cat $FORWARD_SAMPLES` ::: `cat $REVERSE_SAMPLES` ::: `cat $SAMPLE_NAMES`
