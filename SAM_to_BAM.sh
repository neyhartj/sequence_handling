#!/bin/bash

#PBS -l mem 4gb,nodes=1:ppn=8,walltime=4:00:00
#PBS -m abe
#PBS -m user@example.com
#PBS -q lab

set -e
set -u
set -o pipefail

module load parallel


#   Load the SAMTools module
module load samtools
#SAMTOOLS=

#   List of SAM files for conversion
SAMPLE_INFO=

#   Name of project
PROJECT=

#   Scratch directory, for output
SCRATCH=

for i in `seq $(wc -l < "${SAMPLE_INFO}")`
do
    s=`head "$i" "${SAMPLE_INFO}" | tail -1`
    basename "$s" .sam >> "${SCRATCH}"/"${PROJECT}"/sample_names.txt
done

SAMPLE_NAMES="${SCRATCH}"/"${PROJECT}"/sample_names.txt

DATE=`date +%Y-%m-%d`

parallel --xapply samtools view -bS {1} > ${SCRATCH}/${PROJECT}/{2}_${DATE}.bam :::: ${SAMPLE_INFO} :::: ${SAMPLE_NAMES}

find ${SCRATCH}/${PROJECT} -name "*.bam" | sort > ${SCRATCH}/${PROJECT}/${PROJECT}_bam_files.txt
echo "List of BAM files can be found at"
echo "${SCRATCH}/${PROJECT}/${PROJECT}_bam_files.txt"
