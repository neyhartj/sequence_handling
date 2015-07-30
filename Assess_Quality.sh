#!/bin/sh

#PBS -l mem=4000mb,nodes=1:ppn=4,walltime=6:00:00
#PBS -m abe
#PBS -M user@example.com
#PBS -q lab

set -e
set -u
set -o pipefail

module load parallel

#   This script is a QSub submission for running FastQC on a batch of files.
#   To use, on line 5, change the 'user@example.com' to your own email address
#       to get notifications on start and completion for this script
#   Add the full file path to list of samples on the 'SAMPLE_INFO' field on line 35
#       This should look like:
#           SAMPLE_INFO=${HOME}/Directory/list.txt
#       Use ${HOME}, as it is a link that the shell understands as your home directory
#           and the rest is the full path to the actual list of samples
#   Put the full directory path for the output in the 'OUT' field on line 39 with quotes around it
#       This should look like:
#           OUT="${HOME}/Out_Directory"
#       Adjust for your own out directory.
#   Run this script using the qsub command
#       qsub FastQC.sh
#   This script outputs an HTML file and a .zip archive for every sample run
#   Suggested post-processing is to run FasterQC on the HTML files to create one
#       PNG image of the output. See more at
#   http://msi-riss.readthedocs.org/en/latest/software/riss_util.html#fasterqc-pl

#   List of samples to be processed
#   Need to hard code the file path for qsub jobs
SAMPLE_INFO=

#   Full path to out directory
#       Requires quotes around directory path
OUT=""

#   Load FastQC Module
module load fastqc

#   Run FastQC in parallel
mkdir -p ${OUT}
cat ${SAMPLE_INFO} | parallel "fastqc {} -o ${OUT}"

# Create a list of ZIP files for use in counting read depth
find ${OUT} -name "*.zip" | sort > ${OUT}/FastQC_zipfiles.txt
echo "List of ZIP files can be found at"
echo "${OUT}/FastQC_zipfiles.txt"
