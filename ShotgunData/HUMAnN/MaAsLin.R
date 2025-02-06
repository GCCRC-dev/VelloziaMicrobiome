
library(Maaslin2)
library(tidyverse)
library(ggplot2)

df_input_metadata <- read.table(file = "metadata_maaslin2.txt", 
                                header = TRUE, 
                                sep = "\t", 
                                row.names = 1,
                                stringsAsFactors = FALSE)

df_input_path = read.csv("rpk-CPM_pathabundance_unstratified.txt", 
                         sep              = "\t", 
                         stringsAsFactors = FALSE, 
                         row.names        = 1)

fit_data = Maaslin2(
  input_data = df_input_path,
  input_metadata = df_input_metadata,
  output = "pathway_cpm",
  normalization = "NONE",
  transform = "NONE",
  fixed_effects = c("strategy","season"),
  reference = c("strategy","NDT"))

# Read the data
significant_pathway <- read_tsv("pathway_cpm/significant_results.tsv")

sig <- significant_pathway %>%
  filter(qval < 0.05 & metadata %in% c("strategy", "season")) %>%
  filter(!grepl("UNGROUPED|AMBIGUOUS|UNINTEGRATED", feature))

table(sig$metadata)

write_tsv(sig, file = "TableS3.tsv")

  