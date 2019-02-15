#!/bin/bash

set -e

raw_read1=$1
raw_read2=$2
output_dir=$3

# bowtie2
sh bowtie.sh ${raw_read1} ${raw_read2} ${output_dir}
alignment=

# convert BAM to FASTQ
module load bedtools
bedtools bamtofastq -i ${unmapped_bam} -fq ${raw_read1:-3}_unmap1.fq -fq2 ${raw_read2:-3}_unmap2.fq

unmapped_read1=
unmapped_read2=

# trinity
sh trinity.sh ${unmapped_read1} ${unmapped_read2}

# transrate


# BLAST
