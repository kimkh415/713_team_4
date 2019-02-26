#!/bin/bash

set -e

read1=$1
index=$2
outputdir=$3
numprocessors=$4

module load bowtie2/2.2.7

# /pylon5/mc5frap/kimkh415/713_team_4/data/bowtie_index/GRCh38_index
bowtie2 -p ${numprocessors} -q -x ${index} -U ${read1} --un ${outputdir}/unmapped.fq --quiet > ${outputdir}/alignment.sam
