#!/bin/bash

set -e

read1=$1
read2=$2
outputdir=$3
module load gcc/5.3.0
module load perl/5.18.4-threads
module load java/jdk8u73
module load bowtie2/2.2.7
module load samtools/1.3
module load jellyfish2/2.2.6
module load salmon/0.9.1
module load blat/v35
module load trinity/2.8.4

Trinity --no_version_check --seqType fq --max_memory 16G --CPU 4 \
  --workdir $LOCAL/trinity_local \
  --output ${outputdir} \
  --left ${read1} \
  --right ${read2}
