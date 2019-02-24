#!/bin/bash
set -e
assembly=$1
left=$2
right=$3
output=$4
threads=$5

module load salmon/0.9.1
/pylon5/mc5frap/kimkh415/713_team_4/bin/transrate/transrate --assembly ${assembly} --left ${left} --right ${right} --output ${output} --threads ${threads}
