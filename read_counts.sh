#!/bin/env bash

set -e
set -u
set -o pipefail

#   This script is a QSub submission for running FastQC on a batch of files.
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
usage() {
    echo -e "\
Usage: ./read_counts.sh sample_info outdirectory \n\
where:  sample info is a list of samples to be processed \n\
\n\
        outdirectory is the directory where the final text file should be placed \n\
" >&2
    exit 1
}


if [ "$#" -lt 2 ]; then
    usage;
fi

#   List of samples to be processed
sample_info=$1

#   Specify path to outdirectory
OUTDIR=$2

#   Check to see if bioawk is installed
if `command -v bioawk > /dev/null 2> /dev/null`
then
    echo "Bioawk is installed"
else
    echo "Please install Bioawk and add it to your PATH"
    echo
    echo "Running 'installer.sh bioawk' will do this"
    exit 1 
fi

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
    		printf %s"$sample \t $count \n" >> ./${outfile}_out.txt
    done

echo Results can be found at "${OUTDIR}"/"$outfile"_out.txt
