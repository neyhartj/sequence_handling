#!/bin/bash

set -e
set -u
set -o pipefail

module load parallel

#   This script generates a series of QSub submissions for read mapping

usage() {
    echo -e "\
Usage:
" >&2
    exit 1
}

if [ "$#" -lt 1 ]; then
    usage;
fi

case "$1" in
    "map" )
        SCRATCH="$2"
        PROJECT="$3"
        REF_GEN="$4"
        SAMPLE_INFO="$5"
        SETTINGS="mem -t 8 -k 10 -r 1.0 -M -T 85 -O 8 -E 1"
        #   Generate lists of forward and reverse reads that match
        FWD="_R1_trimmed.fq.gz"
        REV="_R2_trimmed.fq.gz"
        grep -E "$FWD" ${SAMPLE_INFO} | sort > ${SCRATCH}/fwd.txt
        FWD_FILE=${SCRATCH}/fwd.txt
        grep -E "$REV" ${SAMPLE_INFO} | sort > ${SCRATCH}/rev.txt
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
            basename "$s" "$FWD" >> "${SCRATCH}"/samples.txt
        done
        #   Date in international format
        YMD=`date +%Y-%m-%d`
        #   Define mapping function
        map() {
            module load bwa
            mkdir -p "${SCRATCH}"/"${PROJECT}"
            bwa "${SETTINGS}" "${REF_GEN}" "$1" "$2" > "${SCRATCH}"/"${PROJECT}"/"$3"_"${PROJECT}"_"${YMD}".sam
        }
        # generate a series of QSub submissions per script
        echo "parallel --xapply map {1} {2} {3} :::: $FWD_FILE :::: $REV_FILE :::: $SAMPLE_NAMES"
        ;;
    "index" )
        module load bwa
        REF_GEN="$2"
        bwa index "${REF_GEN}"
        ;;
    * )
        usage
        ;;
esac
