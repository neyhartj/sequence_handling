#!/bin/bash

#PBS -l mem=8gb,nodes=1:ppn=8,walltime=8:00:00
#PBS -m abe
#PBS -M user@example.com
#PBS -q lab

set -e
set -u
set -o pipefail

module load parallel

#   This script is a QSub submission script for generating plots based off coverage maps
#   To use, on line 5, change the 'user@example.com' to your own email address
#       to get notifications on start and completion for this script

#   List of text files for plotting
SAMPLE_INFO=

#   Name of Project
PROJECT=

#   Scratch directory for output, 'scratch' is a symlink to individual user scratch at /scratch*
SCRATCH=

#   Directory for sequence handling, needed to call the R script
SEQ_HANDLING_DIR=
PLOT_COV=${SEQ_HANDLING_DIR}/plot_cov.R

#   Other variables, don't need to be user-specified
DATE=`date +%Y-%m-%d`
mkdir -p ${SCRATCH}/${PROJECT}

#   Check if R is installed and in the path
if `command -v Rscript > /dev/null 2> /dev/null`
    then 
        echo "R is installed, OK"
    else
        echo "You need R (Rscript) to be installed and in your \$PATH"
        exit 1
fi

for i in `seq $(wc -l < "${SAMPLE_INFO}")`
do
    s=`head -"$i" "${SAMPLE_INFO}" | tail -1`
    name="`basename $s .coverage.hist.txt`" 
    echo "${name}" >> "${SCRATCH}"/"${PROJECT}"/sample_names.txt
    grep 'all' "$s" > "${SCRATCH}"/"${PROJECT}"/"${name}"_genome.txt
    GENOME="${SCRATCH}"/"${PROJECT}"/"${name}"_genome.txt
    grep 'exon' "$s" > "${SCRATCH}"/"${PROJECT}"/"${name}"_exon.txt
    EXON="${SCRATCH}"/"${PROJECT}"/"${name}"_exon.txt
    grep 'gene' "$s" > "${SCRATCH}"/"${PROJECT}"/"${name}"_gene.txt
    GENE="${SCRATCH}"/"${PROJECT}"/"${name}"_gene.txt
done

find "${SCRATCH}"/"${PROJECT}" -name "*_genome.txt" | sort >> "${SCRATCH}"/"${PROJECT}"/all_genomes.txt
ALL_GENOMES="${SCRATCH}"/"${PROJECT}"/all_genomes.txt
find "${SCRATCH}"/"${PROJECT}" -name "*_exon.txt" | sort >> "${SCRATCH}"/"${PROJECT}"/all_exons.txt
ALL_EXONS="${SCRATCH}"/"${PROJECT}"/all_exons.txt
find "${SCRATCH}"/"${PROJECT}" -name "*_gene.txt" | sort >> "${SCRATCH}"/"${PROJECT}"/all_genes.txt
ALL_GENES="${SCRATCH}"/"${PROJECT}"/all_genes.txt

SAMPLE_NAMES="${SCRATCH}"/"${PROJECT}"/sample_names.txt
OUTDIR="${SCRATCH}/${PROJECT}/"

parallel --xapply Rscript ${PLOT_COV} {1} {2} {3} {4} :::: ${ALL_GENOMES} :::: ${ALL_EXONS} :::: ${ALL_GENES} ::: ${OUTDIR}
