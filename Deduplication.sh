#!/bin/sh

#PBS -l mem=16gb,nodes=1:ppn=1,walltime=36:00:00 
#PBS -m abe 
#PBS -M user@example.com
#PBS -q lab

set -e
set -u
set -o pipefail

module load parallel



SAMPLE_INFO=
#	The root of where we will work
SCRATCH=
#   Name of Project
PROJECT=

#	The programs we are using
#       SAMTools
module load samtools
#SAMTOOLS=
#       Picard Tools
module load picard
PICARD_DIR=`echo $PTOOL | rev | cut -d " " -f 1 - | rev`
PICARD_SORT="${PICARD_DIR}/picard.jar SortSam"
#PICARD_SORT=
ADDRG="${PICARD_DIR}/picard.jar AddOrReplaceReadGroups"
#ADDRG=
MARKDUPS="${PICARD_DIR}/picard.jar MarkDuplicates"
#MARKDUPS=

PLATFORM=Illumina

#ALIGNMENT=${SAMPLE}_${CAPTURE}_${ALIGN_DATE}.sam
#	cd into the directory
cd ${SCRATCH}

dedup() {
    YMD=`date +%Y-%m-%d`
    "${ALIGNMENT}"=`basename "$1"`
    #	Use Samtools to trim out the reads we don't care about
    #	-f 3 gives us reads mapped in proper pair
    #	-F 256 excludes reads not in their primary alignments
    $SAMTOOLS view -f 3 -F 256 -bS "${ALIGNMENT}" > "${ALIGNMENT/.sam/_trimmed.bam}"
    #	Picard tools to sort and index
    java -Xmx15g -XX:MaxPermSize=10g -jar\
        "${PICARD_SORT}" \
        INPUT="${ALIGNMENT/.sam/_trimmed.bam}" \
        OUTPUT="${ALIGNMENT/.sam/_Sorted.bam}" \
        SORT_ORDER=coordinate \
        CREATE_INDEX=true\
        TMP_DIR="${HOME}"/Scratch/Picard_Tmp
    #	Then remove duplicates
    java -Xmx15g -XX:MaxPermSize=10g -jar\
        "${MARKDUPS}" \
        INPUT="${ALIGNMENT/.sam/_Sorted.bam}" \
        OUTPUT="${ALIGNMENT/.sam/_NoDups.bam}" \
        METRICS_FILE="${ALIGNMENT/.sam/_Metrics.txt}"\
        REMOVE_DUPLICATES=true\
        CREATE_INDEX=true\
        TMP_DIR="${HOME}"/Scratch/Picard_Tmp\
        MAX_RECORDS_IN_RAM=50000
    #   Then add read groups
    java -Xmx15g -XX:MaxPermSize=10g -jar\
        "${ADDRG}" \
        INPUT="${ALIGNMENT/.sam/_NoDups.bam}" \
        OUTPUT="${ALIGNMENT/.sam/_Finished.bam}" \
        RGID="${ALIGNMENT}"\
        RGPL="${PLATFORM}"\
        RGPU="${ALIGNMENT}"\
        RGSM="${ALIGNMENT}"\
        RGLB="${CAPTURE}"_"${ALIGNMENT}"\
        TMP_DIR="${HOME}"/Scratch/Picard_Tmp\
        CREATE_INDEX=True
}

export -f dedup

parallel dedup {} :::: $SAMPLE_INFO

#	Get rid of everything except the finihed BAM file
#find . -type f -not -name '*Finished*' | xargs rm
