#!/bin/bash

set -e
set -x

raw_read1=$1
raw_read2=$2
aln_index=$3
blast_filter=$4
work_dir=$5
num_proc=$6

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

unmapped_read1=${bowtie_outdir}/unmapped_1.fq
unmapped_read2=${bowtie_outdir}/unmapped_2.fq

# Run Bowtie2
if [[ ! -f ${unmapped_read1} ]] || [[ ! -f ${unmapped_read2} ]]
then
	echo Running Bowtie2...
	sh /pylon5/mc5frap/kimkh415/713_team_4/scripts/bowtie.sh ${raw_read1} ${raw_read2} ${aln_index} ${bowtie_outdir} ${num_proc}
else
	echo Unmapped reads already exist in ${work_dir}/bowtie_output. Skipping Bowtie2.
fi

# convert BAM to FASTQ
# module load bedtools
# bedtools bamtofastq -i ${unmapped_bam} -fq ${raw_read1:-3}_unmap1.fq -fq2 ${raw_read2:-3}_unmap2.fq

if [[ ! -f ${unmapped_read1} ]] || [[ ! -f ${unmapped_read2} ]]
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
	sh /pylon5/mc5frap/kimkh415/713_team_4/scripts/trinity.sh ${unmapped_read1} ${unmapped_read2} ${trinity_outdir} ${num_proc}
else
	echo Assembly file already exists. Skipping Trinity.
fi

# transrate
transrate_outdir=${work_dir}/transrate_output
# mkdir -p ${transrate_outdir}
if [[ ! -f ${transrate_outdir}/assemblies.csv ]]
then
	echo Running Transrate
	sh /pylon5/mc5frap/kimkh415/713_team_4/scripts/transrate.sh ${transcript_fa} ${unmapped_read1} ${unmapped_read2} ${transrate_outdir} ${num_proc}
else
	echo Previous Transrate run exists. Skipping Transrate.
fi

# show Transrate score

# BLAST
blast_output=${work_dir}/blast_output.txt

echo Running BLAST
sh /pylon5/mc5frap/kimkh415/713_team_4/scripts/blastn.sh ${transcript_fa} ${blast_output} ${blast_filter}
echo done


