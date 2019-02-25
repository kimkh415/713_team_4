# **User Manual for <u>Id</u>entifying <u>Pa</u>thogen <u>T</u>ranscripts in <u>H</u>uman RNA-seq Data (ID-PATH)** 
#### Group 4: Kwanho Kim, Aaron Seibel, Haonan Sun, Carlos Venegas, Yuheng Zhang


## Description
We introduce a pipeline to isolate foreign reads from human RNA-sequencing data and identify their sources, which can potentially be pathogens infecting the host. While the detailed explanation of our pipeline can be found in our final report, a brief description of the mechanism is as follows. ID-PATH first isolates `unmapped reads` by aligning input sequence files onto the human reference transcriptome `GRCh38` using bowtie v2.2.7. It then assembles isolated reads using Trinity v2.8.4, leveraging its ability to assemble transcripts without a reference transcriptome (_de novo_ method). The quality of the assembly will be analyzed using Transrate v1.0.3 (we modified Transrate slightly to invoke Salmon v0.9.1 instead of Salmon v0.6.0, used by default). Lastly, foreign transcripts in the sample are identified by comparing the nucleotide similarity against existing transcripts in database using BLAST v2.7.1. 

## Workflow

![](https://i.imgur.com/NAVgVwZ.png)


## Installation
ID-PATH can be found [here](https://github.com/kimkh415/713_team_4) on GitHub.
```
git clone https://github.com/kimkh415/713_team_4.git
```
Cloning this repository will copy all scripts necessary to run ID-PATH. Make sure the `scripts` directory of this repository contains the following files:
* <strong>blastn.sh</strong>
* <strong>bowtie.sh</strong>
* <strong>pipeline.sh</strong> - main script to be invoked
* <strong>transrate.sh</strong>
* <strong>trinity.sh</strong>


## Dependencies

ID-PATH uses a number of open source tools. We provide link to the installation page of each dependency for users to setup prior to running ID-PATH.

* `Bowtie2`: an ultrafast and memory-efficient tool for aligning sequencing reads to long reference sequences - [manual](http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml), [latest version](https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.3.4.3)
* `Trinity`: RNA-Seq de novo transcriptome assembly - [Installation](https://github.com/trinityrnaseq/trinityrnaseq/wiki/Installing-Trinity), [more information](https://github.com/trinityrnaseq/trinityrnaseq/wiki)
* `Transrate`: software for de-novo transcriptome assembly quality analysis - [installation](http://hibberdlab.com/transrate/installation.html)
* `BLAST`: Basic Local Alignment Search Tool - [installation](https://www.ncbi.nlm.nih.gov/books/NBK279671/), [more information](https://blast.ncbi.nlm.nih.gov/Blast.cgi)

### Bowtie2

Bowtie2 is the very first package in this pipeline to align raw reads acquired from SRA database to host reference genome. The human reference genome GRCh38 is used by default. 

Potential foreign reads will be store in the user-specified file after bowtie2 filter out all the mapped reads towards human genome for following steps.

You can download the latest version of Bowtie2 using the specified link above.

ID-PATH invokes bowtie2 using the following command

```
bowtie2 -p [int] -q -x [path/to/index] -1 [path/to/read1.fq] \
    -2 [path/to/read2.fq] --un-conc [output_directory]/unmapped_%.fq \
    --quiet > [output_directory]/alignment.sam
```

where `-p` specifies number of processors, `-x` locates the index built, `-1` and `-2` are input paired-end reads that are in FASTQ format, `--un-conc` tells `bowtie` to output unmapped reads as 

### Trinity

Trinity is a software for _de novo_ transcript assembly that assembles reads into transcripts without using reference transcriptome. 

ID-PATH invokes Trinity using the following command

```
module load gcc/5.3.0
module load perl/5.18.4-threads
module load java/jdk8u73
module load bowtie2/2.2.7
module load samtools/1.3
module load jellyfish2/2.2.6
module load salmon/0.9.1
module load blat/v35
module load trinity/2.8.4

Trinity --no_version_check --seqType fq --max_memory 16G --CPU [int] \
  --trimmomatic \
  --workdir ./trinity_work_dir \
  --output [outputdir] \
  --left [read1] \
  --right [read2]
```

where `--no_version_check` avoids version check prior to execution, `--seqType` sets the input file format of the reads (currently fixed to `FASTQ`), `--max_memory` limits the memory usage, `--CPU` specifies the number of processors, `--trimmomatic` filters reads according to their quality, `--workdir` is the temporary working directory, `--output` specifies where to output the resulting assembly along with other measurements, and `--left` and `--right` specifies input reads.

### Transrate

Transrate is a tool for evaluating the quality of a _de novo_ transcriptome assembly without a reference genome. The `Salmon` that comes with `Transrate` is v0.6.0 which is outdated and contains a parameter that is known for its potential to cause bugs (`--useFSPD`). Thus, we modified the script `Transrate` uses to run `Salmon` so that it uses v0.9.1 and updated bias correction parameters (`--seqBias` and `--gcBias`) to be used.

```
bin/transrate/transrate --assembly [path/to/assembly.fasta] \
    --left [path/to/unmapped_read1.fq] --right [path/to/unmapped_read2.fq] \
    --output [output_directory] --threads [int]
```

`--threads` specifies the number of processors to be used.

### BLAST
BLAST is a local alignment search tool that finds regions of similarity between nucleotide or amino acid sequences and calculates their statistical significance.

In this pipeline, we are running BLAST via command line, using local NCBI databases already installed in Bridges. 

The following command performs a BLAST search against the nt database, looking for alignments of the `query` file (in FASTA format). The search is restricted to only the specified GI's listed in the `gilist` file, and the best 5 alignments will be reported in the `output` file in CSV format.

```
blastn -db nt -gilist [gilist] -query [query] -max_hsps 5 -out [output] -outfmt 10
```

The`BLAST` output will contain these columns (in order):

* Query Seq-id: ID of the Query Sequence.
* Subject Seq-id: ID of the Subject Sequence.
* Percent Identical: similarity percentage between query and subject sequences.
* Alignment length: number of nucleotides correctly aligned.
* Mismatches: number of mismatches.
* Number of gap openings 
* Start of alignment in query
* End of alignment in query
* Start of alignment in subject
* End of alignment in subject
* Expect value: lower is better.
* Score: total score of alignment.




## Getting Started with ID-PATH

Since building the index for human reference transcriptome can be time consuming, we provide prebuilt index for `GRCh38` reference for those who have access to PSC's Bridges. To follow this demonstration, the user requires read access to `/pylon5/mc5frap/kimkh415` directory. For those who have access to Bridges but no read access to the above directory, email kwanhok[at]andrew.cmu.edu.

1. Clone IP-PATH to a directory of your choice.
2. Find paired-end RNA-seq read set (in FASTQ format) with potential eukaryotic pathogen infection.
3. Navigate into the cloned directory (you should find `bin` and `scripts` directories)
5. Run IP-PATH using the following command

```
sh scripts/pipeline.sh [path/to/read1.fastq] [path/to/read2.fastq] \
    [path/to/index_prefix] [path/to/GI_file] [output/path] [number of processors]
```

The detailed explanation of each ID-PATH parameter can be found in the [ID-PATH Parameters](#ID-PATH-Parameters) section.

## Demonstration
If you are interested in demonstrating the performance ID-PATH or reproduce the results of our validation experiment, you can sequentially invoke the following commands. This demonstration uses simulated RNA-seq read set generated from a bacteria, _Clostridium cellulosi_, using [NEAT](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0167047). Since we are aligning reads from bacteria transcripts onto human reference, we should recover majority of the initial reads as `unmapped`. Then the assembly should recover the template bacterial transcripts used in simulation. Thus, the goal of this demonstration is to provide a justification of the effectiveness of ID-PATH.

Parameters / Data locations
* read1: `/pylon5/mc5frap/kimkh415/713_team_4/data/demo/sim_read1.fq`
* read2: `/pylon5/mc5frap/kimkh415/713_team_4/data/demo/sim_read2.fq`
* index: `/pylon5/mc5frap/kimkh415/713_team_4/data/bowtie_index/GRCh38_index`
* GI_file: `/pylon5/mc5frap/kimkh415/713_team_4/data/reference/gi_files/gilist_clostridium.gi`

Firstly, there are processes in our pipeline that requires fair amount of memory (greater than 4.5 GB which is a memory limit when using a single core in Bridges). Thus, invoke `interact` as follows:
```
interact -p RM-shared --ntasks-per-node=8 -t 05:00:00
```

Once you get cores allocated to perform this demonstration, we are now set to run ID-PATH. Note that`pipeline.sh` must be invoked in its super directory, so navigate into the directory you cloned.

Then, using the above specified parameters, execute the following command.
```
sh scripts/pipeline.sh [read1] [read2] \
    [index] [GI_file] ID-PATH_results 8
```

This may take up to several hours.

When ID-PATH completes, you will find a `blast_output.csv` under `ID-PATH_results` with similar transcripts found. 

The first few lines of the demonstration result CSV file looks like the following.
![output screenshot](https://i.imgur.com/8NklOdO.png)

For those of you who are looking for a quick method (run in few seconds) to check whether it runs or not (without generating meaningful output), you should use these reads keeping all other parameters the same.

* read1: `/pylon5/mc5frap/kimkh415/713_team_4/data/demo/demo_1.fastq`
* read2: `/pylon5/mc5frap/kimkh415/713_team_4/data/demo/demo_2.fastq`

Since there are only 1000 reads in each `FASTQ` file, allocating multiple nodes is not necessary.


## ID-PATH Parameters

ID-PATH takes in six parameters in the following order.

* Read1 - first input paired-end reads in fastq format ( e.g. `<YOUR_DIR>/read1.fastq`)

* Read2 - second input paired-end reads in fastq format ( e.g. `<YOUR_DIR>/read2.fastq`)
* Reference index - the built bowtie2 index with directory specified ( e.g. `<YOUR_DIR>/GRCh38_index` or other prebuilt reference prebuilt in Bowtie2)
* Blast Filter - The GI file of target species ( e.g. `<YOUR_DIR>/SPECIES_NAME.gi`)
* Output directory - The output directory where you want to store the result ( e.g. `<YOUR_DIR>/NEW_DIR_NAME`)
* Number of processors - Max integer number of processors you want to allocate ( e.g. `8`)



## Additional Notes

Take caution when you think the sample is infected with prokaryotic pathogen. Most RNA-seq is performed using oligo-dT beads that hybridize to the tails to isolate the mRNA. This is done to remove the much more abundant ribosomal RNA and tRNA from the sample. Since prokaryotes do not add polyA tails to their mRNA, your sample may not contain the information that you are looking for.

