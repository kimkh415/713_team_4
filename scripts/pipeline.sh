#!/bin/bash

set -e

raw_read1=$1
raw_read2=$2
blast_filter=$3
work_dir=$4
num_proc=$5

if [[ ! -d ${work_dir} ]]
then
	mkdir ${work_dir}
fi

# Create and set output directory for bowtie2
mkdir -p ${work_dir}/bowtie_output
bowtie_outdir=${work_dir}/bowtie_output

# Set default number of processors to be 4 if not or wrongly defined.
re='^[0-9]+$'
if [[ -z ${num_proc} || ${num_proc} =~ re ]]
then
	num_proc=4
fi

# Check if input reads exist
if [[ ! -f ${raw_read1} ]] || [[ ! -f ${raw_read2} ]]
then
	echo Check input read files
	exit
fi

bowtie_output=${bowtie_outdir}/unmapped_%.fq

# Run Bowtie2
sh /pylon5/mc5frap/kimkh415/713_team_4/scripts/bowtie.sh ${raw_read1} ${raw_read2} ${bowtie_output} ${num_proc}

# convert BAM to FASTQ
# module load bedtools
# bedtools bamtofastq -i ${unmapped_bam} -fq ${raw_read1:-3}_unmap1.fq -fq2 ${raw_read2:-3}_unmap2.fq

unmapped_read1=${bowtie_outdir}/unmapped_1.fq
unmapped_read2=${bowtie_outdir}/unmapped_2.fq
if [[ ! -f ${unmapped_read1} ]] || [[ ! -f ${unmapped_read2} ]]
then
	echo Something went wrong: Cannot locate unmapped reads after running Botwie.
	exit
fi

# Run Trinity
mkdir -p ${work_dir}/trinity_output
trinity_outdir=${work_dir}/trinity_output

sh /pylon5/mc5frap/kimkh415/713_team_4/scripts/trinity.sh ${unmapped_read1} ${unmapped_read2} ${trinity_outdir} ${num_proc}

transcript_fa=${trinity_outdir}/Trinity.fasta

# transrate
transrate_outdir=${work_dir}/transrate_output
# mkdir -p ${transrate_outdir}
sh /pylon5/mc5frap/kimkh415/713_team_4/scripts/transrate.sh ${transcript_fa} ${unmapped_read1} ${unmapped_read2} ${transrate_outdir} ${num_proc}

# show Transrate score

# BLAST
blast_output=${work_dir}/blast_output.txt

sh /pylon5/mc5frap/kimkh415/713_team_4/scripts/blastp.sh ${transcript_fa} ${blast_output} ${blast_filter}
echo done


