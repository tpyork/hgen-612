# Check back before each lecture for any additions ----



install.packages("devtools")
devtools::install_github("rstudio/fontawesome")


r_pkgs <- c(

  # Lecture 01_tidyverse-features ----
  "tidyverse", "tidyquant", "broom", "gt", "htmltools",
  
  # Lecture 05_flexdashboard ----
  "flexdashboard", "DT", "plotly", "corrr", "emo",

  # Lecuture 06_flexdashboard ----
  "tidymodels", "vip",
  
  # Lecture 07_Machine-Learning-Regression ----
  "ISLR", "MASS", "GGally", "ggfortify", "knitr", "kableExtra", "readxl", "car", "glmnet",
  
  # Lecture 10_tidymodels-1 ----
  "tidymodels", "patchwork", "nycflights13", "broom.mixed", "skimr", "timeDate", "rmdformats", 
  "dotwhisker", "ranger", "randomForest",
  
  # Lecture 17_troubleshooting-code-reprex ----
  "reprex",
  
  # Lecture 20_classification-2 ----
  "class", "caret", "pRoc",
  
  # Lecture 24_Shiny ----
  "themis"
    
  )


install.packages(r_pkgs)