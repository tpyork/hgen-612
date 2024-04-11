# Check back before each lecture for any additions ----



install.packages("devtools")
devtools::install_github("rstudio/fontawesome")
devtools::install_github("hadley/emo")
devtools::install_github("business-science/portfoliodown")


r_pkgs <- c(

  # tidyverse-features ----
  "tidyverse", "tidyquant", "broom", "gt", "htmltools",
  
  # flexdashboard ----
  "flexdashboard", "DT", "plotly", "corrr",

  # flexdashboard ----
  "tidymodels", "vip",
  
  # Machine-Learning-Regression ----
  "ISLR", "MASS", "GGally", "ggfortify", "knitr", "kableExtra", "readxl", "car", "glmnet",
  
  # tidymodels-1 ----
  "tidymodels", "patchwork", "nycflights13", "broom.mixed", "skimr", "timeDate", "rmdformats", 
  "dotwhisker", "ranger", "randomForest",
  
  # troubleshooting-code-reprex ----
  "reprex",
  
  # classification-2 ----
  "class", "caret", "pRoc",
  
  # Shiny ----
  "themis",

  # Shiny ----
  "scales", "wesanderson",
  
  # Shiny ----
  "shinyWidgets", "shinyjs"
    
)

install.packages(r_pkgs)

