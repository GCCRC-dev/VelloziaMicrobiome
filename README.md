# VelloziaMicrobiome - Data and Scripts Repository

This repository contains data and scripts used for the analysis of 16S rRNA gene amplicon and shotgun metagenome sequencing of the *Vellozia* microbiome, in the paper **Seasonal bacterial profiles of *Vellozia* with distinct drought adaptations in the megadiverse campos rupestres (2025)**.


----

## Table of Contents
1. [16S rRNA Gene Amplicon Data](#16s-rRNA-gene-amplicon-data)
2. [Shotgun Metagenome Data](#shotgun-metagenome-data)
3. [Data Records](#data-records)
4. [Contents](#contents)
5. [Usage](#usage)
6. [Citation](#citation)

----

## 16S rRNA Gene Amplicon Data

The amplicon data includes 16S rRNA gene sequences from bulk soil and distinct plant compartments (leaf blade, dry sheath, aerial root, and underground root) of two desiccation-tolerant and two dehydration-avoiding, non-desiccation-tolerant *Vellozia* species. The data were collected across four seasons (beginning and end of the rainy and dry seasons) through 16S rRNA gene sequencing.

For detailed instructions on how to process and analyze the amplicon data, refer to the [Amplicon Data Tutorial](AmpliconData/amplicon_tutorial.md).

----

## Shotgun Metagenome Data

The shotgun metagenome data consists of 38 soil metagenomes collected from both dry and rainy seasons, representing both drought-adaptive strategies.

For detailed instructions on how to process and analyze the shotgun metagenome data, refer to the [Shotgun Metagenome Scripts Manual](ShotgunData/README.md).

----

## Data Records
The raw data required to run the analyses presented here are available in [the NCBI Sequence Read Archive SRP512760](https://identifiers.org/ncbi/insdc.sra:SRP512760).

You can find the Amplicon Sequence Variant (ASV) table with taxonomic classification, confidence score, DNA sequence, and abundance for each sample at [ProcessedAmpliconData](https://github.com/GCCRC-dev/VelloziaMicrobiome/blob/main/AmpliconData/QiimeSupportFiles/ProcessedAmpliconData.rar).


----

## Contents

1. **[AmpliconData](AmpliconData/)** - 16S rRNA gene amplicon data and scripts.
    - **[amplicon_tutorial.md](AmpliconData/amplicon_tutorial.md)** - Tutorial for amplicon data analysis.
    - **[AlphaDiversity](AmpliconData/AlphaDiversity/)** - Script and input files used for Shannon alpha diversity analysis.
    - **[MicrobialComposition](AmpliconData/MicrobialComposition/)** - Script and input files used for microbial composition analysis.
    - **[QiimeSupportFiles](AmpliconData/QiimeSupportFiles/)** - Processed Amplicon Data and files serving as examples, including the manifest import file and metadata used in the tutorial.

2. **[ShotgunData](ShotgunData/)** - Shotgun metagenome data and scripts.
    - **[README.md](ShotgunData/README.md)** - Tutorial for shotgun metagenome analysis.
    - **[concatenate_interleave.sh](ShotgunData/concatenate_interleave.sh)** - Script to combine sequenced samples from different lanes and prepare the interleaved file (input file).
    - **[pipeline.sh](ShotgunData/pipeline.sh)** - Pipeline for processing metagenomic sequence.
    - **[HUMAnN](ShotgunData/HUMAnN/)** - Contains pathway abundance (CPM, unstratified output) from HUMAnN, input files, and a script to perform statistical analysis with MaAsLin2.
        - **[pathway_cpm](ShotgunData/HUMAnN/pathway_cpm/)** - MaAsLin2 directory output.

3. **[LICENSE.txt](LICENSE.txt)** - License for the repository.
4. **[README.md](README.md)** - This file.

----

## Usage

To use the data and scripts in this repository:

1. Clone the repository:
   ```
   $ git clone https://github.com/GCCRC-dev/VelloziaMicrobiome.git
   $ cd VelloziaMicrobiome
   ```

Follow the instructions in the respective README.md files for:

### Example Links
- The link [Amplicon Data Tutorial](AmpliconData/amplicon_tutorial.md) will direct users to the `amplicon_tutorial.md` file inside the `AmpliconData/` folder.
- The link [Shotgun Metagenome Scripts Manual](ShotgunData/README.md) will direct users to the `README.md` file inside the `ShotgunData/` folder.

----

## Citation

   If you use the data or scripts from this repository, please cite our paper (**Publication under review**):
  
 ```
 
   Pinto et al. (2025). Seasonal bacterial profiles of *Vellozia* with distinct drought adaptations in the megadiverse campos rupestres. Scientific Data. 
 ```

For questions or issues, please open an issue in this repository or contact Otavio Pinto at [otaviohenriquebp9@gmail.com].



