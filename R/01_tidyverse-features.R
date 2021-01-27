# {tidyverse} features           ----
# great tidyverse functions      ---
#
# author:  T. York               ---
# credits: M. Dancho             ---
#          G. Karamanis          ---




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
?arrange

mpg %>% 
  arrange(displ)

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


# YOUR TURN <><><><><><><><><><><><><>
# Move `manufacturer` before `cyl`




# - Move multiple columns by data type
mpg %>%
  relocate(where(is.numeric))

mpg %>%
  relocate(where(is.character))

mpg %>%
  relocate(where(is.character), .after = last_col())



# YOUR TURN <><><><><><><><><><><><><>
# Move all variables that start with "m" before year





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

# see ?summarise re .groups; what if you set .groups to "keep" ?



# AVERAGE & STDEV CITY FUEL CONSUMPTION BY VEHICLE CLASS
mpg %>%
  group_by(class) %>%
  summarise(
    across(cty, .fns = list(mean = mean, stdev = sd)), 
    .groups = "drop"
  )


# OR purrr STYLE TILDAS (YOU'LL LEARN THIS NEXT WEEK)
# mpg %>%
#   group_by(class) %>%
#   summarise(
#     across(cty, list(mean = ~ mean(.x, na.rm = TRUE),
#                      stdev = ~ sd(.x, na.rm = TRUE))),
#     .groups = "drop"
#   )




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
      .names = "{.fn} {.col} Consumption"     #see ?across
    ),
    .groups = "drop"
  ) %>%
  rename_with(.fn = str_to_upper)


# COMPLEX FUNCTIONS (NOTICE THE TILDAS)
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
# - Advanced but it shows where we are headed with {purrr}
library(tidyquant)
library(tidyverse)
library(broom)

# devtools::install_github("rstudio/fontawesome")
library(gt)
library(fontawesome)
library(htmltools)


# GROUP SPLIT
# - Turns a grouped data frame into an list of data frames (iterable)

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
hwy_vs_city_tbl <- mpg %>%
  mutate(manufacturer = as_factor(manufacturer)) %>%
  group_by(manufacturer) %>%
  group_split() %>%
  
  map_dfr(.f = function(df) {
    lm(hwy ~ cty, data = df) %>%
      glance() %>%
      add_column(manufacturer = unique(df$manufacturer), .before = 1)
  })




# CREATE TABLE OF RESULTS WITH EMBEDDED skimr HISTOGRAMS
# Inspiration from https://github.com/gkaramanis/tidytuesday/tree/master/2020-week39
mpg2 <- mpg %>%
  group_by(manufacturer) %>% 
  mutate(hist = inline_hist(hwy, n_bins = 7)) %>% 
  ungroup() %>% 
  distinct(manufacturer, hist)


hwy_vs_city_hist_tbl <- 
  left_join(hwy_vs_city_tbl, mpg2, by = "manufacturer") %>% 
  select(manufacturer, nobs, r.squared, p.value, hist) %>% 
  mutate(across(where(is.numeric), round, 3)) %>% 
  mutate(manufacturer = str_to_title(manufacturer)) %>% 
  arrange(desc(r.squared))


hwy_vs_city_hist_tbl %>% 
  gt() %>% 
  data_color(
    columns = vars(r.squared),
    colors = scales::col_numeric(
      palette = c(
        "grey10", "grey30", "grey97"),
      domain = c(0, 1)
    )
  ) %>% 
  tab_header(
    title = "Relationship between City and Highway Mileage",
    subtitle = "lm(formula = hwy ~ cty)"
  ) %>% 
  tab_source_note("Data Source: ggplot2::mpg") %>% 
  cols_label(
    manufacturer = "Manufacturer",
    nobs         = "Obs.",
    r.squared    = "R-squared",
    p.value      = "P-value",
    hist         = "Distribution of Highway Mileage"
  ) %>% 
  cols_width(
    vars(manufacturer) ~ px(85),
    vars(nobs)         ~ px(80),
    vars(r.squared)    ~ px(85),
    vars(p.value)      ~ px(85),
    vars(hist)         ~ px(160)
  ) %>% 
  tab_style(
    style = cell_text(font = "Proxima Nova"),
    locations = cells_body(columns = 1)
  ) %>% 
  tab_style(
    style = cell_text(font = "IBM Plex Sans Condensed"),
    locations = cells_body(columns = 2:4)
  ) %>% 
  tab_style(
    style = cell_text(font = "Graphik Compact", weight = "bold"),
    locations = cells_column_labels(columns = gt::everything())
  ) %>% 
  tab_style(
    style = cell_text(font = "Graphik Compact"),
    locations = cells_title()
  ) %>% 
  tab_style(
    style = cell_text(font = "Graphik Compact"),
    locations = cells_row_groups()
  ) %>% 
  tab_options(
    table.layout = "auto",
    row_group.border.top.width = px(5),
    row_group.border.top.color = "white",
    row_group.border.bottom.width = px(1),
    row_group.border.bottom.color = "lightgrey",
    table.border.top.color = "white",
    table.border.top.width = px(5),
    table.border.bottom.color = "white",
    column_labels.border.bottom.color = "white",
    column_labels.border.bottom.width = px(1),
    column_labels.border.top.width = px(10),
    column_labels.border.top.color = "white"
  ) 





# BONUS CODE: TABLE WITH GT PACKAGE SHOWING RATING STARS
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




# 5.0 BONUS: Keyboard Shortcuts -------------------------------------------
## Note: Option::Mac as Alt::PC

# 1. The pipe, [Command + Shift + M] ----
iris %>% head()



# 2. Commenting/Uncommenting, [Ctrl + Shift + C] ----
iris %>% head()



# 3. Assignment, [Option + -] ----
iris2 <- iris



# 4. Select Multiple Lines, [Ctrl + Option + Up/Down] ----
library(tidyverse)
library(ggplot2)
library(gt)
library(tidymodels)



# 5. Find in Files, [Ctrl + Shift + F] ----





# 6. Get All Keyboard Shortcuts,  [Option + Shift + K] ----












