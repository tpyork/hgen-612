# {flexdashboard} introduction   ----
#
# author:  T. York               ---
# credits: M. Dancho             ---




# LIBRARIES ----
library(tidymodels)
library(vip)
library(tidyverse)




# DATA ----
mpg




# DATA WRANGLING ----
data_prepared_tbl <- mpg %>%
  select(displ:class) %>%
  mutate(trans = ifelse(str_detect(trans, "auto"), "auto", "manual")) %>%
  relocate(year, .before = 1) %>%
  mutate(year = as.factor(year))




# TRAIN / TEST SPLITS ----
set.seed(123)
splits <- data_prepared_tbl %>%
  initial_split(prop = 0.80)

splits




# MODELING ----
model_fit_glm <- logistic_reg() %>%
  set_engine("glm") %>%
  fit(year ~ . , data = training(splits))

model_fit_glm


# can accomplish the same results with `stats` 
glm(year ~ ., family = "binomial", data = training(splits))




# PREDICTION ----
prediction_class_test <- predict(model_fit_glm, new_data = testing(splits), type = "class")

prediction_prob_test  <- predict(model_fit_glm, new_data = testing(splits), type = "prob")

results_tbl <- bind_cols(
  prediction_class_test,
  prediction_prob_test,
  testing(splits)
)




# EVALUATION: AUC ----
results_tbl %>%
  roc_auc(year, .pred_1999)

temp <- results_tbl %>%
  roc_auc(year, .pred_1999)
names(temp)
temp$.estimate

results_tbl %>%
  roc_curve(year, .pred_1999) %>%
  autoplot(
    options = list(
      smooth = TRUE
    )
  )




# FEATURE IMPORTANCE ----

# * Visualize Most Important Features ----
# lots of arguements for vip plot
model_fit_glm$fit %>%
  vip(
    num_features = 20,
    geom         = "point",
    aesthetics   = list(
      size     = 4,
      color    = "#18bc9c"
    )
  ) +
  theme_minimal(base_size = 18) +
  labs(title = "Logistic Regression: Feature Importance")


# * Visualize Top Features ----
data_prepared_tbl %>%
  ggplot(aes(class, hwy, colour = year)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.25) +
  theme_minimal(base_size = 18) +
  scale_color_viridis_d(end = 0.4, option = "viridis") +
  labs(title = "Older Vehicles have Lower Fuel Economy") 

# How would you make this a plotly graph ?

