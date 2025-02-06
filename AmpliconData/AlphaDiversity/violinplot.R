
library(ggplot2)
library(tidyverse)
library(microbiome)
library(ggpubr)
library(patchwork)
library(stringr)

asv_mat <- read_tsv("phyloseq_biom.txt")

samples_df <- read_tsv("metadata.txt")

tax_mat <-read_tsv("phyloseq_taxonomy.txt")

asv_mat <- asv_mat %>%
  tibble::column_to_rownames("asv") 

tax_mat <- tax_mat %>% 
  tibble::column_to_rownames("asv")

samples_df <- samples_df %>% 
  tibble::column_to_rownames("sample")


asv_matx <- as.matrix(asv_mat)
asv_mat <- as.matrix(asv_mat)
tax_mat <- as.matrix(tax_mat)

asv = otu_table(asv_mat, taxa_are_rows = TRUE)

samples = sample_data(samples_df)

pseq <- phyloseq(asv, samples)

sample_totals <- sample_sums(pseq)

# Identify samples to keep (those with total sequences >= 5000)
samples_to_keep <- names(sample_totals[sample_totals >= 5000])

# Subset the phyloseq object
pseq_filtered <- prune_samples(samples_to_keep, pseq)

pseq <-pseq_filtered

pseq.rarified <- rarefy_even_depth(pseq, sample.size = "5000", rngseed = 290193, replace = F)

pseq.rel <- microbiome::transform(pseq.rarified, "compositional")

tab <-microbiome::alpha(pseq.rel, index = "all")

pseq.rel.meta <- microbiome::meta(pseq.rel)

pseq.rel.meta$Shannon <- tab$diversity_shannon 

pseq.rel.meta$strategy <- as.factor(pseq.rel.meta$strategy)
pseq.rel.meta$season <- as.factor(pseq.rel.meta$season)
pseq.rel.meta$bodysite <- as.factor(pseq.rel.meta$bodysite)

strategy <- levels(pseq.rel.meta$strategy)
season <- levels(pseq.rel.meta$season)
bodysite <-levels(pseq.rel.meta$bodysite)

# make a pairwise list that we want to compare.

strategy.pairs <- combn(seq_along(strategy), 2, simplify = FALSE, FUN = function(i)strategy[i])
season.pairs <- combn(seq_along(season), 2, simplify = FALSE, FUN = function(i)season[i])
bodysite.pairs <- combn(seq_along(bodysite), 2, simplify = FALSE, FUN = function(i)bodysite[i])

pseq.rel.meta$bodysite <- factor(pseq.rel.meta$bodysite, levels = c("Lb", "Dsh", "Ar", "Ur", "S"))


shannon_bodysite <- ggviolin(pseq.rel.meta, x = "bodysite", y = "Shannon",
                             add = "boxplot", fill = "bodysite", 
                             palette = c(Lb = "green", Dsh = "blue", Ar = "red2", S = "purple", Ur = "orange"))


shannon_bodysite <- shannon_bodysite + 
  stat_compare_means(comparisons = bodysite.pairs, method = "wilcox.test") +
  labs(y = "Shannon index") + 
  xlab("") + 
  theme(legend.position = "none")

print(shannon_bodysite)


pseq.rel.meta$strategy <- factor(pseq.rel.meta$strategy, levels = c("DT", "NDT"))


shannon_strategy <- ggviolin(pseq.rel.meta, x = "strategy", y = "Shannon",
                             add = "boxplot", fill = "strategy", 
                             palette = c(DT="orange",NDT="green"))


shannon_strategy  <- shannon_strategy  + 
  stat_compare_means(comparisons = strategy.pairs, method = "wilcox.test") +
  labs(y = "Shannon index") + 
  xlab("") +  
  theme(legend.position = "none")  


print(shannon_strategy)

pseq.rel.meta$season <- factor(pseq.rel.meta$season, levels = c("Early Rainy", "Late Rainy", "Early Dry", "Late Dry"))

shannon_season <- ggviolin(pseq.rel.meta, x = "season", y = "Shannon",
                           add = "boxplot", fill = "season", 
                           palette = c('Early Rainy'="lightblue",'Late Rainy'="blue",'Early Dry'="orange",'Late Dry'="red"))


shannon_season <- shannon_season + 
  stat_compare_means(comparisons = season.pairs, method = "wilcox.test") +
  labs(y = "Shannon index") + 
  xlab("") +  
  theme(legend.position = "none") +  
  scale_x_discrete(labels = c("Early Rainy" = "Early\nRainy", 
                              "Late Rainy" = "Late\nRainy", 
                              "Early Dry" = "Early\nDry", 
                              "Late Dry" = "Late\nDry"))  


print(shannon_season)

combined_plot <- shannon_bodysite + shannon_strategy + shannon_season + 
  plot_layout(ncol = 3) 

print(combined_plot)
