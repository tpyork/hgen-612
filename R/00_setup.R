# ========================================================================
# CREATED: 2021-03-22
# UNIVERSAL PROJECT SETUP
# ========================================================================




# SETUP -------------------------------------------------------------------
library('fs')




# MANAGING GIT(HUB) CREDENTIALS -------------------------------------------
# see: https://usethis.r-lib.org/articles/git-credentials.html#practical-instructions
#  usethis::git_protocol()              #this should be https
#  usethis::create_github_token()       #takes you to Github; copy PAT and store in 1Password
#  gitcreds::gitcreds_set()             #paste in created Github token
#  gitcreds::gitcreds_get()
#  usethis::gh_token_help()             #check that your PAT has been successfully stored
#  usethis::git_sitrep()                #includes additional info




# PROJECT SETUP -----------------------------------------------------------

## Create project manually if folder already exists
## Will need to open this file in new RStudio instance -> File/Recent Files
usethis::create_project(path= path(path_home(), "Dropbox/projects/teaching/hgen-612-temp/"))


usethis::use_readme_md()


# From gitkraken R project template
usethis::use_git_ignore(c(".Rhistory", ".Rapp.history", ".RData", ".Ruserdata", "*-Ex.R", "/*.tar.gz", "/*.Rcheck/",
                         ".Rproj.user/", "vignettes/*.html", "vignettes/*.pdf", ".httr-oauth", "*_cache/", "/cache/",
                         "*.utf8.md", "*.knit.md", "/temp", "*.zip", "*.html", ".DS_Store"))

# Add project specific items
usethis::use_git_ignore(c("00_setup.R", "data", "*.pdf", "figures", "*.Rproj"))


# Use git as the version control manager
usethis::use_git()


# Establish a remote repo on Github
usethis::use_github(private = FALSE)


