#!/bin/bash

set -e

read1=$1
read2=$2
outputdir=$3

module load bowtie2/2.2.7


bowtie2 -p 4 --reorder -q -x /pylon5/mc5frap/kimkh415/713_team_4/data/bowtie_index/GRCh38_index -1 ${read1} -2 ${read2} -S ${outputdir}
