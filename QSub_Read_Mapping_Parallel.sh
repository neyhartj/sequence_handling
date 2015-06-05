#!/bin/sh

#PBS -l mem=6000mb,nodes=1:ppn=8,walltime=10:00:00 
#PBS -m abe 
#PBS -M 
#PBS -q lab

module load parallel

#   The aligner command
module load bwa
PROGRAM=bwa

#   Name of Project
#       Please wrap this in quotes
#       Example: "SCN"
PROJECT=

#   Full path to reference genome
REF_GEN=

#   The directory with the reads
READS_DIR=

#   Scratch directory for output, 'scratch' is a symlink to individual user scratch at /scratch*
SCRATCH=

#   File extenstions: forward, and reverse, and general
#       Example
#           "*_R1_trimmed.fq.gz"    for forward extension
#           "*_R2_trimmed.fq.gz"    for reverse extension
#           "*_R1_trimmed.fq.gz"    for general extension
#       These are the defaults for trim_autoplot.sh
#       The quotes and astrick before the forward and
#           reverse extensions are neccessary
#           for globbing using `find`
#       For the general extension, please make it the same as forward
#           but without the astrick before hand
#       Please change below if you are not using trim_autoplot.sh
#           for quality trimming
FWD="*_R1_trimmed.fq.gz"
REV="*_R2_trimmed.fq.gz"
EXT="_R1_trimmed.fq.gz"

#       Generate a list of all files that match
find "$READS_DIR" -name "$FWD" | sort > ${SCRATCH}/fwd.txt
FWD_FILE=${SCRATCH}/fwd.txt
find "$READS_DIR" -name "$REV" | sort > ${SCRATCH}/rev.txt
REV_FILE=${SCRATCH}/rev.txt

#   Check for equal numbers of forward and reverse reads
if [ `wc -l < "$FWD_FILE"` = `wc -l < "$REV_FILE"` ]; then
    echo Equal numbers of forwad and reverse reads
else
    exit 1
fi

#   Create a list of sample names only
for i in `seq $(wc -l < $FWD_FILE)`
do
    s=`head -"$i" "$FWD_FILE" | tail -1`
    basename $s $EXT >> ${SCRATCH}/samples.txt
done

SAMPLE_NAMES=${SCRATCH}/samples.txt

#   Date in international format
YMD=`date +%Y-%m-%d`


#   CHANGES
#       2013-10-11
#       Initial Alignment
#       Using parameters
#           -t 8: Use 8 threads
#           -k 25: Seed length 25
#           -r 1.0: Re-seed if match is greater than 1.0 * seed length
#           -M : mark split hits as secondary
#           -T 80: only output alignments greater than score 80
#           -O 8: Gap open penalty
#           -E 1: Gap extension penalty
#               This should capture only reads with less than five mismatches
#       2013-10-25
#           Paralogue problems!
#           Changing seed length to 10
#           Increasing the score cutoff to 85
#       2014-10-02
#           Some indels not being resolved properly.
#           setting gapopen penalty to 8 and gapextend to 1
#       2014-09-30 (what is Tom's date scheme, it was 30 Sept 2014?)
#           Updated a number of file paths, include reference \
#           version of bwa used, etc.           
#       2015-06-02
#           Added support for parallel read mapping and running one command for all samples
#       2015-06-04
#           Created generallized version of script, runs in parallel
#       2015-06-05
#           Fixed syntax with running BWA, added index-generator for BWA in case this was not already done
#           Fixed sample-naming scheme, fixed syntax with paralllel, rearranged order of variable assigning
#           to put all user-input stuff at top of script


#   Now we run the program with all our options
#       This version runs BWA with the options listed above
#       and creates an index file for it to run.
#       Please edit for your own read mapping program.

mkdir -p ${SCRATCH}/${PROJECT}
${PROGRAM} index ${REF_GEN}
parallel --xapply ${PROGRAM} mem -t 8 -k 10 -r 1.0 -M -T 85 -O 8 -E 1 ${REF_GEN} {1} {2} > ${SCRATCH}/${PROJECT}/{3}_${PROJECT}_${YMD}.sam :::: $FWD_FILE :::: $REV_FILE :::: $SAMPLE_NAMES

#   Cleanup file lists
rm $FWD_FILE
rm $REV_FILE
rm $SAMPLE_NAMES
