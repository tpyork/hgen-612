# tidymodels-1
#
# After this module you should be able to:
#  - build a simple linear regression model using {parsnip}
#  - predict values for new data
#  - update {parsnip} model engine
#  - preprocess data using {recipes} and {workflows}
#  - use {broom} to report model results
# 
# Reference:  https://www.tidymodels.org




# LOAD LIBRARIES ----------------------------------------------------------
library(tidymodels)      # for the parsnip package, along with the rest of tidymodels
library(tidyverse)       # for importing data
library(dotwhisker)      # for inspecting model coefficients
library(skimr)           # for variable summaries
library(patchwork)       # plot composer
library(nycflights13)    # for flight data
library(broom.mixed)     # for converting bayesian model output to tidy tibbles




# PART 1:  BUILD A MODEL --------------------------------------------------



## * THE SEA URCHINS DATA ---------------------------------------------------
urchins_tbl <-
  # Data were assembled for a tutorial 
  # at https://www.flutterbys.com.au/stats/tut/tut7.5a.html
  # read_csv("https://tidymodels.org/start/models/urchins.csv") %>% 
  read_csv("data/urchins.csv") %>% 
  # Change the names to be a little more verbose
  setNames(c("food_regime", "initial_volume", "width")) %>% 
  # Factors are very helpful for modeling, so we convert one column
  mutate(food_regime = factor(food_regime, levels = c("Initial", "Low", "High")))

urchins_tbl %>% 
  glimpse()
# experimental feeding regime group (food_regime: either Initial, Low, or High),
# size in milliliters at the start of the experiment (initial_volume), and
# suture width at the end of the experiment (width).

# Plot raw data
urchins_plt <- urchins_tbl %>% 
  ggplot(aes(x = initial_volume, 
           y = width, 
           group = food_regime, 
           col = food_regime)) + 
  geom_point() + 
  geom_smooth(method = lm, se = FALSE) +
  scale_color_viridis_d(option = "plasma", end = .7)

urchins_plt




## * BUILD AND FIT A MODEL --------------------------------------------------

# Model specification the usual way
# 2-way ANOVA with an interaction specified
lm_fit_1 <- lm(width ~ initial_volume * food_regime, data = urchins_tbl)
lm_fit_1
summary(lm_fit_1)

lm_fit_1 %>% 
  glance()

lm_fit_1 %>% 
  tidy()


## Now let's fit the same model the {tidymodel} way
# Start by specifying the functional form of the model that we want using the parsnip package. 
lm_mod <- 
  linear_reg() %>%     #functional form of the model from {parsnip}; intercept and slopes
  set_engine("lm")     #method for fitting the model

lm_mod


# Now we can estimate the model
lm_fit_2 <- 
  lm_mod %>% 
  fit(width ~ initial_volume * food_regime, data = urchins_tbl)

lm_fit_2
lm_fit_1

lm_fit_2 %>% 
  tidy()

lm_fit_1 %>% 
  tidy()

# Visualize model coefficients
tidy(lm_fit_2) %>% 
  dwplot(dot_args = list(size = 2, color = "black"),
         whisker_args = list(color = "black"),
         vline = geom_vline(xintercept = 0, colour = "grey50", linetype = 2))




## * USE A MODEL TO PREDICT -------------------------------------------------

# Use our model to predict response values on new data
new_points <- expand.grid(initial_volume = 20, 
                          food_regime = c("Initial", "Low", "High"))
new_points


# standard approach; this is ok but specific to lm(); more later..
predict.lm(lm_fit_1, newdata = new_points)


# {tidymodels} approach; find mean values at 20ml
mean_pred <- predict(lm_fit_2, 
                     new_data = new_points)
mean_pred


# Remember the difference from Dr. Smirnova's first lecture?
conf_int_pred <- predict(lm_fit_2, 
                         new_data = new_points, 
                         type = "conf_int")
conf_int_pred


# Now combine predicted data to use for plotting 
reg_plot_df <- 
  new_points %>% 
  bind_cols(mean_pred) %>% 
  bind_cols(conf_int_pred)


# ..and plot
lm_plt <- ggplot(reg_plot_df, aes(x = food_regime)) + 
  geom_point(aes(y = .pred)) + 
  geom_errorbar(aes(ymin = .pred_lower, 
                    ymax = .pred_upper),
                width = .2) + 
  labs(y = "urchin size")
lm_plt




## * MODEL WITH A DIFFERENT ENGINE ------------------------------------------

# set the prior distribution (a Bayesian detail..)
prior_dist <- rstanarm::student_t(df = 1)
set.seed(123)


# make the parsnip model
bayes_mod <-   
  linear_reg() %>% 
  set_engine("stan", 
             prior_intercept = prior_dist, 
             prior           = prior_dist) 
bayes_mod


# train the model
bayes_fit <- 
  bayes_mod %>% 
  fit(width ~ initial_volume * food_regime, data = urchins_tbl)

bayes_fit %>% 
  tidy(conf.int = TRUE)


bayes_plot_df <- 
  new_points %>% 
  bind_cols(predict(bayes_fit, new_data = new_points)) %>% 
  bind_cols(predict(bayes_fit, new_data = new_points, type = "conf_int"))


# Compare predictions
reg_plot_df
bayes_plot_df


bayes_plt <-ggplot(bayes_plot_df, aes(x = food_regime)) + 
  geom_point(aes(y = .pred)) + 
  geom_errorbar(aes(ymin = .pred_lower, ymax = .pred_upper), width = .2) + 
  labs(y = "urchin size") + 
  ggtitle("Bayesian model with t(1) prior distribution")
bayes_plt


lm_plt + bayes_plt +  
  plot_annotation(tag_levels = "1",
                  tag_prefix = "plot_",
                  title      = "Comparison of predictiions") +
  theme_dark()

  


# PART 2. PREPROCESS YOUR DATA WITH RECIPES -------------------------------


## * THE NEW YORK CITY FLIGHT DATA ------------------------------------------
# Let’s use the nycflights13 data to predict whether a plane arrives more than 30 minutes
# late. This data set contains information on 325,819 flights departing near New York City
# in 2013. Let’s start by loading the data and making a few changes to the variables:

?flights

flight_tbl <- 
  flights %>% 
  mutate(
    # Convert the arrival delay to a factor
    arr_delay = ifelse(arr_delay >= 30, "late", "on_time"),
    arr_delay = factor(arr_delay),
    # We will use the date (not date-time) in the recipe below
    date = as.Date(time_hour)
  ) %>% 
  # Include the weather data
  inner_join(weather, by = c("origin", "time_hour")) %>% 
  # Only retain the columns we will use
  select(dep_time, flight, origin, dest, air_time, distance, 
         carrier, date, arr_delay, time_hour) %>% 
  # Exclude missing data
  na.omit() %>% 
  # For creating models, it is better to have qualitative columns
  # encoded as factors (instead of character strings)
  mutate_if(is.character, as.factor)


# Check whether this is the data you think it is..
flight_tbl %>% 
  count(arr_delay) %>% 
  mutate(prop = n/sum(n))

flight_tbl %>%   #we want to predict`arr_delay`
  glimpse()

flight_tbl %>% 
  skimr::skim() 




# Split data for training/testing
set.seed(123)

# Put 3/4 of the data into the training set 
data_split <- initial_split(flight_tbl, prop = 3/4)
data_split

# Create data frames for the two sets:
train_tbl <- training(data_split) 
test_tbl  <- testing(data_split)


# Create recipe and roles
flight_rec <- 
  recipe(arr_delay ~ ., data = train_tbl) %>% 
  update_role(flight, time_hour, new_role = "ID")                  # we will use these to track flights below

flight_rec
summary(flight_rec)


# Feature engineering using {recipes}; adding to code above
flight_rec <- 
  recipe(arr_delay ~ ., data = train_tbl) %>%                       #same as above
  update_role(flight, time_hour, new_role = "ID") %>%               #same as above
  step_date(date, features = c("dow", "month")) %>% 
  step_holiday(date, holidays = timeDate::listHolidays("US")) %>% 
  step_rm(date) %>% 
  step_dummy(all_nominal(), -all_outcomes()) %>%                    #Create dummy variables for all of the factor or character columns unless they are outcomes.
  step_zv(all_predictors())


# 17 US holidays
timeDate::listHolidays("US")

# A lot of new variables were just created automagically
flight_rec %>% prep() %>% juice() %>% glimpse()



# Some features only have values in `test_tbl` so use `step_zv()`; zero variance filter (above)
# note that dummy vars are created from all factor levels in `flight_tbl`
train_tbl %>% 
  distinct(dest) %>% 
  anti_join(test_tbl)

skimr::skim(train_tbl %>% select(dest))
skimr::skim(test_tbl %>% select(dest))



## * FIT A MODEL WITH A RECIPE ----------------------------------------------
# Model specification (as done before)
lr_mod <- 
  logistic_reg() %>% 
  set_engine("glm")


# Use a workflow to pair the model with the recipe.
# Nice b/c different recipes are often needed for different models, 
# so when a model and recipe are bundled, it becomes easier to train and test workflows. 
flight_wflow <- 
  workflow() %>% 
  add_model(lr_mod) %>% 
  add_recipe(flight_rec)

flight_wflow


# Now, there is a single function that can be used to prepare the recipe and train the model 
# from the resulting predictors
flight_fit <- 
  flight_wflow %>% 
  fit(data = train_tbl)


flight_fit %>% 
  extract_fit_parsnip() %>% 
  tidy()


# flight_fit %>%
#   extract_recipe()




## * USE A TRAINED WORKFLOW TO PREDICT --------------------------------------
# Our goal was to predict whether a plane arrives more than 30 minutes late. We have just:
#   - Built the model (lr_mod)
#   - Created a preprocessing recipe (flights_rec)
#   - Bundled the model and recipe (flights_wflow)
#   - Trained our workflow using a single call to fit()


predict(flight_fit, test_tbl)     # predicting with a trained workflow (preprocessor and model)

flight_pred <- 
  predict(flight_fit, test_tbl, type = "prob") %>% 
  bind_cols(test_tbl %>% select(arr_delay, time_hour, flight)) 


# Evaluate using {yardstick}
flight_pred %>% 
  roc_curve(truth = arr_delay, .pred_late) %>% 
  autoplot()


flight_pred %>% 
  roc_auc(truth = arr_delay, .pred_late)


flight_fit %>% 
  extract_fit_parsnip() %>% 
  vip::vip()



