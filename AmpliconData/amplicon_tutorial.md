# Amplicon Sequence Processing Tutorial

This tutorial provides a step-by-step guide to processing amplicon sequences using fastp, QIIME 2, and DADA2. It covers quality control, sequence trimming, denoising, taxonomy classification, and exporting data for downstream analysis. By the end of this tutorial, you will have a clean feature table, representative sequences, and taxonomy assignments ready for further analysis.


## Requirements

Before running the pipeline, ensure the following dependencies are installed:

Ensure that your QIIME 2 environment (e.g., `qiime2-2023.9`) is activated before running the script.

Modify the script to use the correct file paths for your input data.

- **Software**:
  - QIIME 2 (version 2023.9 or later)
  - fastp (for quality control)
  - biom (for manipulating feature tables)
  - conda (for environment management)
- **Data**:
  - Paired-end sequencing data (FASTQ files)
  - Metadata files [metadata file](https://docs.qiime2.org/2023.9/tutorials/metadata/)
  - Manifest file [manifest file](https://docs.qiime2.org/2023.9/tutorials/importing/)
- **System**:
  - At least 16 GB of RAM (32 GB recommended for large datasets)
  - Multi-core processor (for parallel processing)

## Workflow Overview
1. Quality control with fastp
2. Import data into QIIME 2
3. Sequence trimming with cutadapt
4. Denoising with DADA2
5. Taxonomy classification and filtering
6. Grouping samples and removing singletons
7. Exporting data for downstream analysis
8. Visualization


Modifications: Feel free to modify the script based on your dataset, such as adjusting parameters for qiime dada2 denoise-paired, qiime cutadapt trim-paired, etc.
Export Formats: Export formats like .qza, .biom, .qzv are all used in QIIME 2 for different steps of analysis.

---

## Step-by-Step Process

## Step 1: Quality Control with fastp
This step performs quality control on paired-end sequences using fastp. It trims low-quality bases, and removes adapters.

```
fastp \
    -i "$INPUT_R1" \
    -I "$INPUT_R2" \
    -o "$OUTPUT_R1" \
    -O "$OUTPUT_R2" \
    -q 20 \
    -l 50 \
    --thread 10
```

## Step 2: Import data into QIIME 2
After quality control, the next step is to import your data into QIIME 2:

```
conda activate qiime2-2023.9

qiime tools import  \
 --type 'SampleData[PairedEndSequencesWithQuality]'  \
 --input-path manifest.txt  \
 --output-path amplicon.qza  \
 --input-format PairedEndFastqManifestPhred33
 ```

## Step 3: Sequence trimming with cutadapt
This step trims the sequences using cutadapt to remove primer sequences:

```
qiime cutadapt trim-paired  \
 --i-demultiplexed-sequences amplicon.qza  \
 --p-front-f ACWYCTRCGGGRGGCWGCA  \
 --p-front-r GGACTACHVGGGTWTCTAAT  \
 --p-discard-untrimmed  \
 --o-trimmed-sequences amplicon_cutadapt.qza  \
 --p-cores 15
 ```

Cutadapt visualization results:

```
qiime demux summarize  \
 --i-data amplicon_cutadapt.qza  \
 --o-visualization amplicon_cutadapt.qzv
 ```

## Step 4: Denoising with DADA2
Use the dada2 plugin in QIIME 2 for denoising:

```
qiime dada2 denoise-paired  \
 --i-demultiplexed-seqs amplicon_cutadapt.qza  \
 --p-trim-left-f 0  \
 --p-trim-left-r 0  \
 --p-trunc-len-f 225  \
 --p-trunc-len-r 225  \
 --p-max-ee-f 3.0  \
 --p-max-ee-r 5.5  \
 --p-n-threads 30  \
 --o-representative-sequences rep-seqs-dada2.qza  \
 --o-table table-dada2.qza  \
 --o-denoising-stats stats-dada2.qza
 ```

Dada2 visualization stats:

```
qiime metadata tabulate  \
 --m-input-file stats-dada2.qza  \
 --o-visualization stats-dada2.qzv
 ```

## Step 5: Taxonomy classification and filtering
After denoising, classify sequences and filter out unwanted taxa:

```
qiime feature-classifier classify-sklearn  \
 --i-classifier silva-138-99-nb-classifier.qza  \
 --i-reads rep-seqs-dada2.qza  \
 --o-classification taxonomy.qza
 ```

Database can be found at: QIIME 2 Data Resources [Silva 138 SSURef NR99](https://docs.qiime2.org/2023.9/data-resources/).

```
qiime taxa filter-table  \
 --i-table table-dada2.qza \
 --i-taxonomy taxonomy.qza  \
 --p-exclude d__Eukaryota,Unassigned,Chloroplast,Mitochondria \
 --p-mode contains  \
 --o-filtered-table table-dada2_filtered.qza
 ```

## Step 6: Grouping samples and removing singletons
Group samples based on metadata and remove singletons from data:

```
qiime feature-table group  \
 --i-table table-dada2_filtered.qza  \
 --p-axis sample --m-metadata-file metadata.tsv  \
 --m-metadata-column Sample_number  \
 --p-mode 'sum'  \
 --o-grouped-table table-dada2_filtered_group.qza
 ```

Remove singletons:

```
qiime feature-table filter-features \
  --i-table table-dada2_filtered_group.qza \
  --p-min-frequency 2 \
  --o-filtered-table table-dada2_filtered_group_singleton.qza
```

Dada2 table visualization:

```
qiime feature-table summarize \
  --i-table table-dada2_filtered_group_singleton.qza \
  --o-visualization table-dada2_filtered_group_singleton.qzv \
  --m-sample-metadata-file metadata_2.tsv
```

Taxonomy bar plot:

```
qiime taxa barplot  \
 --i-table table-dada2_filtered_group_singleton.qza  \
 --i-taxonomy taxonomy.qza  \
 --m-metadata-file metadata_2.tsv  \
 --o-visualization barplot.qzv
```

## Step 7: Exporting data for downstream analysis
Export the data for further analysis or use with other tools:

```
qiime tools export  \
 --input-path rep-seqs-dada2.qza  \
 --output-path rep-seqs-dada2
```
```
qiime tools export  \
 --input-path taxonomy.qza  \
 --output-path taxonomy
```

```
qiime tools export  \
 --input-path table-dada2_filtered_group_singleton.qza  \
 --output-path table-dada2_filtered_group_singleton
```

Additionally, you can convert the biom file to a tab-delimited format for other tools:

```
cd table-dada2_filtered_group_singleton
biom convert -i feature-table.biom -o feature-table.txt --to-tsv
```

The information present in the exported files from this section can be found combined in the [ProcessedAmpliconData](https://github.com/GCCRC-dev/VelloziaMicrobiome/blob/main/AmpliconData/QiimeSupportFiles/ProcessedAmpliconData.rar).

---

## Step 8: Visualization
Data can also be exported from the ´barplot.qzv´ file at QIIME 2 View.

Use QIIME 2's view command to visualize the output:

```
qiime tools view *.qzv
```
or visit: [QIIME 2 View](https://view.qiime2.org/)

---

## Conclusion
By following this tutorial, you have successfully processed amplicon sequences from raw FASTQ files to a clean feature table and taxonomy assignments. These outputs are now ready for downstream analysis, such as alpha/beta diversity analysis or differential abundance testing.

---

## License
This tutorial is licensed under the [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).
