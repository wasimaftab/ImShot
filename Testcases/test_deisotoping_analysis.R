## This script demonstrates how to desisotope IMS masslists using ImShot r package 

## Clearing screen
cat("\014")

## Clearing variables
rm(list = ls())

## load ImShot R package
library(ImShot)

## Getting the path of this script
my_path <- dirname(rstudioapi::getSourceEditorContext()$path)

## Desisotoping IMS masslists and correct peaks
deisotope_masslist(
  IMS_masslists_folder = normalizePath(
    here::here(my_path,
               "../Datasets/IMS_cluster_masslists"),
    winslash = '/'
  ),
  
  IMS_spectrum_file = normalizePath(
    here::here(my_path,
               "../Datasets/IMS_Spectrum/WT_Spectrum.xlsx"),
    winslash = '/'
  ),
  
  tol = 0.15
)

print(paste(
  'Results are written in a timestamped folder inside',
  paste0(
    normalizePath(rappdirs::user_config_dir(), '/'),
    '/ImShot_Electron_App/Deisotoped_Mass_Lists'
  )
))