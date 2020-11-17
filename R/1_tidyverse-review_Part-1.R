# {tidyverse} review             ----
# 10 great functions             ---
#
# author:  T. York               ---
# credits: M. Dancho             ---




# 1.0 dplyr::relocate() ---------------------------------------------------
library('tidyverse')

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
library('tidyverse')

mpg %>% View()
# - Group By + Summarize: Super common summarization pattern
# - Summarize + Across: Scale your summarizations:
#    - Multiple columns
#    - Multiple Summary Functions (e.g. mean, sd)



# BASIC USE
# - AVERAGE CITY FUEL CONSUMPTION BY VEHICLE CLASS
mpg %>%
  group_by(class) %>%
  summarise(
    across(cty, .fns = mean),
    .groups = "drop"
  )


# AVERAGE & STDEV CITY FUEL CONSUMPTION BY VEHICLE CLASS
mpg %>%
  group_by(class) %>%
  summarise(
    across(cty, .fns = list(mean = mean, stdev = sd)), 
    .groups = "drop"
  )


# AVERAGE & STDEV CITY + HWY FUEL CONSUMPTION BY VEHICLE CLASS
mpg %>%
  group_by(class) %>%
  summarise(
    across(c(cty, hwy), .fns = list(mean = mean, stdev = sd)), 
    .groups = "drop"
  )


# ADVANCE USE
# - CUSTOMIZE NAMING SCHEME
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


# COMPLEX FUNCTIONS
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
library(tidyverse)

# PIVOT WIDER
# - Reshaping to wide format
mpg_pivot_table_1 <- mpg %>%
  group_by(manufacturer) %>%
  count(class, name = "n") %>%
  pivot_wider(names_from = class, values_from = n, values_fill = 0) %>%
  ungroup()


# PIVOT LONGER
# - Long format best for visualizations
mpg_long_summary_table <- mpg_pivot_table_1 %>%
  pivot_longer(
    cols      = compact:subcompact,
    names_to  = "class",
    values_to = "value"
  )

mpg_long_summary_table %>%
  ggplot(aes(class, manufacturer, fill = value)) +
  geom_tile() +
  geom_label(aes(label = value), fill = "white") +
  scale_fill_viridis_c() +
  theme_minimal() +
  labs(title = "Class by Auto Manufacturer")




# 4.0 dplyr::group_split; purrr::map --------------------------------------
library(tidyquant)
library(tidyverse)
library(broom)

# devtools::install_github("rstudio/fontawesome")
library(gt)
library(fontawesome)
library(htmltools)


# GROUP SPLIT
# - Turns a grouped data frame into an list of data frames (iterable)
# - Iteration & functions - Covered in Week 5 of DS4B 101-R

# Group Split
mpg %>%
  mutate(manufacturer = as_factor(manufacturer)) %>%
  group_by(manufacturer) %>%
  group_split()

# We can now iterate with map()
mpg %>%
  mutate(manufacturer = as_factor(manufacturer)) %>%
  group_by(manufacturer) %>%
  group_split() %>%
  
  map(.f = function(df) {
    lm(hwy ~ cty, data = df)
  })


# THE POWER OF BROOM
# - Tidy up our linear regression metrics with glance()
# - Modeling & Machine Learning - Covered in Week 6 of DS4B 101-R Course

hwy_vs_city_tbl <- mpg %>%
  mutate(manufacturer = as_factor(manufacturer)) %>%
  group_by(manufacturer) %>%
  group_split() %>%
  
  map_dfr(.f = function(df) {
    lm(hwy ~ cty, data = df) %>%
      glance() %>%
      add_column(manufacturer = unique(df$manufacturer), .before = 1)
  })


# SUPER AWESOME TABLE WITH GT PACKAGE
# - Advanced but it shows where we are headed with {purrr}
# - Source: https://themockup.blog/posts/2020-10-31-embedding-custom-features-in-gt-tables/
rating_stars <- function(rating, max_rating = 5) {
  rounded_rating <- floor(rating + 0.5)  # always round up
  stars <- lapply(seq_len(max_rating), function(i) {
    if (i <= rounded_rating) {
      fontawesome::fa("star", fill= "orange")
    } else {
      fontawesome::fa("star", fill= "grey")
    }
  })
  label <- sprintf("%s out of %s", rating, max_rating)
  div_out <- div(title = label, "aria-label" = label, role = "img", stars)
  
  as.character(div_out) %>%
    gt::html()
}

hwy_vs_city_tbl %>%
  select(manufacturer, nobs, r.squared, adj.r.squared, p.value) %>%
  mutate(manufacturer = str_to_title(manufacturer)) %>%
  mutate(rating = cut_number(r.squared, n = 5) %>% as.numeric()) %>%
  mutate(rating = map(rating, rating_stars)) %>%
  arrange(desc(r.squared)) %>%
  gt() %>%
  tab_header(title = gt::md("__Highway vs City Fuel Mileage__")) %>%
  tab_spanner(
    label = gt::html("<small>Relationship Strength (hwy ~ cty)</small>"),
    columns = vars(r.squared, adj.r.squared, p.value)
  ) %>%
  fmt_number(columns = vars(r.squared, adj.r.squared)) %>%
  fmt_number(columns = vars(p.value), decimals = 3) %>%
  tab_style(
    style = cell_text(size = px(12)),
    locations = cells_body(
      columns = vars(r.squared, adj.r.squared, p.value))
  ) %>%
  cols_label(
    manufacturer = gt::md("__MFG__"),
    nobs = gt::md("__#__"),
    r.squared = gt::html(glue::glue("<strong>R-Squared ", fontawesome::fa("arrow-down", fill = "orange"), "</strong>")),
    adj.r.squared = gt::md("__R-Squared (Adj)__"),
    p.value = gt::md("__P-Value__"),
    rating  = gt::md("__Rating__")
  )



