# sequence_handling
#### A series of scripts to automate DNA sequence aligning and quality control workflows via list-based batch submission and parallel processing
___
___
## Introduction
### What is `sequence_handling` for?

`sequence_handling` is a series of scripts to automate and speed up DNA sequence aligning and quality control through the use of our workflow outlined here. This repository contains two kinds of scripts: *Shell Scripts* and *Batch Submission Scripts*.

The former group is designed to be run directly from the command line and should be run before using the *Batch Submission Scripts*. These serve as partial dependency installers and a way to generate a list for batch submission.

The latter group is designed to run the workflow in batch and in parallel. They use a list of sequences, with full sequence paths, as their input and utilize [_GNU Parallel_](http://www.gnu.org/software/parallel/) to speed up the process. These are the scripts that will find the depth count of the reads, trim off adapter sequences, map the reads back to a reference genome, and run quality control checks along the way.

> **NOTE:** the latter group of scripts are designed to use the Portable Batch System and run on the Minnesota Supercomputing Institute. Modifications will need to be made if not using these systems.

### Why use list-based batch submission?

List-based batch submission, first and foremost, allow the workflow to run on multiple samples at once, but be selective about which samples are being used. Sometimes, one may need only certain samples within a group of samples to be run; rather than move reads around, which are large and cumbersome to move, utilizing a list tells our workflow exactly which samples should be piped through our workflow. List format should have the full path to each sample, forward and reverse, in a single column listed. An example is shown below:

>/home/path\_to\_sample/sample\_001\_R1.fastq.gz

>/home/path\_to\_sample/sample\_001\_R2.fastq.gz

>/home/path\_to\_sample/sample\_003_R1.fastq.gz

>/home/path\_to\_sample/sample\_003\_R2.fastq.gz

Note that there could be other samples in `/home/path_to_sample/`, but only samples 001 and 003 will be run through our workflow.

### Why use parallel processing?

Piping one sample alone through this workflow can take over 12 hours to completely run. Most sequence handling job are not dealing with one sample, so the amount of time to run this workflow increases drastically. Traditionally, we get around this by having one workflow per sample. However, this drastically increases the chance for mistakes to be made via simple mistyping. The batch submission allows for the chance of those mistakes to be drastically reduced, but does not take care of the time issue.

Parallel processing decreases the amount of time by running multiple jobs at once and keeping track of which are done, which are running, and which have yet to be run. This workflow, with the list-based batch submissions and parallel processing, both simplifies and quickens the task of aliging and running quality control on DNA sequences.

### Dependencies

This workflow requires the following dependencies:

 - [_Seqqs_](https://github.com/morrelllab.seqqs)
 - [_Sickle_](https://github.com/vsbuffalo/sickle)
 - [_Scythe_](https://github.com/vsbuffalo/scythe)
 - [_Bioawk_](https://github.com/lh3/bioawk)
 - [_Samtools_](http://www.htslib.org/)
 - [_R_](http://www.htslib.org/)
 - [_FastQC_](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
 - The [_Burrows-Wheeler Aligner_](http://bio-bwa.sourceforge.net/) (BWA)
 - [_GNU Parallel_](http://www.gnu.org/software/parallel/)

When running these scripts on the Minnesota Supercomputing Institute's (MSI) resources, _R_, _FastQC_, BWA, and _GNU Parallel_ are already loaded into the scripts; the only tools need to be downloaded and installed seperately are _Seqqs_, _Sickle_, _Scythe_, _Bioawk_, and _Samtools_.

If not running on MSI's resources, all of these dependencies except for _FastQC_, BWA, and _GNU Parallel_ can be installed using `installer.sh`
___

## Shell Scripts
### installer.sh
The `installer.sh` script installs [_Seqqs_](https://github.com/morrelllab.seqqs), [_Sickle_](https://github.com/vsbuffalo/sickle), and [_Scythe_](https://github.com/vsbuffalo/scythe) for use with the `Quality_Triming.sh` script. It also has options for installing [_Bioawk_](https://github.com/lh3/bioawk), [_Samtools_](http://www.htslib.org/) and [_R_](http://www.htslib.org/), all dependencies for various scripts within this package. 
### sample\_list_generator.sh
The `sample_list_generator.sh` script creates a list of samples using a directory tree for its searching. This will find **all** samples in a given directory and its subdirectories. Only use this if you are using all samples within a directory tree. Running it with no arguments will give a detailed usage message, or one can edit the script to have variables hard-coded. `sample_list_generator.sh` is designed to be run from the command line directly.
___

## Batch Submission Scripts
### Read_Counts.sh

The `Read_Counts.sh` script calls _Bioawk_ to get accurate counts for read number for a list of samples. The sample list is currently hard-coded into the script to permit qsub job submission. Output is written to a tab-delimited file file with sample name drawn from the file name for the list of samples.

_Bioawk_ is available through [Github](https://github.com/lh3/bioawk).

### Assess_Quality.sh
The `Assess_Quality.sh` script runs [FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on the command line on a series of samples organized in a project directory for quality control. Our recommendation is using this both before and after quality trimming and before read mapping. This script is designed to be run using the Portable Batch System

### Quality\_Trimming.sh
The `Quality_Trimming.sh` script runs `trim_autoplot.sh` (part of the [_Seqqs_](https://github.com/morrelllab.seqqs) repository on GitHub) on a series of samples organized in a project directory.. In addition to requiring _Seqqs_ to be installed, this also requires [GNU Parallel](http://www.gnu.org/software/parallel/) to be installed on the system. This script is set up to be run using the [Portable Batch System](http://www.pbsworks.com/).


### Read\_Mapping.sh
The `Read_Mapping.sh` scripts uses [BWA](http://bio-bwa.sourceforge.net/) to read map a series of sequences. These scripts are both designed to use the results from `Quality_Trimming.sh` for the read mapping. Both scripts find files organized into a project directory and automatically sort them by sample. `QSub_Read_Mapping_Parallel.sh` uses [_GNU Parallel_](http://www.gnu.org/software/parallel/) to run the read mapping for each sample in parallel. This script designed to be run using the Portable Batch System.
___
## TODO

 - ~~Generalize `read_counts.sh` for any project.~~ DONE!
 - Add better list-out methods
 - Add coverage map script to workflow
 - keep README updated
