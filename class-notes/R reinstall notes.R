# =========================================================================
# created: 2011-02-11
# updated: 2026-01-20
# R INSTALLATION AND MANAGEMENT FUNCTIONS
#==========================================================================




# Run in Old Version of R -------------------------------------------------
# 1. Manually set your working directory to a folder
setwd("/Users/UserName/Documents/R-ref/R_install") #this will differ for you!

# 2. Copy names of all currently installed packages
packages <- installed.packages()[,"Package"]

# 3. Save package names to a .Rdata file
save(packages, file="Rpackages")

# 4. Close R (or RStudio)


# Remove current R in terminal --------------------------------------------
# Do not use the terminal in RStudio
# This will only remove R; not your project files/directories; you've already saved the names of packages you want to re-install

# whoami
# sudo rm -rf /Library/Frameworks/R.framework /Applications/R.app



# Install Current R from Website ------------------------------------------
# https://cran.r-project.org/




# Run in new version ------------------------------------------------------
# 1. Manually set your working directory to the same folder as before
setwd("/Users/UserName/Documents/R-ref/R_install")

# 2. Load object with package names
load("Rpackages")

# 3. Remove any packages you do not want re-loaded
packages <- packages[packages != "OpenMx"]
packages <- packages[packages != "mgcv"]

# 4. Re-install all packages
for (p in setdiff(packages, installed.packages()[,"Package"]))
install.packages(p)




# OPTIONAL:  Install Bioconductor (NEW) ------------------------------------
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install()

for (p in setdiff(packages, installed.packages()[,"Package"]))
  BiocManager::install(p, ask = FALSE, update = FALSE)




# End Reinstall -----------------------------------------------------------




# OPTIONAL: Utility functions ---------------------------------------------

getOption("defaultPackages")
.libPaths()
library()
sessionInfo()

# update R packages
library()
update.packages(ask=F)

# update Bioconductor packages
source("http://bioconductor.org/biocLite.R")
old.packages(repos=biocinstallRepos())
update.packages(repos=biocinstallRepos(), ask=FALSE, checkBuilt=TRUE)
