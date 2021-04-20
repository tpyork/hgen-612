# Functions
#
# After this module you should be able to:
#  - understand the basic syntax for creating a function 
#  - appreciate how functions save time and avoid errors
#  - making your functions pipe friendly
#
# r4ds
# https://r4ds.had.co.nz/functions.html
# 
# Advanced R
# https://adv-r.hadley.nz/index.html




# LIBRARIES ---------------------------------------------------------------
library(tidyverse)




# FUNCTION PATTERNS -------------------------------------------------------

# Two types of functions:
# 1. vector functions
# 2. data functiions


# 1. Vectorized function

class(mtcars$mpg)
mean(mtcars$mpg)    #takes a vector, returns a scalar
log(mtcars$mpg)     #takes a vector, returns a vector



# 2. Data function

# `summarise()` is the data function
# `mean()` is still a vector function
mtcars %>% 
  summarise(average = mean(mpg))   #takes a data.frame, returns a ???


mtcars %>% 
  mutate(log = log(mpg))           #we're starting to see a pattern, right?
                                   #tidyverse data functions handling vector functions





# STRUCTURE OF A FUNCTION -------------------------------------------------

# Objects in a function are local to the function
# The object returned can be of any data type 

# Not run
new <- function(arg1, arg2, ...) {
  statement1
  .
  .
  statementN
  return(object)
} 

new(arg1 = , arg2 = )






# EXAMPLE USING 1 ARGUEMENT: Report the mean of a vector ------------------

myfunction <- function(.x) {
  
  out <- mean(.x, na.rm = TRUE)
  return(cat("The mean of this vector is:", out))
  
}

myfunction(.x = c(1,2,3,NA))







# EXAMPLE USING 2 ARGUMENTS -----------------------------------------------

myfunction2 <- function(.x, .na) {
  # x= numeric vector
  # na= option whether missing should be excluded
  if (.na) {
    out <- mean(.x, na.rm = TRUE)
  }
  if (!.na) {
    out <- mean(.x, na.rm = FALSE)
  }
  return(cat("The mean of this vector is:", out))
  
}

myfunction2(.x = c(1,2,NA,4), .na = TRUE)






# WHERE TO STORE YOUR FUNCTIONS -------------------------------------------

# 1. Inline code

# 2. Create a file that contains all your functions
#    source("Your_File_Path/functions.R")

# 3. Create a .Rprofile file in the current working directory

# 4. --> Create your own package






# YOUR TURN:  CREATE A BMI CALCULATOR -------------------------------------

# INPUT= height, weight, formula (English/Metric)
# OUTPUT= "BMI is ___ for a weight of ___ (lbs/kg) and height of ___ (in/m)"


# English= (weight in pounds / (height in inches^2)) * 703
# Metric= (weight in kilograms / (height in meters^2)



bmi_calc <- function(h, w, type) {
  
  .
  .
  .
  
}






# STORING OUTPUT FROM FUNCTIONS IN A LIST ---------------------------------

powers <- function(.x) {
  
  out <- list(p2 = .x * .x, 
              p3 = .x * .x * .x, 
              p4 = .x * .x * .x * .x)
  return(out)
  
}

powers(7)


# Functions return evaluations in a list structure all the time
# What problems might occur (think `broom`)?
# What is the solution?







# WRITE PIPE FRIENDLY FUNCTIONS -------------------------------------------

set.seed(12345)
data_tbl <- tibble(height = rnorm(100, 70, 3),
                   weight = rnorm(100, 180, 15))




bmi_calc_2 <- function(.h, .w) {
  bmi <- ((.w / .h^2) * 703) %>% round(2)
  return(bmi)
}


bmi_calc_2(70, 150)

bmi_calc_2(c(70, 71, 72), c(150, 151, 152))

bmi_calc_2(data_tbl$height, data_tbl$weight)



data_tbl %>% 
  mutate(bmi = bmi_calc_2(height, weight))




# what if we wanted to make our function fully pipe compliant?
data_tbl %>% 
  bmi_calc_2(height, weight)




# How about this?
add_bmi <- function(.data, .h, .w) {
  
  .data %>% 
    mutate(bmi = bmi_calc_2(.h, .w))
  
}

data_tbl %>% 
  add_bmi(height, weight)





# Sidebar: We can control how and when R evaluates expressions
1 + 2
expr(1 + 2)
eval(expr(1 + 2))
eval(parse(text = "1 + 2"))


class(expr(1 + 2))
lm(height ~ weight, data = data_tbl)




# enquo(): Freezes column names before they cause errors
# 1. capture expressions before they are evaluated
# 2. evaluate when ready
#
# Don't get bogged down in details unless you want to take a
#  deep dive into `rlang` : https://rlang.r-lib.org/
#  Take-home: 'rlang` facilitates working with the R language and tidyverse

add_bmi_2 <- function(.data, .h, .w) {
  
  h_expr <- enquo(.h)   #freeze the expression/call here
  w_expr <- enquo(.w)
  
  .data %>% 
    mutate(bmi = bmi_calc_2(!!h_expr, !!w_expr))
  
}
  

data_tbl %>% 
  add_bmi_2(height, weight)

  
  
    
  

# SUMMARY -----------------------------------------------------------------

# You should consider writing a function whenever you’ve copied and pasted a block of
# code more than twice (i.e. you now have three copies of the same code).

# It’s easier to start with working code and turn it into a function; it’s harder 
# to create a function and then try to make it work.

# 3 Key Steps:
# - You need to pick a name for the function.
# - You list the inputs, or arguments, to the function inside `function`
# - You place the code you have developed in body of the function

# Generally, function names should be verbs, and arguments should be nouns.

# If your function name is composed of multiple words, I recommend using “snake_case”,
# where each lowercase word is separated by an underscore.

# Generally, data arguments should come first in a function. Detail arguments should go 
# on the end, and usually should have default values. 

# It’s good practice to check important preconditions, and throw an error (with stop()), 
# if they are not true.

# The value returned by the function is usually the last statement it evaluates, but you can 
# choose to return early by using return().


