#!/bin/env bash

#PBS -l mem=12gb,nodes=1:ppn=1,walltime=4:00:00 
#PBS -m abe 
#PBS -M user@example.com
#PBS -q lab

set -e
set -u
set -o pipefail

module load parallel

#   Path to BEDTools
#   On MSI, loading the module works
#   Otherwise, have path to BEDTools directory
module load bedtools
#BEDTOOLS=

#   Scratch directory for output, 'scratch' is a symlink to individual user scratch at /scratch*
SCRATCH=

#   Name of Project
#       Please wrap this in quotes
#       Example: "SCN"
PROJECT=

#   List of BAM files for coverage mapping
SAMPLE_INFO=

#   Annotation file to be considered
#       This is the reference .bed or .gff file
REF_ANN=${HOME}/Shared/Datasets/Annotations/Soybean_Cyst_Nematode/Heterodera_glycines_OP25_gene_models.gff

DATE=`date +%Y-%m-%d`

#   List of sample names
for i in `seq $(wc -l < "${SAMPLE_INFO}")`
do
    s=`head -"$i" "${SAMPLE_INFO}" | tail -1`
    basename "$s" .bam >> "${SCRATCH}"/sample_names.txt
done

SAMPLES=${SCRATCH}/sample_names.txt

#   check if R is installed and in the path
if `command -v Rscript > /dev/null 2> /dev/null`
    then 
        echo "R is installed, OK"
    else
        echo "You need R (Rscript) to be installed and in your \$PATH"
        exit 1
fi

cd $SCRATCH

cat ${SAMPLES} | parallel "mkdir {} "

parallel -- xapply "bedtools coverage -hist -abam {1} -b ${REF_ANN} > {2}/Sample_{2}_${PROJECT}_${DATE}.coverage.hist.txt" :::: ${SAMPLE_INFO} :::: ${SAMPLES}
