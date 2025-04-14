# rnaseq

**Description**

Welcome to the RNAseq module for Omicsflow. This module is designed to perform a differential expression analysis on paired end illumina RNAseq data. The expected input for this pipeline is raw fastq files produced by an illumina sequecning system. Please refer to the "file_structure" document to learn how to organize your files prior to pipeline execution becasue the pipeline expects to find files with specific names in certain locations. Both differential gene expression and differential transcript expression analyses will be performed and outputted as comma separated value (csv) files. The required files to run this module are outlined below.

**Required Files**

An example for each of these files is shown in the "example_files" sub-directory

adapter.fa - The adapter.fa file provides the forward and reverse adapters to be trimmed from the raw fastq files 
ballgown.txt - This file provides information for the differential expression analysis by separating the samples into control and treatment groups
info.tsv - This file provides library and barcode information for each of the samples
nextflow.config - This file can provide a lot of different information for the pipeline execution. Please consult nextflow documentation to understand the different parameters that can be specified in the config document. At minimum, for pipeline execution, the species and reference version should be noted

**Additional details**

The raw paired-end sequence files as well as the reference sequence for alignment should be available as shown in the "file_structure" document.

**Pipeline steps**
