#!/bin/env bash

#PBS -l mem=2000mb,nodes=1:ppn=1,walltime=8:00:00
#PBS -m abe 
#PBS -M user@example.com
#PBS -q lab

set -e
set -u
set -o pipefail

#   This script is a qsub submission for running FastQC on a batch of files.
#   To use, on line 5, change the 'user@example.com' to your own email address
#       to get notifications on start and completion for this script
#   Add the full file path to list of samples on the 'SAMPLE_INFO' field on line 31
#       This should look like:
#           SAMPLE_INFO=${HOME}/Directory/list.txt
#       Use ${HOME}, as it is a link that the shell understands as your home directory
#           and the rest is the full path to the actual list of samples
#   Put the full directory path for the output in the 'OUT' field on line 38
#       This should look like:
#           OUT=${HOME}/Out_Directory
#       Adjust for your own out directory.
#   Run this script using the qsub command
#       qsub Read_Counts.sh
#   This script outputs text file with the read depths


#   List of samples to be processed
#   Need to hard code the file path for qsub jobs
sample_info=

#   Specify path to directory where reads are stored
#   Not needed
#WORKING=${HOME}/scratch/SCN/rename

#   Specify path to outdirectory
OUTDIR=

#   Specify path to Bioawk installation
#   This is not a path to Bioawk itself
bioawk=

#   Truncate sample info file into output file name
outfile=$(basename $sample_info .txt)

echo "$outfile"

echo "$sample_info"

#   Create a bash array of sample names for files
sample_names=($(cut -f 1 "$sample_info"))

#   Create output file
touch ${OUTDIR}/${outfile}_out.txt

echo ${sample_names[*]}

#   Iterate over each of the sample names and calculate
#   Read depth 
for sample in ${sample_names[*]}
    do
    		count="$(bioawk -cfastx 'END{print NR}' $sample)"
    		printf %s"$sample \t $count \n"  >>./${outfile}_out.txt
    done

echo Results can be found at "${OUTDIR}"/"$outfile"_out.txt
