#!/bin/bash

set -e

read1=$1
read2=$2
outputdir=$3
module load trinity

trinity --no_version_check --seqType fq --max_memory 16G --CPU 4 \
  --workdir $LOCAL/trinity_local \
  --output ${outputdir} \
  --left ${read1} \
  --right ${read2}
