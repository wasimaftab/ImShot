## Installs ImShot 1.2.2 and every R package it needs.
##
## Works on Windows, macOS and Linux with R >= 4.0. Run it in one of these ways:
##   * RStudio: open this file and press "Source"
##   * R console: source("<path to ImShot folder>/Install_Required_Packages_ImShot_R.R")
##   * Terminal: Rscript Install_Required_Packages_ImShot_R.R
##
## ImShot and its dependencies are installed into their own library folder
## (default: ~/R/ImShot-library/<R version>), so packages you already have are
## never changed and cannot conflict with ImShot. After installation, load
## ImShot in a new R session with:
##   .libPaths(c("~/R/ImShot-library/<R version>", .libPaths()))
##   library(ImShot)
##
## devtools is NOT required. Packages are installed as pre-built binaries where
## possible, from a package snapshot that matches the running R version, so older
## R versions do not receive packages that need a newer R. The installation runs
## in a fresh R process, so packages loaded in your current session do not
## interfere with it.

## Clearing screen
cat("\014")

if (getRversion() < "4.0.0") {
    stop("ImShot needs R >= 4.0.0. You are running R ", getRversion(), ".")
}

## ---------------------------------------------------------------------------
## 1. Locate the ImShot folder (the folder containing this script) and choose
##    the library folder ImShot is installed into
## ---------------------------------------------------------------------------
get_script_dir <- function() {
    ## Called via source() (also what RStudio's "Source" button does)
    for (i in rev(seq_len(sys.nframe()))) {
        f <- sys.frame(i)$ofile
        if (!is.null(f)) return(dirname(normalizePath(f)))
    }
    ## Called via Rscript
    f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
    if (length(f)) return(dirname(normalizePath(f[1])))
    ## Lines run one by one in RStudio
    if (requireNamespace("rstudioapi", quietly = TRUE) &&
        rstudioapi::isAvailable()) {
        p <- rstudioapi::getSourceEditorContext()$path
        if (nzchar(p)) return(dirname(normalizePath(p)))
    }
    normalizePath(getwd())
}

is_installer_process <- Sys.getenv("IMSHOT_INSTALLER_PROCESS") == "1"
r_minor <- sub("^(\\d+\\.\\d+).*$", "\\1", as.character(getRversion()))

## Set `imshot_dir` or `imshot_lib` yourself before running this script to
## override the defaults
if (is_installer_process) {
    imshot_dir <- Sys.getenv("IMSHOT_DIR")
    imshot_lib <- Sys.getenv("IMSHOT_LIB")
} else {
    if (!exists("imshot_dir")) imshot_dir <- get_script_dir()
    if (!exists("imshot_lib")) {
        imshot_lib <- file.path("~", "R", "ImShot-library", r_minor)
    }
    imshot_lib <- normalizePath(imshot_lib, winslash = "/", mustWork = FALSE)
}
if (!file.exists(file.path(imshot_dir, "Install_Required_Packages_ImShot_R.R")) ||
    !dir.exists(file.path(imshot_dir, "Install_Locally"))) {
    stop("Could not find the ImShot folder (looked in '", imshot_dir, "').\n",
         "Run setwd(\"<path to ImShot folder>\") or set ",
         "imshot_dir <- \"<path to ImShot folder>\" and run this script again.")
}

## ---------------------------------------------------------------------------
## 2. Choose package repositories suited to this R version and OS
## ---------------------------------------------------------------------------
## Last day each R version was the current release. Packages from that date are
## known to work with that R version. The current R release uses the latest ones.
r_snapshot_dates <- c(
    "4.0" = "2021-05-17",
    "4.1" = "2022-04-21",
    "4.2" = "2023-04-20",
    "4.3" = "2024-04-23",
    "4.4" = "2025-04-10",
    "4.5" = "2026-04-23"
)
snapshot <- if (r_minor %in% names(r_snapshot_dates)) {
    r_snapshot_dates[[r_minor]]
} else {
    "latest"
}
os_type <- Sys.info()[["sysname"]]

url_exists <- function(u) {
    tryCatch({
        con <- url(u)
        on.exit(close(con))
        length(suppressWarnings(readLines(con, n = 1))) > 0
    }, error = function(e) FALSE)
}

## Name of the Linux distribution as used by Posit Package Manager
linux_distro <- function() {
    if (!file.exists("/etc/os-release")) return(NA_character_)
    os <- readLines("/etc/os-release", warn = FALSE)
    field <- function(k) {
        v <- sub(paste0("^", k, "="), "", grep(paste0("^", k, "="), os, value = TRUE))
        gsub("\"", "", v[1])
    }
    id <- field("ID")
    id_like <- field("ID_LIKE")
    version <- field("VERSION_ID")
    codename <- field("VERSION_CODENAME")
    if (!is.na(codename) && nzchar(codename) &&
        (id %in% c("ubuntu", "debian") ||
         grepl("ubuntu|debian", id_like))) {
        ## Ubuntu derivatives (e.g. Linux Mint) report the Ubuntu codename here
        ubuntu_codename <- field("UBUNTU_CODENAME")
        if (!is.na(ubuntu_codename) && nzchar(ubuntu_codename)) return(ubuntu_codename)
        return(codename)
    }
    if (id %in% c("rhel", "centos", "rocky", "almalinux", "ol", "fedora") ||
        grepl("rhel|fedora", id_like)) {
        return(paste0("rhel", sub("\\..*$", "", version)))
    }
    if (grepl("opensuse|sles", id)) {
        return(paste0("opensuse", gsub("\\.", "", version)))
    }
    NA_character_
}

set_repositories <- function() {
    if (os_type == "Linux") {
        ## Posit Package Manager provides pre-built Linux binaries, so packages
        ## do not have to be compiled (compiling needs extra system libraries).
        p3m <- "https://packagemanager.posit.co/cran"
        cran_url <- paste(p3m, snapshot, sep = "/")
        distro <- linux_distro()
        if (!is.na(distro)) {
            bin_url <- paste(p3m, "__linux__", distro, snapshot, sep = "/")
            if (url_exists(paste0(bin_url, "/src/contrib/PACKAGES"))) {
                cran_url <- bin_url
                options(HTTPUserAgent = sprintf(
                    "R/%s R (%s)", getRversion(),
                    paste(getRversion(), R.version["platform"],
                          R.version["arch"], R.version["os"])))
            }
        }
        if (cran_url == paste(p3m, snapshot, sep = "/")) {
            cat("No pre-built binaries for this Linux distribution;",
                "packages will be compiled from source.\n")
        }
    } else {
        ## Windows and macOS: CRAN keeps binaries built for each R version
        cran_url <- "https://cloud.r-project.org"
        ## Always take the binary built for this R version, never compile newer source
        options(install.packages.check.source = "no")
    }
    options(repos = c(CRAN = cran_url))
    cat("Package repository:", cran_url, "\n\n")
}

## ---------------------------------------------------------------------------
## 3. Package lists
## ---------------------------------------------------------------------------
list.of.cran.packages <-
    c(
        "rjson",
        "fs",
        "cli",
        "rlang",
        "hash",
        "rstudioapi",
        "here",
        "MASS",
        "dplyr",
        "htmlwidgets",
        "matlab",
        "matrixStats",
        "plotly",
        "rappdirs",
        "readxl",
        "stringr",
        "writexl",
        "rrcovNA",
        "missForest",
        "missMDA",
        ## Dependencies of the local packages in Install_Locally
        "lubridate",
        "timeDate",
        "Matrix",
        "gbm",
        "locfit",
        "xts",
        "quantmod",
        "zoo",
        "abind",
        "rpart",
        "class",
        "ROCR",
        "lattice"
    )

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

## Installed from the tar.gz files shipped with ImShot, in this order
list.of.local.packages <-
    c(
        TimeProjection = "Install_Locally/TimeProjection_0.2.0.tar.gz",
        imputation = "Install_Locally/imputation_2.0.1.tar.gz",
        DMwR = "Install_Locally/DMwR_0.4.1.tar.gz",
        ImShot = "ImShot_R_Package/ImShot.package.v1.2.2.tar.gz"
    )

## ---------------------------------------------------------------------------
## 4. Install (runs in a fresh R process that sees only the ImShot library)
## ---------------------------------------------------------------------------
not_installed <- function(pkgs) {
    pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
}

install_cran_and_bio_packages <- function() {
    ## BiocManager picks the Bioconductor release that matches this R version
    ## and also installs the CRAN packages (from the repository chosen above)
    new.packages <- not_installed(c(list.of.cran.packages, list.of.bio.packages))
    if (length(new.packages)) {
        BiocManager::install(new.packages, ask = FALSE, update = FALSE)
    }
}

## A Linux binary can need a system library that is not present on this
## computer (e.g. igraph needs libglpk). Such packages are rebuilt from source,
## which uses the copies of these libraries bundled with the package.
broken_linux_binaries <- function() {
    if (os_type != "Linux" || !nzchar(Sys.which("ldd"))) return(character(0))
    so_files <- Sys.glob(file.path(imshot_lib, "*", "libs", "*.so"))
    broken <- vapply(so_files, function(f) {
        any(grepl("not found", suppressWarnings(
            system2("ldd", shQuote(f), stdout = TRUE, stderr = TRUE))))
    }, logical(1))
    unique(basename(dirname(dirname(so_files[broken]))))
}

run_installation <- function() {
    ## Use only the ImShot library (plus R's own base packages)
    .libPaths(imshot_lib, include.site = FALSE)
    set_repositories()

    if (!requireNamespace("BiocManager", quietly = TRUE)) {
        install.packages("BiocManager")
    }
    ## "had non-zero exit status" warnings are dropped here; failures are
    ## repaired below and every package is checked at the end
    withCallingHandlers(
        install_cran_and_bio_packages(),
        warning = function(w) {
            if (grepl("non-zero exit status", conditionMessage(w)))
                invokeRestart("muffleWarning")
        })

    broken <- broken_linux_binaries()
    if (length(broken)) {
        cat("\nSome pre-built packages need system libraries that are missing on",
            "this computer.\nAny installation errors above are caused by this and",
            "are fixed now by rebuilding from source:",
            paste(broken, collapse = ", "), "\n\n")
        install.packages(broken,
                         repos = c(CRAN = paste(
                             "https://packagemanager.posit.co/cran", snapshot, sep = "/")),
                         type = "source")
        install_cran_and_bio_packages()
    }

    for (pkg in names(list.of.local.packages)) {
        if (length(not_installed(pkg))) {
            install.packages(file.path(imshot_dir, list.of.local.packages[[pkg]]),
                             repos = NULL, type = "source")
        }
    }

    ## Check the result
    cat("\n")
    not_inst_cran <- not_installed(c("BiocManager", list.of.cran.packages))
    not_inst_bioc <- not_installed(list.of.bio.packages)
    not_inst_local <- not_installed(names(list.of.local.packages))

    if (length(not_inst_cran)) {
        print('Following CRAN packages are not installed')
        print('#########################################')
        print(not_inst_cran)
        cat('\n')
    }
    if (length(not_inst_bioc)) {
        print('Following Bioconductor packages are not installed')
        print('#################################################')
        print(not_inst_bioc)
        cat('\n')
    }
    if (length(not_inst_local)) {
        print('Following local packages are not installed')
        print('###########################################')
        print(not_inst_local)
        cat('\n')
    }

    if (length(c(not_inst_cran, not_inst_bioc, not_inst_local))) {
        if (os_type == "Linux") {
            cat("Packages compiled from source on Linux need system libraries.",
                "Install them and run this script again:\n",
                " Debian/Ubuntu: sudo apt-get install build-essential gfortran",
                "libxml2-dev libcurl4-openssl-dev libssl-dev libfontconfig1-dev",
                "libfreetype6-dev libharfbuzz-dev libfribidi-dev libpng-dev",
                "libtiff5-dev libjpeg-dev libglpk-dev tcl-dev tk-dev\n",
                " Fedora/RHEL:   sudo dnf install gcc gcc-c++ gcc-gfortran make",
                "libxml2-devel libcurl-devel openssl-devel fontconfig-devel",
                "freetype-devel harfbuzz-devel fribidi-devel libpng-devel",
                "libtiff-devel libjpeg-turbo-devel glpk-devel tcl-devel tk-devel\n")
        } else if (os_type == "Windows") {
            cat("If a package had to be compiled, install Rtools for your R",
                "version: https://cran.r-project.org/bin/windows/Rtools/\n")
        } else {
            cat("If a package had to be compiled, install the macOS build tools:",
                "https://mac.r-project.org/tools/\n")
        }
        stop("ImShot installation is incomplete; see the messages above ",
             "(the first error printed during installation is usually the cause).")
    }

    ## ImShot uses tcltk for file dialogs and Pandoc for saving HTML plots
    if (!capabilities("tcltk")) {
        warning("This R build has no Tcl/Tk support, which ImShot uses for dialogs. ",
                if (os_type == "Darwin") "On macOS, install XQuartz (https://www.xquartz.org). "
                else if (os_type == "Linux") "On Linux, install R from your distribution or CRAN packages, which include Tcl/Tk. ",
                call. = FALSE)
    }
    if (!nzchar(Sys.which("pandoc")) && !nzchar(Sys.getenv("RSTUDIO_PANDOC"))) {
        warning("Pandoc was not found; it is needed to save plotly plots as HTML. ",
                "It is included with RStudio, or see https://pandoc.org/installing.html",
                call. = FALSE)
    }
    cat("ImShot version:", as.character(utils::packageVersion("ImShot")), "\n")
}

## ---------------------------------------------------------------------------
## 5. Run
## ---------------------------------------------------------------------------
if (is_installer_process) {
    run_installation()
} else {
    cat("ImShot folder:  ", imshot_dir, "\n")
    cat("ImShot library: ", imshot_lib, "\n")
    cat("Installing in a separate R process; this can take 30 minutes or more",
        "the first time...\n\n")
    dir.create(imshot_lib, recursive = TRUE, showWarnings = FALSE)

    ## Settings for the installer process, restored afterwards
    old_env <- Sys.getenv(c("IMSHOT_INSTALLER_PROCESS", "IMSHOT_DIR", "IMSHOT_LIB",
                            "R_LIBS", "R_LIBS_USER"), unset = NA)
    Sys.setenv(IMSHOT_INSTALLER_PROCESS = "1", IMSHOT_DIR = imshot_dir,
               IMSHOT_LIB = imshot_lib, R_LIBS = imshot_lib, R_LIBS_USER = imshot_lib)
    status <- system2(file.path(R.home("bin"), "Rscript"),
                      c("--no-init-file",
                        shQuote(file.path(imshot_dir,
                                          "Install_Required_Packages_ImShot_R.R"))))
    for (v in names(old_env)) {
        if (is.na(old_env[[v]])) Sys.unsetenv(v)
        else do.call(Sys.setenv, as.list(old_env[v]))
    }

    if (status != 0) {
        stop("ImShot installation is incomplete; see the messages above ",
             "(the first error printed during installation is usually the cause).")
    }
    print('All the required packages are installed successfully')
    cat("\nTo use ImShot, restart R (RStudio: Session > Restart R) and run:\n\n",
        sprintf('    .libPaths(c("%s", .libPaths()))\n', imshot_lib),
        "    library(ImShot)\n\n",
        "The desktop application needs the same library: start it with the ",
        sprintf('environment variable R_LIBS_USER set to "%s".\n', imshot_lib),
        sep = "")
}
