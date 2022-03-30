# portfoliodown
#
# After this module you should be able to:
#  - build a personal website from the posterdown template
#  - push to github
#  - connect to Netlify
#  - make your professional life public
# 
# Reference:  
# https://www.r-bloggers.com/2021/12/introducing-portfoliodown-the-data-science-portfolio-website-builder/
# https://medium.com/nerd-for-tech/cabuilding-a-data-science-portfolio-website-in-15-minutes-84f93501bad8




# CREATE NEW PROJECT ------------------------------------------------------
usethis::create_project(path= path(path_home(), "Dropbox/projects/teaching/temp-612/"))
## Will need to open this file in new RStudio instance -> File/Recent Files


# use github
usethis::use_git_ignore()

usethis::use_git()

usethis::use_github(private = TRUE)




# LIBRARIES ---------------------------------------------------------------
devtools::install_github("business-science/portfoliodown")

library(portfoliodown)




# CREATE NEW PORTFOLIO ----------------------------------------------------
# run once
new_portfolio_site()


# build website
serve_site()



# NEXT --------------------------------------------------------------------

# push to Github
# connect with Netlify
# deploy changes






