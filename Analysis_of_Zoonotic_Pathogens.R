#Checking required packages and installing missing ones

#packages <- c("phyloseq", "ggplot2", "vegan", "ComplexHeatmap", 
 #             "dplyr", "tidyr", "RColorBrewer", "reshape2", 
 #             "ggrepel", "circlize", "stringr", "patchwork")

#missing <- packages[!packages %in% rownames(installed.packages())]

#if(length(missing) > 0){
#  print(paste("Installing:", paste(missing, collapse=", ")))
#  install.packages(missing)
#} else {
#  print("All packages installed!")
#}

#if (!require("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")

#BiocManager::install(c("phyloseq", "ComplexHeatmap"))

#Confirm paths to bracken and kraen results, and that the files are as they should be
#list.files("/home/jerrybryt/Research /Zoonotic/bracken_pf_out", pattern="*.txt") |> head(10)
#list.files("/home/jerrybryt/Research /Zoonotic/kraken2_pf_out", pattern="*.txt") |> head(10)


#Actual analysis begins
suppressWarnings(
suppressPackageStartupMessages({
library(dplyr)
library(tidyr)
library(stringr)
})
)

# Set paths
bracken_res <- "/home/jerrybryt/Research /Zoonotic/bracken_pf_out"
kraken_res  <- "/home/jerrybryt/Research /Zoonotic/kraken2_pf_out"

# Load all bracken files
bracken_files <- list.files(bracken_res, pattern = "_bracken\\.txt$", full.names = TRUE)

# Read and merge all samples into one dataframe
bracken_list <- lapply(bracken_files, function(f) {
  sample_name <- str_extract(basename(f), "A5018_01_\\d+_S\\d+")
  df <- read.delim(f, header = TRUE, stringsAsFactors = FALSE)
  df$sample <- sample_name
  return(df)
})

bracken_all <- bind_rows(bracken_list)

#Surveying the structure
cat("Dimensions:", nrow(bracken_all), "rows x", ncol(bracken_all), "cols\n")
cat("Samples loaded:", length(unique(bracken_all$sample)), "\n")
cat("Column names:", paste(colnames(bracken_all), collapse=", "), "\n")
head(bracken_all)


# Remove human reads
bracken_clean <- bracken_all %>%
  filter(name != "Homo sapiens")

# Check how many species remain
cat("Species after human removal:", length(unique(bracken_clean$name)), "\n")
cat("Rows remaining:", nrow(bracken_clean), "\n")

# Build wide abundance matrix (species x samples)
abundance_matrix <- bracken_clean %>%
  select(name, sample, new_est_reads) %>%
  pivot_wider(names_from = sample, 
              values_from = new_est_reads, 
              values_fill = 0)

cat("Matrix dimensions:", nrow(abundance_matrix), "species x", ncol(abundance_matrix)-1, "samples\n")

# Quick look
head(abundance_matrix[,1:5])

# Define our target zoonotic pathogens
zoonotic_targets <- c("leptospira", "brucella", "coxiella", "mycobacterium",
                      "hantavirus", "toxoplasma", "cryptosporidium", "coronavirus",
                      "flavivirus", "giardia", "histoplasma", "cryptococcus",
                      "francisella", "borrelia", "hepatitis e")

# Filter for zoonotic pathogens only
zoonotic_df <- bracken_clean %>%
  filter(str_to_lower(name) %>% 
           sapply(function(x) any(str_detect(x, zoonotic_targets))))

cat("\nZoonotic pathogen rows detected:", nrow(zoonotic_df), "\n")
cat("Unique zoonotic taxa:", length(unique(zoonotic_df$name)), "\n")
print(unique(zoonotic_df$name))

# First let's see ALL 78 species to understand what we have
print(unique(bracken_clean$name))

# Better approach - filter by genus keywords more carefully
zoonotic_genera <- c("Leptospira", "Brucella", "Coxiella", "Mycobacterium",
                     "Toxoplasma", "Cryptosporidium", "Giardia", "Histoplasma", 
                     "Cryptococcus", "Francisella", "Borrelia", "Hantavirus",
                     "Coronavirus", "coronavirus", "Flavivirus", "Pegivirus",
                     "Yersinia", "Salmonella")

zoonotic_df <- bracken_clean %>%
  filter(sapply(name, function(x) 
    any(str_detect(x, fixed(zoonotic_genera, ignore_case = TRUE)))))

cat("Zoonotic pathogen rows detected:", nrow(zoonotic_df), "\n")
cat("Unique zoonotic taxa:\n")
print(unique(zoonotic_df$name))

# Which sample is missing from the matrix?
expected <- paste0("A5018_01_0", sprintf("%02d", 1:27), "_S", 1:27)
present <- colnames(abundance_matrix)[-1]
cat("Missing sample:", setdiff(expected, present), "\n")

# See exact names in the data
unique(bracken_clean$sample) |> sort()

# Expanded zoonotic list based on what's actually in your data
zoonotic_genera <- c("Leptospira", "Brucella", "Coxiella", "Mycobacterium",
                     "Toxoplasma", "Cryptosporidium", "Giardia", "Histoplasma",
                     "Cryptococcus", "Francisella", "Borrelia", "Hantavirus",
                     "Coronavirus", "coronavirus", "Flavivirus", "Pegivirus",
                     "Yersinia", "Salmonella", "Leishmania", "Babesia",
                     "Chlamydia", "Burkholderia", "Plasmodium", "Trichomonas",
                     "Vibrio", "Staphylococcus", "Acinetobacter", "Escherichia")

zoonotic_df <- bracken_clean %>%
  filter(sapply(name, function(x)
    any(sapply(zoonotic_genera, function(g)
      str_detect(x, regex(g, ignore_case = TRUE))))))

cat("Zoonotic pathogen rows detected:", nrow(zoonotic_df), "\n")
cat("Unique zoonotic taxa:\n")
print(unique(zoonotic_df$name))

# Also fix sample 27 naming
unique(bracken_clean$sample) |> sort()

list.files("/home/jerrybryt/Research /Zoonotic/bracken_pf_out", 
           pattern="A5018_01_027")


# Calculate prevalence for each zoonotic taxon
prevalence <- zoonotic_df %>%
  group_by(name) %>%
  summarise(
    samples_detected = n_distinct(sample),
    prevalence_pct = round(n_distinct(sample) / 26 * 100, 1),
    mean_reads = round(mean(new_est_reads), 1),
    total_reads = sum(new_est_reads)
  ) %>%
  arrange(desc(samples_detected))

print(prevalence, n=30)
