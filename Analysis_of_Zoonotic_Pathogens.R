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


