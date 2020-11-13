# {tidyverse} review             ----
# 10 great functions             ---
#
# author:  T. York               ---
# credits: M. Dancho             ---



library('tidyverse')



# 1.0 dplyr::relocate() ---------------------------------------------------
ggplot2::mpg


# - select() is like filter() for columns
mpg %>%
  select(model, manufacturer, class, year)

# - relocate() is like arrange() for columns
mpg  %>%
  relocate(model, manufacturer, class, year)

?relocate

mpg %>%
  select(everything())



# - Move single column by position
mpg %>%
  relocate(manufacturer, .after = class)

?last_col

mpg %>%
  relocate(manufacturer, .after = last_col())

mpg %>%
  relocate(manufacturer, .after = last_col(offset = 1))



# - Move multiple columns by data type
mpg %>%
  relocate(where(is.numeric))

mpg %>%
  relocate(where(is.character))

mpg %>%
  relocate(where(is.character), .after = last_col())



# - Use tidyselect to match columns
mpg %>%
  relocate(starts_with("m"), .before = year)




# 2.0 dplyr::across() -----------------------------------------------------
mpg %>% View()
# - Group By + Summarize: Super common summarization pattern
# - Summarize + Across: Scale your summarizations:
#    - Multiple columns
#    - Multiple Summary Functions (e.g. mean, sd)



# - BASIC USE
# * AVERAGE CITY FUEL CONSUMPTION BY VEHICLE CLASS
mpg %>%
  group_by(class) %>%
  summarise(
    across(cty, .fns = mean),
    .groups = "drop"
  )


# * AVERAGE & STDEV CITY FUEL CONSUMPTION BY VEHICLE CLASS
mpg %>%
  group_by(class) %>%
  summarise(
    across(cty, .fns = list(mean = mean, stdev = sd)), 
    .groups = "drop"
  )


# * AVERAGE & STDEV CITY + HWY FUEL CONSUMPTION BY VEHICLE CLASS
mpg %>%
  group_by(class) %>%
  summarise(
    across(c(cty, hwy), .fns = list(mean = mean, stdev = sd)), 
    .groups = "drop"
  )


# - ADVANCE USE
# * CUSTOMIZE NAMING SCHEME
mpg %>%
  group_by(class) %>%
  summarise(
    across(
      c(cty, hwy),
      .fns = list(mean = mean, stdev = sd),
      .names = "{.fn} {.col} Consumption"
    ),
    .groups = "drop"
  ) %>%
  rename_with(.fn = str_to_upper)


# * COMPLEX FUNCTIONS
mpg %>%
  group_by(class) %>%
  summarise(
    across(
      c(cty, hwy),
      .fns = list(
        "mean"     = ~ mean(.x),
        "range lo" = ~ (mean(.x) - 2*sd(.x)),
        "range hi" = ~ (mean(.x) + 2*sd(.x))
      ),
      .names = "{.fn} {.col}"
    ),
    .groups = "drop"
  ) %>%
  rename_with(.fn = str_to_upper)




# 3.0 tidyr::pivot_wider; tidyr::pivot::longer ----------------------------







