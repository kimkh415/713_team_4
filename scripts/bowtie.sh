#!/bin/bash

set -e

read1=$1
read2=$2
index=$3
outputdir=$4
numprocessors=$5

module load bowtie2/2.2.7

# /pylon5/mc5frap/kimkh415/713_team_4/data/bowtie_index/GRCh38_index
bowtie2 -p ${numprocessors} -q -x ${index} -1 ${read1} -2 ${read2} --un-conc ${outputdir}/unmapped_%.fq --quiet > ${outputdir}/alignment.sam
