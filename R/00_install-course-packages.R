# Check back before each lecture for any additions ----



devtools::install_github("rstudio/fontawesome")


r_pkgs <- c(

  # Lecture 01_tidyverse-features ----
  "tidyverse", "tidyquant", "broom", "gt", "htmltools",
  
  # Lecture 05_flexdashboard ----
  "flexdashboard", "DT", "plotly", "corrr", "emo",

  # Lecuture 06_flexdashboard ----
  "tidymodels", "vip",
  
  # Lecture 07_Machine-Learning-Regression ----
  "ISLR", "MASS", "GGally", "ggfortify", "knitr", "kableExtra", "readxl"
  
    
  )


install.packages(r_pkgs)