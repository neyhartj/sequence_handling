# sequence_handling
#### A series of scripts to automate DNA sequence aligning and quality control workflows via list-based batch submission and parallel processing
___
___
## Introduction
### What is `sequence_handling` for?

`sequence_handling` is a series of scripts to automate and speed up DNA sequence aligning and quality control through the use of our workflow outlined here. This repository contains two kinds of scripts: *Shell Scripts* and *Batch Submission Scripts*.

The former group is designed to be run directly from the command line. These serve as partial dependency installers, a way to generate a list for batch submission, and QSub starters. Running any of these scripts without any arguments generates a usage message for more details.

The latter group is designed to run the workflow in batch and in parallel. They use a list of sequences, with full sequence paths, as their input and utilize [_GNU Parallel_](http://www.gnu.org/software/parallel/) to speed up the process. These are the scripts that will find the depth count of the reads, trim off adapter sequences, map the reads back to a reference genome, and run quality control checks along the way.

> **NOTE:** the latter group of scripts and `read_mapping_start.sh` are designed to use the Portable Batch System and run on the [Minnesota Supercomputing Institute](https://www.msi.umn.edu) (MSI). Modifications will need to be made if not using these systems.

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
 - [_SAMTools_](http://www.htslib.org/)
 - [_R_](http://cran.r-project.org/)
 - [_Picard Tools_](http://broadinstitute.github.io/picard/)
 - [_FastQC_](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
 - [_The Burrows-Wheeler Aligner_](http://bio-bwa.sourceforge.net/) (BWA)
 - [_GNU Parallel_](http://www.gnu.org/software/parallel/)

When running these scripts on the Minnesota Supercomputing Institute's (MSI) resources, _R_, _FastQC_, _Picard Tools_, _SAMTools_, BWA, and _GNU Parallel_ are already loaded into the scripts; the only tools need to be downloaded and installed seperately are _Seqqs_, _Sickle_, _Scythe_, and _Bioawk_.

If not running on MSI's resources, all of these dependencies except for _FastQC_, BWA, _Picard Tools_, and _GNU Parallel_ can be installed using `installer.sh`
___

## Shell Scripts

**NOTE: Running any of these scripts without arguments generates a usage message for greater detail about how to use them**

### installer.sh

The `installer.sh` script installs [_Seqqs_](https://github.com/morrelllab.seqqs), [_Sickle_](https://github.com/vsbuffalo/sickle), and [_Scythe_](https://github.com/vsbuffalo/scythe) for use with the `Quality_Triming.sh` script. It also has options for installing [_Bioawk_](https://github.com/lh3/bioawk), [_SAMTools_](http://www.htslib.org/) and [_R_](http://cran.r-project.org/), all dependencies for various scripts within this package.

### sample\_list\_generator.sh

The `sample_list_generator.sh` script creates a list of samples using a directory tree for its searching. This will find **all** samples in a given directory and its subdirectories. Only use this if you are using all samples within a directory tree. `sample_list_generator.sh` is designed to be run from the command line directly.

## read\_counts.sh

The `read_counts.sh` script calls [_Bioawk_](https://github.com/lh3/bioawk) to get accurate counts for read number for a list of samples. Output is written to a tab-delimited file file with sample name drawn from the file name for the list of samples.

### read\_mapping\_start.sh

The `read_mapping_start.sh` script generates a series of QSub submissions for use with the [Portable Batch System](http://www.pbsworks.com/) on MSI's resources. starts a series of [BWA](http://bio-bwa.sourceforge.net/) sessions to map reads back to a reference genome.
___

## Batch Submission Scripts

**NOTE: Each of these scripts contains usage information within the script itself. Furthermore, all values for these scripts are hard-coded into the script itself. Please open each script using your favourite text editor (ex. [_Vim_](http://www.vim.org), [_Sublime Text_](http://www.sublimetext.com), [_Visual Studio Code_](http://code.visualstudio.com), etc.) to read usage information and set values**

### ~~Read_Counts.sh~~

**NOTE: This script has been converted to a shell script. See `read_counts.sh` above.**

### Assess_Quality.sh

The `Assess_Quality.sh` script runs [_FastQC_](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on the command line on a series of samples organized in a project directory for quality control. Our recommendation is using this both before and after quality trimming and before read mapping. This script is designed to be run using the [Portable Batch System](http://www.pbsworks.com/).

### Quality\_Trimming.sh

The `Quality_Trimming.sh` script runs `trim_autoplot.sh` (part of the [_Seqqs_](https://github.com/morrelllab.seqqs) repository on GitHub) on a series of samples organized in a project directory.. In addition to requiring _Seqqs_ to be installed, this also requires [GNU Parallel](http://www.gnu.org/software/parallel/) to be installed on the system. This script is set up to be run using the [Portable Batch System](http://www.pbsworks.com/).

**NOTE: A list of trimmed FastQ files is _NOT_ output by this script. To do so, change to your out directory and run `find \`pwd\` -regex ".*_R[1-2]_trimmed.fq.gz" | sort > samples_trimmed.txt` to get the list; work is being done to get this done automatically**

### ~~Read\_Mapping.sh~~

**NOTE: This script has been redesigned and replaced with `read_mapping_start.sh`, please use that script for read mapping**

Due to parallelization issues with BWA, this script has been converted to a *Shell Script*. This is still dependent on ~~[GNU Parallel](http://www.gnu.org/software/parallel/) and~~ the [Portable Batch System](http://www.pbsworks.com/). Read above for more details.

### SAM\_to\_BAM.sh

The `SAM_to_BAM.sh` script converts the SAM files from read mapping with [BWA](http://bio-bwa.sourceforge.net/) to the BAM format using [_Samtools_](http://www.htslib.org/). The output for this is a sorted BAM file. In addition to converting the files, it will create a list of the output BAM files for use in other scripts.

**NOTE: Working is being done to add read mapping statistics using `samtools flagstat` into this script. This has not been tested, use with caution**

### Coverage\_Map.sh

The `Coverage_Map.sh` script generates coverage maps from BAM files using [_BEDTools_](http://bedtools.readthedocs.org/en/latest/) and [_R_](http://cran.r-project.org/). This map is in text format and is used for making coverage plots. In addition to generating coverage maps, this script will create a list of all the coverage maps generated for use in other scripts.

**NOTE: This script has not been tested, use with caution**

### Plot\_Coverage.sh

The `Plot_Coverage.sh` script creates plots using [_R_](http://cran.r-project.org/) based off of coverage maps. It will generate three plots: one showing coverage across the genome, one showing coverage across exons, and one showing coverage across genes. This script uses `plot_cov.R` to generate the plots.

**NOTE: This script has not been tested, use with caution**

### Deduplication.sh

The `Deduplication.sh` script processess and de-duplicates the SAM files generated from the `read_mapping_start.sh` script. This uses [_Samtools_](http://www.htslib.org/) and [_Picard Tools_](http://broadinstitute.github.io/picard/)

**NOTE: This script has not been tested, use with caution**

___

## TODO

 - ~~Generalize `read_counts.sh` for any project.~~ DONE!
 - Add better list-out methods
 - ~~Fix memory issues with `Read_Mapping.sh`~~ ~~Redesign read mapping scripts~~ DONE!
 -  ~~Add coverage map script to workflow~~ Finish integrating `Coverage_Map.sh` with the rest of the pipeline
 - Get `Plot_Coverage.sh` and `plot_cov.R` integrated into the pipeline
 - Add information about `plot_cov.R` to the README
 - ~~Add script to easily convert SAM files from `Read_Mapping.sh` to BAM files for `Coverage_Map.sh`~~ DONE!
 - Add Deduplication script
 - Add read mapping statistics via `samtools flagstat`
 - keep README updated
