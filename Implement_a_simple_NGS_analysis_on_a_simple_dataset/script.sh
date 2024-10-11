#!/bin/bash

# Create a directory for the development of the activity

mkdir stage4
cd stage4

# Download the files we will need

wget https://zenodo.org/records/10426436/files/ERR8774458_1.fastq.gz?download=1

wget https://zenodo.org/records/10426436/files/ERR8774458_2.fastq.gz?download=1

wget https://zenodo.org/records/10886725/files/Reference.fasta?download=1

# Quality control
# Create a directory to save the results of the quality control

mkdir results_fastqc

# Rename the files we downloaded

mv ERR8774458_1.fastq.gz?download=1 ERR8774458_1.fastq.gz
mv ERR8774458_2.fastq.gz?download=1 ERR8774458_2.fastq.gz
mv Reference.fasta?download=1 Reference.fasta

# List the documents that have just been created

ls -l

# Unzip the files we just downloaded

zcat ERR8774458_1.fastq.gz | head
zcat ERR8774458_2.fastq.gz | head

# Create and activate a conda environment
# Run FastQC for quality control

fastqc ERR8774458_1.fastq.gz -o results_fastqc
fastqc ERR8774458_2.fastq.gz -o results_fastqc

# Create a folder to save the results of the filtering

mkdir results_fastp

# Execute sequence filtering by quality and length

fastp -i ERR8774458_1.fastq.gz -I ERR8774458_2.fastq.gz -o results_fastp/cleaned_R1.fastq -O results_fastp/cleaned_R2.fastq -q 20 -l 50 -h results_fastp/fastp_report.html

# Perform the mapping

mkdir bwa

bwa index Reference.fasta 

bwa mem -Y -M -t 32 -o bwa/Muestra1.sam Reference.fasta results_fastp/cleaned_R1.fastq results_fastp/cleaned_R2.fastq

# To visualize it, we create a BAM file

samtools view -Sb bwa/Muestra1.sam --threads 32 -o bwa/Muestra1".bam"

# Sort by similarity

samtools sort bwa/Muestra1*bam -o bwa/Muestra1"_sorted.bam"

# Create an index for the BAM file

samtools index bwa/Muestra1"_sorted.bam"

# Variant calling

freebayes -f Reference.fasta bwa/Muestra1_sorted.bam > variantes.vcf
could not open Reference.fasta

# Use an IGV program to analyze the data