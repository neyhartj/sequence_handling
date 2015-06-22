#!/bin/env bash

#PBS -l mem=12gb,nodes=1:ppn=8,walltime=4:00:00 
#PBS -m abe 
#PBS -M user@example.com
#PBS -q lab

set -e
set -u
set -o pipefail

module load parallel

#   This script is a QSub submission for generating a coverage map for a batch of BAM files.
#   To use, on line 5, change the 'user@example.com' to your own email address
#       to get notifications on start and completion for this script
#   Define a path to the bedtools in the 'BEDTOOLS' field on line 47
#       If using MSI, leave the definition as is to use their installation of bedtools
#       Otherwise, it should look like this:
#           BEDTOOLS=${HOME}/software/bedtools
#       Please be sure to comment out (put a '#' symbol in front of) the 'module load bedtools' on line 46
#       And to uncomment (remove the '#' symbol) from the 'BEDTOOLS=' line 47
#   Add the full file path to list of samples on the 'SAMPLE_INFO' field on line 50
#       This should look like:
#           SAMPLE_INFO=${HOME}/Directory/list.txt
#       Use ${HOME}, as it is a link that the shell understands as your home directory
#           and the rest is the full path to the actual list of samples
#   Name the project in the 'PROJECT' field on line 53
#       This should look lke:
#           PROJECT=Genetics
#   Put the full directory path for the output in the 'SCRATCH' field on line 56
#       This should look like:
#           SCRATCH="${HOME}/Out_Directory"
#       Adjust for your own out directory.
#   Define a reference annotation file for the coverage mapping process in the 'REF_ANN' field on line 60
#       This should look like:
#           REF_ANN=${HOME}/Directory/annotation.bed
#       This can be either a BED file or a GFF file
#   Run this script using the qsub command
#       qsub Coverage_Map.sh
#   This script outputs a text file for each sample

#   Path to BEDTools
#   On MSI, loading the module works
#   Otherwise, have path to BEDTools directory
module load bedtools
#BEDTOOLS=

#   List of BAM files for coverage mapping
SAMPLE_INFO=

#   Name of Project
PROJECT=

#   Scratch directory for output, 'scratch' is a symlink to individual user scratch at /scratch*
SCRATCH=

#   Annotation file to be considered
#       This is the reference .bed or .gff file
REF_ANN=

#   Other variables, don't need to be user-specified
DATE=`date +%Y-%m-%d`
mkdir -p ${SCRATCH}/${PROJECT}

#   List of sample names
for i in `seq $(wc -l < "${SAMPLE_INFO}")`
do
    s=`head -"$i" "${SAMPLE_INFO}" | tail -1`
    basename "$s" .bam >> "${SCRATCH}"/"${PROJECT}"/sample_names.txt
done

SAMPLES="${SCRATCH}"/"${PROJECT}"/sample_names.txt

#   Do the work here
cd ${SCRATCH}/${PROJECT}
parallel --xapply "bedtools coverage -hist -abam {1} -b ${REF_ANN} > ${SCRATCH}/${PROJECT}/Sample_{2}_${PROJECT}_${DATE}.coverage.hist.txt" :::: ${SAMPLE_INFO} :::: ${SAMPLES}

#   Make an output list for use with
find ${SCRATCH}/${PROJECT} -name "*.coverage.hist.txt" | sort > ${SCRATCH}/${PROJECT}/${PROJECT}_samples_coverage.txt
echo "List of samples for  can be found at"
echo "${SCRATCH}/${PROJECT}/${PROJECT}_samples_coverage.txt"
