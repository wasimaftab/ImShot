# ImShot: An open-source software for probabilistic identification of proteins in situ and visualization of proteomics data

## Installation (updated 2026)

The installation script installs ImShot **version 1.2.3** (`ImShot_R_Package/ImShot.package.v1.2.3.tar.gz`). An older installed ImShot is replaced automatically.

**Changes in 1.2.3** (compared with the 2022 release 1.2.2):
- The treatment and control names entered in `two_grp_limma()` are now checked. An empty, numeric or overlapping name, or a name that would select all intensity columns, is rejected and asked again, and the selected columns are printed. Previously, an empty answer (for example, a blank line sent to the console together with the code) silently selected all intensity columns.
- No other code was changed. For valid inputs, results are identical to version 1.2.2.

The 2022 package files (`ImShot.package.v1.2.2.tar.gz` and `.zip`), the datasets and the sample results are kept unchanged.

1. Download or clone this repository (if you download the ZIP archive, extract it and rename the folder `ImShot`).
2. Open `Install_Required_Packages_ImShot_R.R` in RStudio and press **Source**, or run it from the R console:
   ```r
   source("ImShot/Install_Required_Packages_ImShot_R.R")
   ```
   or from a terminal inside the `ImShot` folder:
   ```sh
   Rscript Install_Required_Packages_ImShot_R.R
   ```
3. Wait until it prints `All the required packages are installed successfully`. The first installation can take 30 minutes or longer. Error messages shown during installation can be ignored if this final message appears; the installer repairs some problems itself.
4. Restart R. In **every** new R session, add the ImShot library before loading ImShot (use the path printed by the installer; `4.3` is your R version):
   ```r
   .libPaths(c("~/R/ImShot-library/4.3", .libPaths()))
   library(ImShot)
   ```

What the installer does:
- Works on Windows, macOS and Linux with R >= 4.0. `devtools` is not needed.
- Installs ImShot and all its dependencies into a separate library (`~/R/ImShot-library/<R version>`), so your other R packages are neither used nor changed. To uninstall, delete that folder.
- Takes CRAN packages from a snapshot that matches your R version, so older R versions do not receive packages that require a newer R. On Linux, pre-built binaries are used where available.
- If installation is incomplete, it lists the missing packages and the build tools or system libraries to install. Install them and run the script again.

The desktop application (`ImShot_Electron_App`) needs the same library: set the environment variable `R_LIBS_USER` to the ImShot library path before starting it.

## Documentation

For information on how to run ImShot refer the following document (its installation section is replaced by the instructions above):

https://github.com/wasimaftab/ImShot/blob/master/Documentation/Software%20_Documentation_GItHub.pdf

Earlier states of the repository:
- the original 2022 release (ImShot 1.2.2): commit [`b6bcd2d`](https://github.com/wasimaftab/ImShot/tree/b6bcd2d74e185796a48a11e4ff226d2b0106d1fd)
- ImShot 1.2.2 with the first updated installer: tag [`v1.2.2-installer-2026`](https://github.com/wasimaftab/ImShot/tree/v1.2.2-installer-2026)

![Graph_Abs](https://user-images.githubusercontent.com/29901809/152519060-4e57abe8-8ea1-4f98-a9e6-b57255028cbd.png)
