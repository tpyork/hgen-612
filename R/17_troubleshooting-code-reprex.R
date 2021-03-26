# HGEN 612 - Data Science II
# Reprex - minimal reproducible examples
#
#
#
#
#################################################################################


# ****Important*****
# Restart your R session every time you test a new reprex. 




# Example 1 ---------------------------------------------------------------

library(dplyr)
library(ggplot2)

diamonds %>% 
  filter(price > 3000) %>% 
  mutate(total_all = n()) %>% 
  group_by(cut) %>% 
  summarize( total = n(),
             avg_size = mean(carat),
             sd_size = sd(carat),
  ) %>% 
  ggplot(aes(x = avg_size, y = clarity)) +
  geom_bar() 







# Example 2 ---------------------------------------------------------------

n <- 10
mydat <- data.frame(exam_1 = rnorm(n, 70, 15),
                    exam_2 = rnorm(n, 86, 5),
                    exam_3 = rnorm(n, 68, 13)
                    )

mydat$lowest_exam = apply(mydat, 2, min) 







# Example 3 ---------------------------------------------------------------

library(ggplot2)
data("mpg")

mpg %>%
  mutate(year = factor(year)) %>%
  group_by(class, year) %>%
  summarize(
    cty_avg = mean(cty),
    sd_hi = cty_avg + sd(cty),
    sd_lo = cty_avg - sd(cty)
  ) %>%
  ggplot() +
  aes(fct_reorder(class, cty_avg), cty_avg, color = year) +
  geom_pointrange(
    aes(ymin = sd_lo, 
        ymax = sd_hi),
    position = position_dodge(width = 0.5)
  ) +
  coord_cartesian(ylim(c(0,30))) +
  xlab("Class") +
  ylab("Average Fuel Efficiency") +
  labs(color = "Year") +
  ggtitle("City Fuel Efficiency by Class in Cars Manufactured in 1999 and 2008") 

# What can we immediately drop out of the code chunk?
# FODMAP-approach to troubleshooting code







# Code Senses ------------------------------------------------------------------


# CS-1: Star Wars Sentences -----------
# The code should print a sentence for each character stating their height.  

data("starwars")

for(i in 1:nrow(starwars)){
  starwars$statement[i] <- paste(starwars$name[i], 
                                 "is", 
                                 starwars$height[i], 
                                 "cm tall.")
}




# CS-1b ---------------

my_starwars <- filter(starwars, !is.na(height))

for(i in 1:nrow(my_starwars)){
  my_starwars$statement[i] <- paste(starwars$name[i], 
                                    "is", 
                                    starwars$height[i], 
                                    "cm tall.")
}









# CS-2: Dysfunctional Problems -----------------

age.calculator <- function(x){
  clean <- NULL
  for (i in 1:length(x)){
    x[is.na(x)] <- 0
    s <- x[i]
    clean[i] <- as.numeric(str_match(s, "[0-9]+"))
  }
  return(clean)
}


age.calculator("12")
age.calculator(c("11", "~14"))








# CS-3: Baby proportions -----------------

library(babynames)

babynames %>% 
  filter(between(year, 1990, 2000)) %>% 
  group_by(sex) %>% 
  mutate(total_sex = sum(babynames$n),
         propFemale = n/total_sex) %>% 
  filter(name == "Skyler") %>% 
  ggplot(aes(year, 
             propFemale, 
             linetype = sex)) +
  geom_line() 








# {reprex} ----------------------------------------------------------------

library(reprex)


n <- 10
mydat <- data.frame(exam_1 = rnorm(n, 70, 15),
                    exam_2 = rnorm(n, 86, 5),
                    exam_3 = rnorm(n, 68, 13)
)

mydat$lowest_exam = apply(mydat, 2, min) 


# https://github.com/tpyork/hgen-612






# Challenge -------------------------------------------------------------------


# Seasonal Breeding -----

# A) Create a minimal dataset that will allow us to tackle the breeding behavior 
# variables. 
# Give a thumbs up on Zoom when you are ready.



# B) Design a way to collapse the variables into a single variable.





# Take home challenge ----------------------------------------------------

# Create a reprex for the next four R errors you encounter.


