library(ggplot2)
library(tidyverse)

biom <- read_tsv("biom.txt",
                   col_types = cols(Group = col_character(),
                                    .default = col_double())) %>%
  rename_all(tolower) %>%
  select(group, starts_with("asv")) %>%
  pivot_longer(-group, names_to="asv", values_to="count")

taxonomy <- read_tsv("taxonomy.txt")%>%
  rename_all(tolower) %>%
  separate(taxonomy, into=c("kingdom","phylum","class","order","family","genus","species"), sep=";")

composite <- inner_join(biom, taxonomy, by="asv") %>%
  group_by(group, asv) %>%
  summarize(count = sum(count), .groups="drop") %>%
  group_by(group) %>%
  mutate(rel_abund = count / sum(count)*100) %>%
  ungroup() %>%
  inner_join(taxonomy, composite, by="asv")  %>%
  pivot_longer(cols=c("kingdom","phylum","class","order","family","genus","species","asv"),
               names_to="level",
               values_to="taxon")

metadata <- read_tsv("metadata.txt",
                     col_types=cols(sample = col_character())) %>%
  rename_all(tolower) %>%
  rename(group = sample)


phylum <-composite %>%
  filter(level == "phylum") %>%
  group_by(group) %>%
  mutate(total = sum(count)) %>%
  ungroup() %>%
  filter(total > 1000) %>%
  group_by(group,taxon) %>%
  summarize(rel_abund = sum(rel_abund),
            .groups="drop") %>%
  inner_join(metadata, phylum, by = "group") %>%
  group_by(replic,taxon) %>%
  summarize(mean_rel_abund = mean(rel_abund),
            .groups="drop") %>%
  filter(mean_rel_abund != "NaN" & mean_rel_abund != 0.0000000000) %>%
  group_by(taxon) %>%
  mutate(pool = mean_rel_abund < 3,
         .groups ="drop") %>%
  mutate(taxon = if_else(pool, "Others", taxon)) %>%
  group_by(replic, taxon) %>%
  summarize(mean_rel_abund = sum(mean_rel_abund), .groups = "drop") %>%
  mutate(replic = factor(replic,levels=c("Vn_Lb_S","Vt_Lb_S","Vn_Lb_F","Vt_Lb_F",
                                         "Vn_Lb_J","Vt_Lb_J", "Vn_Lb_A","Vt_Lb_A",
                                         "Vi_Lb_S","Vp_Lb_S","Vi_Lb_F","Vp_Lb_F",
                                         "Vi_Lb_J","Vp_Lb_J","Vi_Lb_A","Vp_Lb_A",
                                         "Vn_Dsh_S","Vt_Dsh_S","Vn_Dsh_F","Vt_Dsh_F",
                                         "Vn_Dsh_J","Vt_Dsh_J", "Vn_Dsh_A","Vt_Dsh_A",
                                         "Vi_Dsh_S","Vp_Dsh_S","Vi_Dsh_F","Vp_Dsh_F",
                                         "Vi_Dsh_J","Vp_Dsh_J","Vi_Dsh_A","Vp_Dsh_A",
                                         "Vn_Ar_S","Vt_Ar_S","Vn_Ar_F","Vt_Ar_F",
                                         "Vn_Ar_J","Vt_Ar_J", "Vn_Ar_A","Vt_Ar_A",
                                         "Vi_Ar_S","Vp_Ar_S","Vi_Ar_F","Vp_Ar_F",
                                         "Vi_Ar_J","Vp_Ar_J","Vi_Ar_A","Vp_Ar_A",
                                         "Vn_Ur_S","Vt_Ur_S","Vn_Ur_F","Vt_Ur_F",
                                         "Vn_Ur_J","Vt_Ur_J", "Vn_Ur_A","Vt_Ur_A",
                                         "Vi_Ur_S","Vp_Ur_S","Vi_Ur_F","Vp_Ur_F",
                                         "Vi_Ur_J","Vp_Ur_J","Vi_Ur_A","Vp_Ur_A",
                                         "Vn_S_S","Vt_S_S","Vn_S_F","Vt_S_F",
                                         "Vn_S_J","Vt_S_J", "Vn_S_A","Vt_S_A",
                                         "Vi_S_S","Vp_S_S","Vi_S_F","Vp_S_F",
                                         "Vi_S_J","Vp_S_J","Vi_S_A","Vp_S_A")))

# Ensure taxon is a factor
phylum$taxon <- factor(phylum$taxon)

# Identify the levels excluding "Others" and "unclassified"
other_levels <- setdiff(levels(phylum$taxon), c("Others", "unclassified"))

# Add "Others" and "unclassified" to the end of the levels
new_levels <- c(other_levels, "Others", "unclassified")

# Reorder the levels in the taxon factor
phylum$taxon <- factor(phylum$taxon, levels = new_levels)

# Define a scientific core palette with 13 colors
scientific_palette <- c("#1f78b4", "#33a02c", "lightblue", "#e31a1c", "#ff7f00","#6a3d9a",
                        "#a6cee3", "#b2df8a", "#fb9a99", "#fdbf6f", "#cab2d6",
                        "#17becf", "#dbdb8d", "#8c564b","#9467bd")

barchart <- phylum %>%
  ggplot(aes(x = replic, y = mean_rel_abund, fill = taxon)) +
  geom_col() +
  scale_fill_manual(values = scientific_palette, name = NULL) +
  scale_y_continuous(expand = c(0, 0)) +
  labs(x = NULL, y = "Relative Abundance (%)") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, vjust = 1, hjust = 1),
        legend.text = element_text(face = "italic"),
        legend.key.size = unit(10, "pt"))

print(barchart)
















