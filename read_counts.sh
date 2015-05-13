#!/bin/env bash

set -e
set -u
set -o pipefail

# input format for this list is simply fastq files, one per line
# could build list with find
# fastq_1.gz
# fastq_2.gz

#PBS -l mem=1000mb,nodes=1:ppn=1,walltime=8:00:00
#PBS -m abe
#PBS -M pmorrell@umn.edu

# sample list
sample_info=$1

# path to bioawk installation
bioawk=~/Apps/HLi/bioawk

echo "$sample_info"

# create a bash array of sample names for files
sample_names=($(cut -f 1 "$sample_info"))

# create output file
touch read_counts.txt

echo ${sample_names[*]}

# iterate over each of the sample names and calculate 
for sample in ${sample_names[*]}
    do
    		count="$(bioawk -cfastx 'END{print NR}' $sample)"
    		printf %s"$sample \t $count \n"  >>./read_counts.txt
    done



