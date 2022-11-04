## Clearing screen
cat("\014")

## Function to check packages are installed
install_required_packages <- function(list.of.packages, flag) {
    new.packages <-
        list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
    if (length(new.packages) && flag == "CRAN")
        install.packages(new.packages)
    else if (length(new.packages) && flag == "BIO")
        BiocManager::install(new.packages)
}

## Function to install packages
check_if_packages_installed <- function(list.of.packages) {
    search_list <-
        paste0("^", paste0(list.of.packages, collapse = "$|^"), "$")
    idx <- grep(search_list, installed.packages()[, 'Package'])
    pkgs <-
        as.data.frame(installed.packages()[idx, c('Package',  'Version', 'Built')])
    not_inst <- setdiff(list.of.packages, pkgs$Package)
    if (length(not_inst) == 0) {
        flag <- 1
    } else{
        flag <- 0
    }
    return(list(flag = flag, not_inst = not_inst))
}

## Installing CRAN packages
list.of.cran.packages <-
    c(
        "rjson",
        "fs",
        "cli",
        "rlang",
        "hash",
        "rstudioapi",
        "here",
        "BiocManager",
        "MASS",
        "devtools",
        "dplyr",
        "htmlwidgets",
        "matlab",
        "matrixStats",
        "plotly",
        "rappdirs",
        "readxl",
        "stringr",
        "tcltk",
        "writexl",
        "rrcovNA",
        "missForest",
        "missMDA"
    )

install_required_packages(list.of.cran.packages, 'CRAN')
cran <- check_if_packages_installed(list.of.cran.packages)
cran_flag <- cran$flag
not_inst_cran <- cran$not_inst

### Installing Bioconductor packages
list.of.bio.packages <-
    c(
        "org.Mm.eg.db",
        "org.Hs.eg.db",
        "org.Dm.eg.db",
        "org.Sc.sgd.db",
        "clusterProfiler",
        "ReactomePA",
        "DOSE",
        "RCy3",
        "limma",
        "qvalue",
        "pcaMethods"
    )
install_required_packages(list.of.bio.packages, 'BIO')
bioc <- check_if_packages_installed(list.of.bio.packages)
bioc_flag <- bioc$flag
not_inst_bioc <- bioc$not_inst

if (bioc_flag && cran_flag) {
    ## Installing ImShot (local package)
    list.of.packages <- c("DMwR", "TimeProjection", "imputation", "ImShot")
    new.packages <-
        list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
    if (length(new.packages)) {
        ## Getting the path of this script
        my_path <-
            dirname(rstudioapi::getSourceEditorContext()$path)
        
        ## Install ImShot R package
        if (Sys.info()["sysname"] == "Darwin"){
          print("Installing ImShot on macOS using tar file")
          devtools::install_local(normalizePath(
            here::here(
              my_path,
              'ImShot_R_Package/ImShot.package.v1.2.2.tar.gz'
            ),
            winslash = '/'
          ))
        } else {
          devtools::install_local(normalizePath(
            here::here(
              my_path,
              'ImShot_R_Package/ImShot.package.v1.2.2.zip'
            ),
            winslash = '/'
          ))
        }

        ## Install other required local packages
        devtools::install_local(normalizePath(
            here::here(
                my_path,
                'Install_Locally/TimeProjection_0.2.0.tar.gz'
            ),
            winslash = '/'
        ))
        
        devtools::install_local(normalizePath(
          here::here(
            my_path,
            'Install_Locally/DMwR_0.4.1.tar.gz'
          ),
          winslash = '/'
        ))
        
        devtools::install_local(normalizePath(
            here::here(
                my_path,
                'Install_Locally/imputation_2.0.1.tar.gz'
            ),
            winslash = '/'
        ))
    }
    new.packages <-
        list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
    if (length(new.packages)) {
        stop('Some or all packages from this set: {DMwR, imputation, ImShot} are NOT installed successfully')
    } else{
        print('All the required packages are installed successfully')
    }
} else if (bioc_flag == 1 && cran_flag == 0) {
    print('Following CRAN packages are not installed')
    print('#########################################')
    print(not_inst_cran)
} else if (bioc_flag == 0 && cran_flag == 1) {
    print('Following Bioconductor packages are not installed')
    print('#################################################')
    print(not_inst_bioc)
} else {
    print('Following CRAN packages are not installed')
    print('#########################################')
    print(not_inst_cran)
    cat('\n')
    print('Following Bioconductor packages are not installed')
    print('#################################################')
    print(not_inst_bioc)
}