## This script demonstrates how to perform MLP filtering using ImShot r package 

## Clearing screen
cat("\014")

## Clearing variables
rm(list = ls())

## load ImShot R package
library(ImShot)

## Getting the path of this script
my_path <- dirname(rstudioapi::getSourceEditorContext()$path)

## MLP scoring of the desisotoped IMS masslists
ims_lcms_integration(
  search_mode = 0,
  pep_limma_results = normalizePath(
    here::here(my_path, '../Sample_results/Results_Limma/Peptide_20220127_172706'),
    winslash = '/'
  ),

  deisotoped_ims_dir = normalizePath(
    here::here(my_path, '../Sample_results/Deisotoped_Mass_Lists'),
    winslash = '/'
  ),
  
  tol = 0.1,
  
  tol_mlp = 0.2
)

print(paste(
  'Results are written in a timestamped folder inside',
  paste0(
    normalizePath(rappdirs::user_config_dir(), '/'),
    '/ImShot_Electron_App/Results_MLP'
  )
))