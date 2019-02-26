#!/bin/bash

set -e
# set -x

raw_read=$1
aln_index=$2
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
if [[ ! -f ${raw_read} ]]
then
	echo Check input read file
	exit
fi

unmapped_read1=${bowtie_outdir}/unmapped.fq

# Run Bowtie2
if [[ ! -f ${unmapped_read1} ]]
then
	echo Running Bowtie2...
	sh scripts/bowtie_single.sh ${raw_read} ${aln_index} ${bowtie_outdir} ${num_proc}
else
	echo Unmapped reads already exist in ${work_dir}/bowtie_output. Skipping Bowtie2.
fi

# convert BAM to FASTQ
# module load bedtools
# bedtools bamtofastq -i ${unmapped_bam} -fq ${raw_read1:-3}_unmap1.fq -fq2 ${raw_read2:-3}_unmap2.fq

if [[ ! -f ${unmapped_read} ]]
then
	echo Something went wrong: Cannot locate unmapped reads after running Botwie.
	exit
fi

# Run Trinity
mkdir -p ${work_dir}/trinity_output
trinity_outdir=${work_dir}/trinity_output
transcript_fa=${trinity_outdir}/Trinity.fasta

if [[ ! -f ${transcript_fa} ]]
then
	echo Running Trinity
	sh scripts/trinity_single.sh ${unmapped_read} ${trinity_outdir} ${num_proc}
else
	echo Assembly file already exists. Skipping Trinity.
fi

echo Transrate does not accept single-end reads. Skipping Transrate.

# BLAST
blast_output=${work_dir}/blast_output.csv

echo Running BLAST
sh scripts/blastn.sh ${transcript_fa} ${blast_output} ${blast_filter}
echo done


