#
# CLEAN DATA
#


library('tidyverse')


attach(faithful)


faithful2 <- faithful %>% 
  as_tibble() %>% 
  mutate(waiting.minute = waiting / 60)


saveRDS(faithful2, "R/git-tutorial/data/faithful2.rds")
