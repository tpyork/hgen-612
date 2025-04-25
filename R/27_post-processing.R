# Post-Processing Prediction Models
#
# Examine calibration of prediction probabilities



# LIBRARIES ---------------------------------------------------------------
# Core
library(tidymodels)  

# Post-processing
library(probably)
library(yardstick)

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
tabyl(hotels$children) %>% 
  knitr::kable()




# DATA SPLITTING AND RESAMPLING -------------------------------------------
set.seed(123)
splits <- initial_split(hotels, strata = children)

hotel_tr <- training(splits)
hotel_te  <- testing(splits)


#resampling
hotel_rs <- vfold_cv(hotel_tr, strata = children)




# PENALIZED LOGISTIC REGRESSION -------------------------------------------
lr_mod <- 
  logistic_reg(mixture = 1, penalty = tune()) %>% 
  set_engine("glmnet")

# * Create the recipe ----
holidays <- c("AllSouls", "AshWednesday", "ChristmasEve", "Easter", 
              "ChristmasDay", "GoodFriday", "NewYearsDay", "PalmSunday")


# DOWNSAMPLE ----  
lr_recipe_down <- 
  recipe(children ~ ., data = hotel_tr) %>%   #remember that `hotel_other` is just a template here
  step_date(arrival_date) %>% 
  step_holiday(arrival_date, holidays = holidays) %>% 
  step_rm(arrival_date) %>% 
  step_dummy(all_nominal(), -all_outcomes()) %>% 
  step_zv(all_predictors()) %>% 
  step_normalize(all_predictors()) %>% 
  themis::step_downsample(children, under_ratio = 1)


# * Create the workflow ----
lr_workflow_down <- 
  workflow() %>% 
  add_model(lr_mod) %>% 
  add_recipe(lr_recipe_down)


# * Update the tune ----
# Tune the model on the downsampled `val_set`
lr_reg_grid <- tibble(penalty = 10^seq(-4, -1, length.out = 30))

lr_res_down <- 
  lr_workflow_down %>% 
  tune_grid(resamples = hotel_rs, #rset object
            grid      = lr_reg_grid,
            control   = control_grid(save_pred = TRUE), #needed to get data for ROC curve
            metrics   = metric_set(roc_auc))

lr_res_down %>% 
  collect_metrics() 

lr_best_down <- 
  lr_res_down %>% 
  collect_metrics() %>% 
  arrange(penalty) %>%  #print(n = 30)
  slice(13)
lr_best_down


# Add best validation model to workflow
lr_workflow_down_best <- finalize_workflow(
  lr_workflow_down,
  lr_best_down       #needs to have the same column name as tune()
)



# * Fit best model on downsampled training data ----
met <- metric_set(roc_auc, brier_class)

# We'll save the out-of-sample predictions to visualize them. 
ctrl <- control_resamples(save_pred = TRUE)

log_res <- 
  lr_workflow_down_best %>% 
  fit_resamples(hotel_rs, metrics = met, control = ctrl)

collect_metrics(log_res)   #brier_class >0.25 is bad


#is it calibrated?
collect_predictions(log_res) %>%
  ggplot(aes(.pred_children)) +
  geom_histogram(col = "white", bins = 40) +
  facet_wrap(~ children, ncol = 1) +
  geom_rug(col = "blue", alpha = 1 / 2) + 
  labs(x = "Probability Estimate of children")


cal_plot_breaks(log_res)
cal_plot_windowed(log_res, step_size = 0.025)


#logistic regression remedy
# fit a logistic regression model to the data (with the probability estimates as the predictor). 
# The probability predictions from this model are then used as the calibrated estimate. 
logit_val <- cal_validate_logistic(log_res, metrics = met, save_pred = TRUE)
collect_metrics(logit_val)


collect_predictions(logit_val) %>%
  filter(.type == "calibrated") %>%
  cal_plot_windowed(truth = children, estimate = .pred_children, step_size = 0.025) +
  ggtitle("Logistic calibration via GAM")

#isotonic regression (alternative)
set.seed(1212)
iso_val <- cal_validate_isotonic_boot(log_res, metrics = met, 
                                      save_pred = TRUE, times = 25)
collect_metrics(iso_val)

collect_predictions(iso_val) %>%
  filter(.type == "calibrated") %>%
  cal_plot_windowed(truth = children, estimate = .pred_children, step_size = 0.025) +
  ggtitle("Isotonic regression calibration")




#test set results
hotel_cal <- cal_estimate_beta(log_res)
log_fit <- lr_workflow_down_best %>% fit(data = hotel_tr)

hotel_test_pred <- augment(log_fit, new_data = hotel_te)
hotel_test_pred %>% met(children, .pred_children)


hotel_test_cal_pred <-
  hotel_test_pred %>%
  cal_apply(hotel_cal)
hotel_test_cal_pred %>% dplyr::select(children, starts_with(".pred_"))


#calibrated test set results
hotel_test_cal_pred %>% met(children, .pred_children)

hotel_test_cal_pred %>%
  cal_plot_windowed(truth = children, estimate = .pred_children, step_size = 0.025)




