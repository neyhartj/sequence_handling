#!/bin/env bash
#PBS -l mem=2000mb,nodes=1:ppn=1,walltime=8:00:00
#PBS -m abe
#PBS -M pmorrell@umn.edu

set -e
set -u
set -o pipefail

# input format is simply a list of fastq files, one per line
# could build list with find
# fastq_1.gz
# fastq_2.gz

# change to working directory
WORKING=${HOME}/scratch/SCN/rename
cd "$WORKING"

# sample list
# sample_info=$1
# need to hard code the file path for qsub jobs
sample_info=${HOME}/scratch/SCN/rename/SCN_reads.txt

# path to bioawk installation
bioawk=${HOME}/Apps/HLi/bioawk

# truncate sample info file into output file name
outfile=$(basename $sample_info .txt)

echo "$outfile"

echo "$sample_info"

# create a bash array of sample names for files
sample_names=($(cut -f 1 "$sample_info"))

# create output file
touch ./${outfile}_out.txt

echo ${sample_names[*]}

# iterate over each of the sample names and calculate
# read depth 
for sample in ${sample_names[*]}
    do
    		count="$(bioawk -cfastx 'END{print NR}' $sample)"
    		printf %s"$sample \t $count \n"  >>./${outfile}_out.txt
    done

