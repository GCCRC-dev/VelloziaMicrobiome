# Data Processing Pipeline

This repository contains a pipeline for processing metagenomic sequence data using tools like BBMap, HUMAnN, and MEGAHIT. The pipeline performs quality filtering, trimming, contamination removal, metagenomic assembly, and microbial community analysis. It is designed to handle interleaved FASTQ files and generate functional and taxonomic profiles for downstream analysis.

----

## Contents
1. [Requirements](#requirements)
2. [Input File Format](#input-file-format)
3. [Script Usage](#script-usage)
4. [Prepare input files with concatenate_interleave script](#prepare-input-files-with-concatenate_interleave-script)

----

## Requirements

To run this pipeline, the following tools must be installed and configured:

### 1. BBMap
BBMap is a suite of tools for processing sequence data, including read filtering and mapping.

- [BBMap Installation Guide](https://sourceforge.net/projects/bbmap/)

### 2. HUMAnN
HUMAnN is used for analyzing functional and taxonomic profiles of microbial communities.

### Notes:
It is advisable to follow this tutorial within the HUMAnN environment.

You can install HUMAnN 3.0 and its utility dependencies with conda:
- [HUMAnN 3.0 tutorial](https://github.com/biobakery/biobakery/wiki/humann3)

```
$ conda install -c biobakery humann
$ conda activate humann
```

- **Required Databases:**
  - Full Chocophlan Database (`HUMANN_N_PATH`)
  - UniRef Protein Database (`HUMANN_P_PATH`)
  
- [HUMAnN User Manual](https://github.com/biobakery/humann).


### 3. MEGAHIT
MEGAHIT is used for metagenomic assembly.

- Install MEGAHIT by following the instructions in the [MEGAHIT GitHub Repository](https://github.com/voutcn/megahit).

### 4. QUAST
QUAST is used for quality assessment of metagenomic assembly.

- [QUAST Installation Guide](https://github.com/ablab/quast)

### 5. Other Dependencies
- **Python**: Required for running QUAST and other scripts.
- **Pigz**: Parallel Gzip for compression (must be installed for parallel compression).
- **GNU Parallel**: Required for running multi-threaded operations.

----

## Input File Format

The input files must be **interleaved FASTQ** files (with `.fastq.gz` extension). The pipeline.sh will process all `.fastq.gz` files found in the working directory. Make sure the input files are named correctly for your datasets.

You can use the script **concatenate_interleave.sh** to combine sequenced samples from different lanes and prepare the interleaved `.fastq.gz` file for use in this pipeline.

### Input File for concatenate_interleave.sh, Example:
- `sample1_L001_R1.fastq.gz` and `sample1_L001_R2.fastq.gz` for lane 1, read 1 and read 2.
- `sample1_L002_R1.fastq.gz` and `sample1_L002_R2.fastq.gz` for lane 2, read 1 and read 2.

### Ouput:
`interleaved_sample1.fastq.gz`

----

## Script Usage

### 1. Clone the Repository or Download the Script

Clone or download the repository to your working directory.

### 2. Modify the Script to Provide Correct Paths

Edit the script to provide the correct paths for tools and databases on your system:

### 3. Set the path to the bbmap scripts and RQCFilter references files
```
BBMAP_PATH="/path/to/bbmap/"
RQCFilter_PATH="/path/to/bbtools/RQCFilterData/"
Quast_PATH="/path/to/metaquast/quast/"
```

### 4. Requisite Database Setup
The RQCFilterData database must be downloaded and installed. This is a 106 GB tar file that includes reference datasets of artifacts, adapters, contaminants, the phiX genome, and host genomes.

To download the database, run:
```
$ mkdir refdata
$ wget http://portal.nersc.gov/dna/microbial/assembly/bushnell/RQCFilterData.tar
$ tar -xvf RQCFilterData.tar -C refdata
$ rm RQCFilterData.tar
```

**This pipeline assumes that the RQCfilter reference files are unzipped and do not have the .gz extension**.

```
$ gunzip /path/to/bbtools/RQCFilterData/*.gz
```

### 5. Set Paths to HUMAnN Databases


 **HUMAnN Databases**:
   - Download the full Chocophlan and UniRef databases:
     ```
     $ humann_databases --download chocophlan full /path/to/humann_dbs
     $ humann_databases --download uniref uniref90_diamond /path/to/humann_dbs
     ```
  
     ```
      HUMANN_N_PATH="/path/to/humann_dbs/full_chocophlan/"
      HUMANN_P_PATH="/path/to/humann_dbs/uniref/"
     ```
The **pipeline.sh** file needs to be edited, and the directory path should be updated to match the corresponding path on your system.

**Make sure all required databases are downloaded and placed at the specified paths.**

### 6. Run the Script

Once everything is set up, run the pipeline in a directory containing your interleaved fastq.gz files:
```
$ bash pipeline.sh
```

What the Script Does:
  - Filters and trims the input data using BBMap.
  - Filters and trims the input data using BBMap.
  - Removes contamination from microbial and human sequences.
  - Assembles the filtered data using MEGAHIT.
  - Performs quality assessment with QUAST.
  - Runs HUMAnN to analyze microbial functional profiles.
  - Processes the output from HUMAnN into a combined, normalized table.

The script will generate several intermediate and final output files:

  - Filtered and processed reads: Stored as intermediate files prefixed with TEMP_.
  - Assembly output: Final contigs stored in directories prefixed with ASSEMBLY_.
  - HUMAnN output: Pathabundance and related data stored in humann_ directories.
  - QUAST output: Final assembly quality assessment results.
  - The processed pathabundance.tsv files will be combined and normalized into humann_combined_pathabundance_cpm.tsv.

### Notes

  - The input files must be in the interleaved FASTQ format (paired-end reads).
  - Ensure that sufficient memory and disk space are available for large files.
  - Use compatible versions of the required tools for optimal execution.
  - Prepare Input Files with concatenate_interleave.sh
  - Sequence Data Concatenation and Interleaving Script
  - This script processes paired-end sequencing data by concatenating samples from different lanes (if applicable) and interleaving the resulting files. It requires BBMap's reformat.sh for interleaving.

----

# Prepare input files with concatenate_interleave script

This script should be used to format the fastq files for running in the pipeline.sh. It processes the data by concatenating samples that were sequenced in different lanes and converting the forward and reverse reads into interleaved format.

----

## Requirements

BBMap must be installed, and the BBMAP_PATH should be set correctly in the script.
Input files must be in .fastq.gz format with paired-end files appropriately named.

### File Naming Format
For the script to function correctly, the input files must follow the naming convention:

- Read 1 files should have _R1 in the filename.
- Read 2 files should have _R2 in the filename.

If sequencing was performed across multiple lanes, the lane identifiers should be included in the filenames (e.g., _L001_, _L002_).
Example filenames:

- sample1_L001_R1.fastq.gz and sample1_L001_R2.fastq.gz for lane 1, read 1 and read 2.
- sample1_L002_R1.fastq.gz and sample1_L002_R2.fastq.gz for lane 2, read 1 and read 2.

----

## How It Works

The script searches for files matching the pattern *_R1*.fastq.gz in the current directory.
It finds the corresponding R2 files by replacing _R1 with _R2 in the filenames.
If lane-specific identifiers are found in the filenames, the script concatenates the files from both lanes (e.g., L001 and L002) before interleaving.
**The samples must have exactly the same name, with only the lane and direction identifiers changed.**

Example Input:
```
sample1_L001_R1.fastq.gz
sample1_L001_R2.fastq.gz
sample1_L002_R1.fastq.gz
sample1_L002_R2.fastq.gz
```

Example Output:
```
interleaved_sample1.fastq.gz
```

Script Usage
Clone or download the repository containing this script.
Set the BBMap path in the script:
```
BBMAP_PATH="/path/to/bbmap/"
```

Place your input files (with the correct naming format) in the working directory.

Run the script:
```
$ bash concatenate_interleave.sh
```

The script will:

Detect lane-specific files and concatenate them.
Interleave the concatenated files and output a new .fastq.gz file.

----

## Notes

The script assumes the input files are paired-end and named according to the convention.
If the script cannot find corresponding R2 files or lane-specific files, it will issue a warning and skip those files.
The final interleaved file will be named interleaved_<sample_name>.fastq.gz.

----

## License
This pipeline is licensed under the [MIT License](https://opensource.org/licenses/MIT).
