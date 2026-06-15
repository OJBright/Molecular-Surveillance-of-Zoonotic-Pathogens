# Metagenomic Surveillance of Zoonotic Pathogens at the Human-Wildlife Interface.

## Overview
This repository contains bioinformatics scripts and analysis code for a shotgun metagenomics study screening for zoonotic pathogens in human blood samples collected from communities living at the boundaries of a National Park in Uganda.

Communities at the MFNP boundary share ecological interfaces with wildlife, including habitat, water sources, and parasites making them uniquely vulnerable to zoonotic disease spillover. This study provides the first molecular surveillance data for this high-risk human-wildlife interface population.

---

## Study Design
- **Sample type:** Human blood
- **Total samples:** 27 paired-end samples (54 files)
- **Sequencing platform:** Illumina NovaSeq X (100bp paired-end)
- **Study site:** (Private)

---

## Target Pathogens
| Class | Pathogens |
|-------|-----------|
| Bacterial | *Leptospira*, *Brucella*, *Coxiella burnetii*, *Mycobacterium bovis*, *Borrelia*, *Francisella tularensis* |
| Viral | Hantaviruses, Lyssavirus, Hepatitis E, Coronaviruses, Flaviviruses |
| Parasitic | *Toxoplasma gondii*, *Cryptosporidium*, *Giardia* |
| Fungal | *Histoplasma capsulatum*, *Cryptococcus gattii* |

---

## Pipeline

```
Raw Reads → QC Check → Quality Trimming → Host Depletion → Taxonomic Classification → Abundance Estimation → Diversity Analysis → Visualization
```

### Tools Used
| Step | Tool | Version |
|------|------|---------|
| Quality Check | FastQC + MultiQC | - |
| Quality Trimming | fastp | - |
| Host Depletion | Bowtie2 (hg38 no-alt) | - |
| Taxonomic Classification | Kraken2 (PlusPF database) | 2.1.3 |
| Abundance Estimation | Bracken | - |
| Diversity Analysis | R (phyloseq, vegan) | 4.5.3 |
| Visualization | R (ggplot2, ComplexHeatmap) | - |

---

## Repository Structure

```
├── scripts/
│   ├── 01_fastp_trimming.sh          # Quality trimming
│   ├── 02_host_depletion.sh          # Bowtie2 host depletion (hg38)
│   ├── 03_kraken2_classification.sh  # Kraken2 taxonomic classification
│   ├── 04_bracken_abundance.sh       # Bracken abundance estimation
│   └── 05_R_analysis/
│       ├── 01_data_loading.R         # Load and merge Bracken outputs
│       ├── 02_diversity_analysis.R   # Alpha and beta diversity
│       ├── 03_pathogen_prevalence.R  # Zoonotic pathogen screening
│       └── 04_visualization.R        # Publication figures
├── results/
│   └── figures/                      # Publication-ready figures
├── data/
│   └── metadata.csv                  # Sample metadata
└── README.md
```

## Requirements

### HPC Environment
- SLURM workload manager
- Conda/Miniconda

### Conda Environment
```bash
conda create -n ngs
conda activate ngs
conda install -c bioconda kraken2 bracken bowtie2 fastp fastqc multiqc samtools
```

### R Packages
```r
install.packages(c("ggplot2", "vegan", "dplyr", "tidyr", 
                   "RColorBrewer", "reshape2", "patchwork", "ggrepel"))

BiocManager::install(c("phyloseq", "ComplexHeatmap"))
```

---

## Usage

### 1. Quality Trimming
```bash
sbatch scripts/01_fastp_trimming.sh
```

### 2. Host Depletion
```bash
sbatch scripts/02_host_depletion.sh
```

### 3. Kraken2 Classification
```bash
sbatch scripts/03_kraken2_classification.sh
```

### 4. Bracken Abundance Estimation
```bash
sbatch scripts/04_bracken_abundance.sh
```

### 5. R Analysis
```bash
Rscript scripts/05_R_analysis/01_data_loading.R
```

---

## Authors
- **Jerome Bright Ogenrwot**- Bioinformatics analysis, manuscript preparation
- **Peter Ziribagwa Sabakaki**- Study design, supervision

## Institution
African Center of Excellence in Bioinformatics and Data Intensive Sciences
Infectious Diseases Institute, Makerere University
Kampala, Uganda

## License
This project is licensed under the MIT License.

## Acknowledgements
Data was analysed using computational resources (High Performance Computing) from the ACE, supported by the US National Institutes of Health
