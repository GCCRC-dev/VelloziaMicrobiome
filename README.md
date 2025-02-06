# VelloziaMicrobiome - Data and Scripts Repository

This repository contains data and scripts used for the analysis of 16S rRNA gene amplicon and shotgun metagenome sequencing of the Vellozia microbiome, as published in the paper **Seasonal bacterial profiles of Vellozia with distinct drought adaptations in the megadiverse campos rupestres (2025)**.

---

## Table of Contents
1. [16S rRNA Gene Amplicon Data](#16s-rRNA-gene-amplicon-data)
2. [Shotgun Metagenome Data](#shotgun-metagenome-data)
3. [Repository Structure](#repository-structure)
4. [Usage](#usage)
5. [Citation](#citation)

---

## 16S rRNA Gene Amplicon Data

The amplicon data includes 16S rRNA gene sequences from bulk soil and distinct plant compartments (leaf blade, dry sheath, aerial root, and underground root) of two desiccation-tolerant and two dehydration-avoiding, non-desiccation-tolerant *Vellozia* species. The data were collected across four seasons (beginning and end of the rainy and dry seasons) through 16S rRNA gene sequencing.

For detailed instructions on how to process and analyze the amplicon data, refer to the [Amplicon Data Tutorial](AmpliconData/amplicon_tutorial.md).

---

## Shotgun Metagenome Data

The shotgun metagenome data consists of 38 soil metagenomes collected from both dry and rainy seasons, representing both drought-adaptive strategies.

For detailed instructions on how to process and analyze the shotgun metagenome data, refer to the [Shotgun Metagenome Scripts](ShotgunData/README.md).

---

## Contents

VelloziaMicrobiome/
├── AmpliconData/ # 16S rRNA gene amplicon data and scripts
│ ├── amplicon_tutorial.md # Tutorial for amplicon data analysis
│ ├── AlphaDiversity/ # Script and input files used to Shannon alpha diversity analysis.
│ ├── MicrobialComposition/ # Script and input files used to perform microbial composition analysis.
│ └──QiimeSupportFiles/ # Files that serve as examples, including manifest importing file and metadata, used in the tutorial.
├── ShotgunData/ # Shotgun metagenome data and scripts
│ ├── README.md # Tutorial for shotgun metagenome analysis
│ ├── concatenate_interleave.sh # Combine sequenced samples from different lanes and prepare the interleaved (input file)
│ ├── pipeline.sh # Pipeline for processing metagenomic sequence
│ └──HUMAnN/ # It contains pathway abundance (CPM, unstratified output) from HUMAnN, input files, and a script to perform statistical analysis with MaAsLin2.
├── LICENSE # License for the repository
└── README.md # This file

---

## Usage

To use the data and scripts in this repository:

1. Clone the repository:
   ```bash
   git clone https://github.com/GCCRC-dev/VelloziaMicrobiome.git
   cd VelloziaMicrobiome

Follow the instructions in the respective README.md files for:

### Example Links
- The link `[Amplicon Data Tutorial](AmpliconData/amplicon_tutorial.md)` will direct users to the `amplicon_tutorial.md` file inside the `AmpliconData/` folder.
- The link `[Shotgun Metagenome Scripts](ShotgunData/README.md)` will direct users to the `README.md` file inside the `ShotgunData/` folder.

Citation

If you use the data or scripts from this repository, please cite our paper:

Pinto et al. (2025). Seasonal bacterial profiles of Vellozia with distinct drought adaptations in the megadiverse campos rupestres. Scientific Data, DOI: XXXXXX.

For questions or issues, please open an issue in this repository or contact [Otavio Pinto] at [otaviohenriquebp9@gmail.com].

