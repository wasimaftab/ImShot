## This script demonstrates how to call a function from ImShot r package 
## to perform two group comparison using Limma statistics

## Clearing screen
cat("\014")

## Clearing variables
rm(list = ls())

## load ImShot R package
library(ImShot)

## Getting the path of this script
my_path <- dirname(rstudioapi::getSourceEditorContext()$path)

## two group comparison using proteingroups.txt (MaxQuant output)
## (output folder path is default, see function documentation)
two_grp_limma(
    mq_file_path = normalizePath(
        here::here(
            my_path,
            "../Datasets/MQ_output_files/proteinGroups_180416.txt"
        ),
        winslash = '/'
    ),
    peptide_or_protein = 1,
    lfq_or_ibaq = 2,
    norm_method = 2
)
print(paste(
    'Results are written in a timestamped folder inside',
    paste0(
        normalizePath(rappdirs::user_config_dir(), '/'),
        '/ImShot_Electron_App/Results_Limma'
    )
))


# ## two group comparison using peptides.txt (MaxQuant output)
# ## (output folder path is default, see function documentation)
# two_grp_limma(
#   mq_file_path = normalizePath(
#     here::here(my_path,
#                "../Datasets/MQ_output_files/peptides_180416.txt"),
#     winslash = '/'
#   ),
#   peptide_or_protein = 0
# )
# 
# print(paste(
#   'Results are written in a timestamped folder inside',
#   paste0(
#   normalizePath(rappdirs::user_config_dir(), '/'),
#   '/ImShot_Electron_App/Results_Limma'
#   )
# ))