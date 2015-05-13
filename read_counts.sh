#!/bin/env bash

set -e
set -u
set -o pipefail

# sample list
sample_info=$1

bioawk=~/Apps/HLi/bioawk

echo "$sample_info"

# create a bash array of sample names for files
sample_names=($(cut -f 1 "$sample_info"))

# create output file
touch read_counts.txt

echo ${sample_names[*]}

for sample in ${sample_names[*]}
    do
    		count="$(bioawk -cfastx 'END{print NR}' $sample)"
    		printf %s"$sample \t $count \n"  >>./read_counts.txt
		#$bioawk -cfastx 'END{print NR}' $sample >>./read_counts.txt
    done

