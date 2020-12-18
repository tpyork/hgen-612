# Model Estimation
#
# After this module you should be able to:
#  - understand how model parameters are estimated 
#  - appreciate how the general idea behind modern data mining methods to 
#    search a family of models to select the best fit




# LOAD LIBRARIES AND OPTIONS ----------------------------------------------
library('tidyverse')
library('modelr')

options(na.action= na.warn)




# A SIMPLE MODEL ----------------------------------------------------------

## Take a look at some raw data
sim1

ggplot(sim1, aes(x, y)) + 
  geom_point()


## Looks linear, right?
## y = a_1 + a_2 * x




## Create a bunch of random models
models <- tibble(
  a1 = runif(250, -20, 40),
  a2 = runif(250, -5, 5)
)


## We have a lot of choices !
ggplot(sim1, aes(x, y)) + 
  geom_abline(aes(intercept = a1, slope = a2), data = models, alpha = 1/4) +
  geom_point() 




## How to tell which model is good and which is bad ?
model1 <- function(a, data) {
  a[1] + data$x * a[2]
}

model1(c(7, 1.5), sim1)




## Now we need a summary metric of distance between predicted versus observed values
## root-mean-squared deviation
measure_distance <- function(mod, data) {
  diff <- data$y - model1(mod, data)
  sqrt(mean(diff ^ 2))
}

measure_distance(c(7, 1.5), sim1)



## Now let's compute this distance metric for all our models
sim1_dist <- function(a1, a2) {
  measure_distance(c(a1, a2), sim1)
}

models <- models %>% 
  mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))
models



## Plot the 10 best models
best.10 <- ggplot(sim1, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(
    aes(intercept = a1, slope = a2, colour = dist), data = filter(models, rank(dist) <= 10)
  )
best.10




# Another way to visualize the universe of models
ggplot(models, aes(a1, a2)) +
  geom_point(data = filter(models, rank(dist) <= 10), size = 4, colour = "red") +
  geom_point(aes(colour = dist))




## A more systematic approach
grid <- expand.grid(
  a1 = seq(-5, 20, length = 25),
  a2 = seq(1, 3, length = 25)
) %>% 
  mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))

grid %>% 
  ggplot(aes(a1, a2)) +
  geom_point(data = filter(grid, rank(dist) <= 10), size = 4, colour = "red") +
  geom_point(aes(colour = dist)) 



ggplot(sim1, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(
    aes(intercept = a1, slope = a2, colour = -dist), 
    data = filter(grid, rank(dist) <= 10)
  )
#compare to `best.10`



## Numerical optimization solution
best <- optim(c(0, 0), measure_distance, data = sim1)
best$par




## YOUR TURN: plot this model on the oberved data points
##            did the optimization do what we wanted ?

ggplot(sim1, aes(x= x, y= y)) +
  geom_point(colour= 'grey30') +
  geom_??






## Is there another solution to estimating parameters (besides the one below)?

slope <- function(dat) {
  x <- dat$x
  y <- dat$y
  diff.x <- x - mean(x)
  diff.y <- y - mean(y)
  sum.product <- sum(diff.x * diff.y)
  sum.x.diff.squared <- sum(diff.x^2)
  return(sum.product / sum.x.diff.squared)
}


fit.curve <- function(dat) {
  b <- slope(dat)
  a <- mean(sim1$y) - b*mean(sim1$x)
  return(list(a, b))
}


fit.curve(sim1)




###
