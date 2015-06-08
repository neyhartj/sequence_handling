#!/bin/sh

#PBS -l mem=4000mb,nodes=1:ppn=4,walltime=6:00:00
#PBS -m abe
#PBS -M 
#PBS -q lab

set -e
set -u
set -o pipefail

module load parallel

#   List of samples to be processed
#   Need to hard code the file path for qsub jobs
SAMPLE_INFO=

#   Full path to out directory
#       Requires quotes around directory path
OUT=""

#   Load FastQC Module
module load fastqc

#   Run FastQC in parallel
cat ${SAMPLE_INFO} | parallel "fastqc {} -o ${OUT}"
