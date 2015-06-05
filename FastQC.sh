#!/bin/sh

#PBS -l mem=4000mb,nodes=1:ppn=4,walltime=6:00:00
#PBS -m abe
#PBS -M 
#PBS -q lab

#   Full path to directory where samples are stored
#       Requires quotes around directory path
SAMPLE_DIR=""

#   File extension
#       Example
#           *.txt.gz
#           *.fa.gz
#       Requires astrick for globbing
EXT=*.txt.gz

#   Full path to out directory
#       Requires quotes around directory path
OUT=""

#   Load FastQC Module
module load fastqc

#   Load Parallel Module
module load parallel

#   Run FastQC in parallel
find $SAMPLE_DIR -name $EXT | parallel "fastqc {} -o ${OUT}"
