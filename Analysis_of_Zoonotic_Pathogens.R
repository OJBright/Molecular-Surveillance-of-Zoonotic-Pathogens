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
