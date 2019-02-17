#!/bin/bash

set -e

raw_read1=$1
raw_read2=$2
work_dir=$3
num_proc=$4

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

echo ${num_proc}

# Check if input reads exist
if [[ ! -f ${raw_read1} ]] || [[ ! -f ${raw_read2} ]]
then
	echo Check input read files
	exit
fi

# Run Bowtie2
echo sh bowtie.sh ${raw_read1} ${raw_read2} ${bowtie_outdir}
touch ${bowtie_outdir}/unmapped_1.fq
touch ${bowtie_outdir}/unmapped_2.fq

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

echo sh trinity.sh ${unmapped_read1} ${unmapped_read2} ${trinity_outdir}
touch ${trinity_outdir}/Trinity.fasta

transcript_fa=${trinity_outdir}/Trinity.fasta

# transrate
transrate_outdir=${output_dir}/transrate_output
echo sh transrate.sh ${transcript_fa} ${unmapped_read1} ${unmapped_read2} ${transrate_outdir}
echo done
# show Transrate score

# BLAST
