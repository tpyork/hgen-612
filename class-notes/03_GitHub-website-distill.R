

# CREATE NEW GITHUB REPO NAMED `username.github.io`
# CLONE REPO IN RSTUDIO USING NEW PROJECT GIT VERSION CONTROL


install.packages("distill")

library(distill)

create_website(dir = ".", title = "Building websites with Distill", gh_pages = TRUE)

# RESTART RSTUDIO TO GET 'BUILD WEBSITE' BUTTON

library(distill)

# BUILD WEBSITE

# GO TO seankross/postcards AND CHECK OUT TEMPLATES

install.packages("postcards")

# delete existing index.Rmd

create_article(file = "index", template = "trestles", package = "postcards")  #new home page

# add to end of yaml
site: distill::distill_website

# edit name; add new picture

# add social media addresses; add target to open in new page
url: "https://linkedin.com/in/timothy-york-40b972160 target = '_blank' "

# build website again; stage, commit, push to GitHub

# in GitHub go to Settings / Pages
# Deploy from Branch  
# main  /  /docs  and then hit Save

# More Resources - Jenny Sloane !!
# https://www.youtube.com/playlist?list=PLpZT7JPM8_GZlqEssUJ6ABm0rblI1cBEW

# Quarto
# https://drganghe.github.io/quarto-academic-site-examples.html
# https://github.com/drganghe/quarto-academic-website-template




