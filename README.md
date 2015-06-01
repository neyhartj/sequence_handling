# sequence_handling

The 'read_counts.sh' script calls bioawk to get accurate counts for read number for a list of samples. The sample list is currently hard-coded into the script to permit qsub job submission. Output is written toa tab-delimited file file with sample name drawn from the file name for the list of samples.

Bioawk is available through [Github](https://github.com/lh3/bioawk).
 
