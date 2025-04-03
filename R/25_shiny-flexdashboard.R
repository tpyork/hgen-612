# Shiny flexdashboard
#
# Build a model to predict which actual hotel stays included children and/or babies.
# Examine case imbalance.
# https://www.tidymodels.org/start/case-study/




# LIBRARIES ---------------------------------------------------------------
library(tidymodels)  

# Helper packages
library(readr)       # for importing data
library(vip)         # for variable importance plots
library(janitor)     # for tabyl
library(forcats)     # for factor operations



# IMPORT DATA -------------------------------------------------------------
hotels <- 
  # read_csv('https://tidymodels.org/start/case-study/hotels.csv') %>%
  read_csv('data/hotels.csv') %>% 
  mutate_if(is.character, as.factor) 




# INSPECT DATA ------------------------------------------------------------

# Data summary
glimpse(hotels)


# 1-way table
tabyl(hotels$children) %>% 
  knitr::kable()


# 2-way table
hotels %>% 
  tabyl(children, hotel) %>% 
  knitr::kable()




# DATA SPLITTING AND RESAMPLING -------------------------------------------
# For a data splitting strategy, let’s reserve 25% of the stays to the test set. 
# We know our outcome variable children is pretty imbalanced so we’ll use a 
# stratified random sample.

set.seed(123)
splits <- initial_split(hotels, strata = children)

hotel_other <- training(splits)
hotel_test  <- testing(splits)

# training set proportions by children
tabyl(hotel_other$children)

# test set proportions by children
tabyl(hotel_test$children)



# Create a single resample called a validation set. 
# In tidymodels, a validation set is treated as a single iteration of resampling. This will
# be a split from the 37,500 stays that were not used for testing, which we called hotel_other. 
# This split creates two new datasets:
#  - the set held out for the purpose of measuring performance, called the validation set.
#  - the remaining data used to fit the model, called the training set.
set.seed(234)
val_set <- validation_split(hotel_other, 
                            strata = children, 
                            prop   = 0.80)
val_set
class(val_set)     # inherits rset object
?tune_grid         # see resamples argument




# PENALIZED LOGISTIC REGRESSION -------------------------------------------
# Use a model that can perform feature selection during training (LASSO).


# * Create the model ----
# We’ll set the penalty argument to tune() as a placeholder for now. This is
# a model hyperparameter that we will tune to find the best value for making 
# predictions with our data. Setting mixture to a value of one means that the 
# glmnet model will potentially remove irrelevant predictors and choose a simpler model.
lr_mod <- 
  logistic_reg(mixture = 1, penalty = tune()) %>% 
  set_engine("glmnet")

# verify what we are doing
lr_mod %>% 
  translate()


# * Create the recipe ----
holidays <- c("AllSouls", "AshWednesday", "ChristmasEve", "Easter", 
              "ChristmasDay", "GoodFriday", "NewYearsDay", "PalmSunday")

lr_recipe <- 
  recipe(children ~ ., data = hotel_other) %>%   #remember that `hotel_other` is just a template here
  step_date(arrival_date) %>% 
  step_holiday(arrival_date, holidays = holidays) %>% 
  step_rm(arrival_date) %>% 
  step_dummy(all_nominal(), -all_outcomes()) %>% 
  step_zv(all_predictors()) %>% 
  step_normalize(all_predictors())


# Lots of new variables
lr_recipe %>%
  prep() %>%
  juice() %>% 
  glimpse()


lr_recipe %>%
  prep() %>%
  juice() %>% 
  ggplot(aes(children)) +
  geom_bar()


# * Create the workflow ----
lr_workflow <- 
  workflow() %>% 
  add_model(lr_mod) %>% 
  add_recipe(lr_recipe)


# * Create tuning grid ----
# `length.out` will determine how many penalty values are tested in `tune_grid()`
lr_reg_grid <- tibble(penalty = 10^seq(-4, -1, length.out = 30))


# Train and tune the model
lr_res <- 
  lr_workflow %>% 
  tune_grid(resamples = val_set, #rset object
            grid      = lr_reg_grid,
            control   = control_grid(save_pred = TRUE), #needed to get data for ROC curve
            metrics   = metric_set(roc_auc))



# * Validation results ----
# View ROC validation results
# This plots shows us that model performance is generally better at
# the smaller penalty values. This suggests that the majority of 
# the predictors are important to the model.
lr_res %>% 
  collect_metrics() 

lr_plot <- 
  lr_res %>% 
  collect_metrics() %>% 
  ggplot(aes(x = penalty, y = mean)) + 
  geom_point() + 
  geom_line() + 
  ylab("Area under the ROC Curve") +
  scale_x_log10(labels = scales::label_number())
lr_plot 


top_models <-
  lr_res %>% 
  show_best(metric = "roc_auc", n = 15) %>% 
  arrange(penalty) 
top_models


lr_best <- 
  lr_res %>% 
  collect_metrics() %>% 
  arrange(penalty) %>% 
  slice(12)
lr_best


# Sometimes we may want to choose a penalty value further along the x-axis, 
# closer to where we start to see the decline in model performance
# since it has effectively the same performance as the numerically 
# best model, but might eliminate more predictors. But for this example
# we will go with the `penalty` from best model.
lr_plot + 
  geom_vline(xintercept     = lr_best$penalty,
                 color      = 'red',
                 linetype   = 'dotted')


lr_auc <- 
  lr_res %>% 
  collect_predictions(parameters = lr_best) %>% 
  roc_curve(children, .pred_children) %>% 
  mutate(model = "Logistic Regression")

autoplot(lr_auc)



# * Fit best model on training data ----

# Add best validation model to workflow
lr_workflow_best <- finalize_workflow(
  lr_workflow,
  lr_best       #needs to have the same column name as tune()
)


# Inspect fit on entire training data
lr_fit <-
  lr_workflow_best %>% 
  fit(hotel_other)

lr_fit %>%
  extract_fit_parsnip() %>% 
  tidy()


# variable importance plot
lr_fit %>% 
  # pluck(".workflow", 1) %>%   
  extract_fit_parsnip() %>% 
  vip(num_features = 20, 
      aesthetics = list(color = 'blue', fill = "grey50", size = 0.3))


# * Last fit ----
lr_last_fit <-
  last_fit(
    lr_workflow_best,
    splits
  ) 




# Inspect fit metrics and diagnostics
lr_last_fit %>%
  collect_metrics()


lr_last_fit %>%
  collect_predictions()


lr_conf_mat <-
  lr_last_fit %>%
  collect_predictions() %>% 
  conf_mat(truth = children, estimate = .pred_class) 


lr_conf_mat %>% 
  autoplot(type = "heatmap")


lr_conf_mat %>%
  summary() %>%
  select(-.estimator) %>% 
  knitr::kable()


# Looks like our algorithm is optimizing over the `accuracy`
# Options might include: downsample, upsample, change classification decision
# See: Subsample for class imbalance: https://www.tidymodels.org/learn/models/sub-sampling/



# DOWNSAMPLE ----  
# Down-sampling is intended to be performed on the training set alone. Why?
# For this reason, the default is skip = TRUE. It is advisable to use 
# prep(recipe, retain = TRUE) when preparing the recipe; in this way 
# juice() can be used to obtain the down-sampled version of the data.


# * Update the recipe ----
lr_recipe_down <- 
  recipe(children ~ ., data = hotel_other) %>%   #remember that `hotel_other` is just a template here
  step_date(arrival_date) %>% 
  step_holiday(arrival_date, holidays = holidays) %>% 
  step_rm(arrival_date) %>% 
  step_dummy(all_nominal(), -all_outcomes()) %>% 
  step_zv(all_predictors()) %>% 
  step_normalize(all_predictors()) %>% 
  themis::step_downsample(children, under_ratio = 1)


lr_recipe_down %>%
  prep() %>%
  juice() %>%
  ggplot(aes(children)) +
  geom_bar()


# * Update the workflow ----
lr_workflow_down <-
  lr_workflow %>% 
  update_recipe(lr_recipe_down)


# * Update the tune ----
# Tune the model on the downsampled `val_set`
lr_res_down <- 
  lr_workflow_down %>% 
  tune_grid(resamples = val_set, #rset object
            grid      = lr_reg_grid,
            control   = control_grid(save_pred = TRUE), #needed to get data for ROC curve
            metrics   = metric_set(roc_auc))

lr_res_down %>% 
  collect_metrics() 


lr_best_down <- 
  lr_res_down %>% 
  collect_metrics() %>% 
  arrange(penalty) %>% 
  slice(12)
lr_best_down



# Add best validation model to workflow
lr_workflow_down_best <- finalize_workflow(
  lr_workflow_down,
  lr_best_down       #needs to have the same column name as tune()
)


# * Fit best model on downsampled training data ----
lr_fit_down <-
  lr_workflow_down_best %>% 
  fit(hotel_other)

lr_fit_down %>%
  extract_fit_parsnip() %>% 
  tidy()


# * Last fit ----
lr_last_fit_down <-
  last_fit(
    lr_workflow_down_best,
    splits
  ) 


lr_last_fit_down %>%
  collect_metrics()

# Compare to:
# lr_last_fit %>%
#   collect_metrics()



lr_conf_mat_down <-
  lr_last_fit_down %>%
  collect_predictions() %>% 
  conf_mat(truth = children, estimate = .pred_class) 


lr_conf_mat_down %>% 
  autoplot(type = "heatmap")

# Compare to:
# lr_conf_mat %>%
#   autoplot(type = "heatmap")


lr_conf_mat_down %>%
  summary() %>% 
  select(-.estimator) %>% 
  knitr::kable()

# Compare to:
# lr_conf_mat %>%
#   summary() %>%
#   select(-.estimator) %>%
#   knitr::kable()




# WHERE TO NEXT ? ----
