# tidymodels recode !
#
# Recode the pine beetle analysis using the tidymodels workflow.
# Original code at the end of this script.




# LIBRARIES ----
library(tidyverse)
library(readxl)
library(broom)
library(car)
library(ggfortify)
library(tidymodels)
library(vip)




# DATA ----
pine_tbl <- read_excel("instructor/katia/Data/Data_1993.xlsx", sheet = 1)




# LINEAR REGRESSION ----

# Base R Version ----
lm_fit <- lm(DeadDist ~ TreeDiam + Infest_Serv1 +  SDI_20th + BA_20th, data = pine_tbl)

lm_fit %>%
  tidy()
  
lm_fit %>% 
  glance()

vif(lm_fit)


# * Refit the model without basal area indicator ----
lm_fit.nc <- lm(DeadDist  ~ TreeDiam + Infest_Serv1 + SDI_20th, data = pine_tbl)

lm_fit.nc %>%
  tidy()

lm_fit.nc %>% 
  glance()

vif(lm_fit.nc)


# * Checking assumptions ----
ggfortify:::autoplot.lm(lm_fit.nc, which = 1:2, label.size = 2) +
  theme_bw()


# * Feature Engineering ----
# Variable transformation
pine_tbl <- pine_tbl %>% 
  mutate(DeadDist_log = log(pine_tbl$DeadDist)) %>% 
  mutate(DeadDist_sqrt = sqrt(pine_tbl$DeadDist))




# * Model assumptions: log-transform ----
lm_fit.nc.log <- lm(DeadDist_log  ~ TreeDiam + Infest_Serv1 + SDI_20th, data = pine_tbl)
autoplot(lm_fit.nc.log, which = 1:2, label.size = 1)+
  theme_bw()


# * Model assumptions: square-root transform ----
lm_fit.nc.sqrt <- lm(DeadDist_sqrt  ~ TreeDiam + Infest_Serv1 + SDI_20th, data = pine_tbl)
autoplot(lm_fit.nc.sqrt, which = 1:2, label.size = 1) +
  theme_bw()


lm_fit.nc.sqrt %>%
  tidy()

lm_fit.nc.sqrt %>% 
  glance()


# Tidymodels Version ----
#  Specify, fit and evaluate same models with tidymodels

# * Create Recipe ----
## specify variable relationships
## specify (training) data
## feature engineer
## process recipe on data
pine_rec <- pine_tbl %>% 
  recipe(DeadDist ~ TreeDiam + Infest_Serv1 +  SDI_20th + BA_20th) %>% 
  step_sqrt(all_outcomes()) %>% 
  step_corr(all_predictors()) #%>% 
  # prep()


# View feature engineered data
pine_rec %>% 
  prep() %>% 
  juice()


# * Create Model ----
lm_mod <- 
  linear_reg() %>% 
  set_engine("lm")


# * Create Workflow ----
pine_wflow <- 
  workflow() %>% 
  add_model(lm_mod) %>% 
  add_recipe(pine_rec)

pine_wflow


pine_fit <- 
  pine_wflow %>% 
  fit(data = pine_tbl)


pine_fit %>% 
  extract_fit_parsnip() %>% 
  tidy()

pine_fit %>% 
  extract_fit_parsnip() %>% 
  glance()


pine_fit %>% 
  extract_preprocessor()

pine_fit %>% 
  extract_spec_parsnip()




# RIDGE REGRESSION ----

# Tidymodels Version ----

# * Create Ridge Regression Model ----
# penalty == lambda
# mixture == alpha
# Note: parsinp allows for a formula method (formula specified in recipe above)
# Remember that glmnet() require a matrix specification


# Create training/testing data
pine_split <- initial_split(pine_tbl)
pine_train <- training(pine_split)
pine_test <- testing(pine_split)


# picking Dr. Smirnova's best lambda estimate; can estimate with tune() - see below
ridge_mod <-
  linear_reg(mixture = 0, penalty = 0.1629751) %>%  #validation sample or resampling can estimate this
  set_engine("glmnet")

# verify what we are doing
ridge_mod %>% 
  translate()
  

# create a new recipe; could use `add_step()` to recipe created above
pine_rec <- pine_train %>% 
  recipe(DeadDist ~ TreeDiam + Infest_Serv1 + SDI_20th + BA_20th) %>% 
  step_sqrt(all_outcomes()) %>% 
  step_corr(all_predictors()) %>% 
  step_normalize(all_numeric(), -all_outcomes()) %>% 
  step_zv(all_numeric(), -all_outcomes()) #%>% 
  # prep()


pine_ridge_wflow <- 
  workflow() %>% 
  add_model(ridge_mod) %>% 
  add_recipe(pine_rec)

pine_ridge_wflow


pine_ridge_fit <- 
  pine_ridge_wflow %>% 
  fit(data = pine_train)


pine_ridge_fit %>% 
  extract_fit_parsnip() %>% 
  tidy()


pine_ridge_fit %>% 
  extract_preprocessor()

pine_ridge_fit %>% 
  extract_spec_parsnip()


# refit best model on training and evaluate on testing
last_fit(
  pine_ridge_wflow,
  pine_split
) %>%
  collect_metrics()


# verify Ridge Regression performance with standard linear regression approach
lm(sqrt(DeadDist) ~ TreeDiam + Infest_Serv1 + BA_20th, data = pine_tbl) %>% 
  glance()




# LASSO ----

# create bootstrap samples for resampling and tuning the penalty parameter
set.seed(1234)
pine_boot <- bootstraps(pine_train)

# create a grid of tuning parameters
lambda_grid <- grid_regular(penalty(), levels = 50)


lasso_mod <-
  linear_reg(mixture = 1, penalty = tune()) %>% 
  set_engine("glmnet")

# verify what we are doing
lasso_mod %>% 
  translate()


# create workflow
pine_lasso_wflow <- 
  workflow() %>% 
  add_model(lasso_mod) %>% 
  add_recipe(pine_rec)


set.seed(2020)
lasso_grid <- tune_grid(
  pine_lasso_wflow,
  resamples = pine_boot,
  grid = lambda_grid
)


# let's look at bootstrap results
lasso_grid %>%
  collect_metrics()


lasso_grid %>%
  collect_metrics() %>%
  ggplot(aes(penalty, mean, color = .metric)) +
  geom_errorbar(aes(
    ymin = mean - std_err,
    ymax = mean + std_err
  ),
  alpha = 0.5
  ) +
  geom_line(size = 1.5) +
  facet_wrap(~.metric, scales = "free", nrow = 2) +
  scale_x_log10() +
  theme(legend.position = "none")


# We have a couple of options for choosing our final parameter, such as 
# select_by_pct_loss() or select_by_one_std_err(), but for now let’s stick
# with just picking the lowest RMSE. After we have that parameter, we can 
# finalize our workflow, i.e. update it with this value.
# see https://juliasilge.com/blog/lasso-the-office/

lowest_rmse <- lasso_grid %>%
  select_best("rmse")

# update our final model with lowest rmse
final_lasso <- finalize_workflow(
  pine_lasso_wflow,
  lowest_rmse
)



final_lasso %>% 
  fit(pine_train) %>%
  pull_workflow_fit() %>% 
  tidy()
# note that penalty (lambda) is close to zero; hence near equivalent to lm() solution  


# variable importance plot
final_lasso %>%
  fit(pine_train) %>%
  pull_workflow_fit() %>%
  vi(lambda = lowest_rmse$penalty) %>%
  mutate(
    Importance = abs(Importance),
    Variable = fct_reorder(Variable, Importance)
  ) %>%
  ggplot(aes(x = Importance, y = Variable, fill = Sign)) +
  geom_col() +
  scale_x_continuous(expand = c(0, 0)) +
  labs(y = NULL)



last_fit(
  final_lasso,
  pine_split
) %>%
  collect_metrics()




# # ORIGINAL MODEL CODE ----
# library(glmnet)
# #convert x into a matrix of predictors and
# #transform any qualitative variables into a dummy variable
# fm <- as.formula("DeadDist~TreeDiam +  Infest_Serv1+ SDI_20th +BA_20th")
# x=model.matrix(fm, pine_tbl)[,-1]
# y = pine_tbl$DeadDist
# 
# # set possible values of tuning parameter lambda
# grid=10^seq(10,-2,length=100) 
# #fit the model 
# ridge.mod=glmnet(x,y,alpha=0,lambda=grid)
# 
# dim(coef(ridge.mod))
# ridge.mod$lambda[50] #Display 50th lambda value
# round(coef(ridge.mod)[,50],4) # Display coefficients associated with 50th lambda value
# sqrt(sum(coef(ridge.mod)[-1,50]^2)) # Calculate the magnitude of regression coefficients
# 
# 
# #compare to the magnitude for the small lambda (i.e. regular lease squares)
# ridge.mod$lambda[100] #Display 100th lambda value
# round(coef(ridge.mod)[,100],4) # Display coefficients associated with 100th lambda value
# sqrt(sum(coef(ridge.mod)[-1,100]^2)) # Calculate the magnitude of regression coefficients
# 
# 
# cv.fit <- cv.glmnet(x,y,alpha=0, lambda=grid)
# plot(cv.fit)
# 
# 
# # Value of $\lambda$ that gives minimum mean cross-validated error
# cv.fit$lambda.min
# 
# # Value of $\lambda$ for the model such that with that error is within one standard error of the minimum
# cv.fit$lambda.1se
# 
# # Ridge regression: tuning parameters
# plot(ridge.mod, xvar='lambda', label = TRUE)
# abline(v = log(cv.fit$lambda.min), col="red", lwd=3, lty=2)
# abline(v = log(cv.fit$lambda.1se), col="blue", lwd=2, lty=1)
# 
# coef(ridge.mod, s = cv.fit$lambda.min)
# coef(cv.fit, s = "lambda.1se")
# ridge.fitted <- predict(cv.fit, newx = x, s = "lambda.min")
# mean((ridge.fitted - y)^2)



