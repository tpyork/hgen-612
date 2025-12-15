# ========================================================================
# CREATED: 2020-04-22
# UNIVERSAL PROJECT SETUP
# ========================================================================




# INSTALL PACKAGES --------------------------------------------------------




# SETUP -------------------------------------------------------------------
library('fs')



# GIT INTRODUCE ----
# happygitwithr.com
use_git_config(user.name = "Jane Doe", user.email = "jane@example.org")




# PROJECT SETUP -----------------------------------------------------------
usethis::create_project(path= path(path_home(), "Documents/projects/posterdown_posters"))
## Will need to open this file in new RStudio instance -> File/Recent Files

usethis::use_readme_md()

# From gitkraken R project template
usethis::use_git_ignore(c(".Rhistory", ".Rapp.history", ".RData", ".Ruserdata", "*-Ex.R", "/*.tar.gz", "/*.Rcheck/",
                         ".Rproj.user/", "vignettes/*.html", "vignettes/*.pdf", ".httr-oauth", "*_cache/", "/cache/",
                         "*.utf8.md", "*.knit.md", "/temp", "*.zip", "*.html", ".DS_Store", "*.Rproj"))

usethis::use_git()

# need to commit first ??
usethis::use_github(private = TRUE)
