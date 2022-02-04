## This script demonstrates how to perform Pathway (KEGG or Reactome) enrichment analysis 
## and plot results on a Cytoscape session using ImShot r package
## Cytoscape must be running before executing this script

## Clearing screen
cat("\014")

## Clearing variables
rm(list = ls())

## load ImShot R package
library(ImShot)

## Getting the path of this script
my_path <- dirname(rstudioapi::getSourceEditorContext()$path)

## Using custom background
## (output folder path is default, see function documentation)
pathway_enrichment_analysis(
  enrichment_path = normalizePath(
    here::here(my_path, "../Datasets/Enrichment_Data"),
    winslash = '/'
  ),
  species_background = normalizePath(
    here::here(
      my_path,
      "../Datasets/Enrichment_Data/Background/Mouse_Proteome_Uniprot.txt"
    ),
    winslash = '/'
  ),
  annot_db = "org.Mm.eg.db",
  pathway_db = "Reactome",
  kegg_code = "mmu",
  min_gs_size = 1,
  max_gs_size = 500,
  pvalue_cutoff = 0.05,
  padjust_method = "BH",
  max_path_show = 10
)

# ## Using default background
# ## (output folder path is default, see function documentation)
# pathway_enrichment_analysis(
#   enrichment_path = normalizePath(
#     here::here(my_path, "../../../Datasets/Enrichment_Data"),
#     winslash = '/'
#   ),
#   species_background = "Default",
#   annot_db = "org.Mm.eg.db",
#   pathway_db = "Reactome",
#   kegg_code = "mmu",
#   min_gs_size = 1,
#   max_gs_size = 500,
#   pvalue_cutoff = 0.05,
#   padjust_method = "BH",
#   max_path_show = 10
# )
# 
# print(paste(
#   'Results are written in a timestamped folder inside',
#   paste0(
#     normalizePath(rappdirs::user_config_dir(), '/'),
#     '/ImShot_Electron_App/Results_Pathway'
#   )
# ))
