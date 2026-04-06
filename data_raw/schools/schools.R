library(tidyverse)
dd <- read.csv("data_raw/schools/2018-2021_Daily_Attendance_by_School.csv")
dd <- dd |> 
  janitor::clean_names() |> 
  as_tibble()

dd[280408,]
unique(dd$school_year)

dd <- bind_rows(dd |> 
  #mutate(date2 = date) |> 
  filter(school_year < 20202021) |> 
  mutate(date = lubridate::mdy(date)),
dd |> 
  filter(school_year == 20202021) |>
  mutate(date = str_extract(date, "[0-9]{4}-[0-9]+-[0-9]+")) |> 
  mutate(date = lubridate::ymd(date)))

dd <- dd |> 
  mutate(dow = lubridate::wday(date, label = T),
         month = lubridate::month(date, label = T)) 
dd <- dd |> 
  mutate(school_year = factor(school_year))
summary(dd)
dd <- dd[complete.cases(dd),]
summary(dd)

unique(dd$school_dbn)
dd <- dd %>%
  mutate(
    district = str_sub(school_dbn, 1, 2),
    borough_code = str_sub(school_dbn, 3, 3),
    borough = recode(
      borough_code,
      M = "Manhattan",
      X = "Bronx",
      K = "Brooklyn",
      Q = "Queens",
      R = "Staten Island"
    )
  )

summary(dd)
head(dd)
tail(dd)
#source: https://catalog.data.gov/dataset/2018-2021-daily-attendance-by-school

library(glmmTMB )
glmmTMB(absent ~ (1|school_dbn) + offset(log(enrolled)), family = poisson, data = dd)

set.seed(20260406)
set.seed(20260406)

# one row per school, excluding District 75
school_frame <- dd %>%
  distinct(school_dbn, district, borough) %>%
  filter(district != "75")

# proportional allocation of 100 schools across boroughs
alloc <- school_frame %>%
  count(borough, name = "N_borough") %>%
  mutate(
    raw_n = 100 * N_borough / sum(N_borough),
    n_sample = floor(raw_n),
    remainder = raw_n - n_sample
  ) %>%
  arrange(desc(remainder)) %>%
  mutate(
    n_sample = n_sample + if_else(
      row_number() <= 100 - sum(n_sample),
      1L,
      0L
    )
  ) %>%
  select(borough, n_sample)

# sample schools within each borough, then keep all rows for those schools
sampled_schools <- school_frame %>%
  left_join(alloc, by = "borough") %>%
  group_split(borough) %>%
  purrr::map_dfr(~ dplyr::slice_sample(.x, n = .x$n_sample[1])) %>%
  select(school_dbn)

dd_sample <- dd %>%
  filter(district != "75") %>%
  semi_join(sampled_schools, by = "school_dbn")

dd <- dd_sample

dd <- dd |> 
  filter(enrolled > 0)
m1 <- glmmTMB(absent ~ (1|school_dbn) + offset(log(enrolled)), family = poisson, data = dd)
summary(m1)
performance::check_overdispersion(m1)
performance::check_zeroinflation(m1)

m2 <- glmmTMB(
  absent ~ (1 | school_dbn) + offset(log(enrolled)),
  family = nbinom2,
  data = dd
)

performance::check_overdispersion(m2)
performance::check_zeroinflation(m2)

m3 <- glmmTMB(
  absent ~ (1 | school_dbn) + offset(log(enrolled)),
  ziformula = ~1,
  family = nbinom2,
  data = dd
)

performance::check_overdispersion(m3)
performance::check_zeroinflation(m3)

m4 <- glmmTMB(
  absent ~ dow + (1 | school_dbn) + offset(log(enrolled)),
  family = nbinom2,
  data = dd
)

m5 <- glmmTMB(
  absent ~ dow + (1 | school_dbn) + offset(log(enrolled)),
  ziformula = ~1,
  family = nbinom2,
  data = dd
)


summary(m4)
summary(m5)

AIC(m2, m3, m4, m5)

performance::check_overdispersion(m4)
performance::check_zeroinflation(m4)

performance::check_overdispersion(m5)
performance::check_zeroinflation(m5)

m6 <- glmmTMB(
  absent ~ dow + month + (1 | school_dbn) + offset(log(enrolled)),
  family = nbinom2,
  data = dd
)

m7 <- glmmTMB(
  absent ~ dow + month + (1 | school_dbn) + offset(log(enrolled)),
  ziformula = ~1,
  family = nbinom2,
  data = dd
)

dd <- dd |> 
  mutate(dow = factor(dow, ordered = FALSE),
         month = factor(month, ordered = FALSE))
summary(m6)
summary(m7)

AIC(m4, m5, m6, m7)

performance::check_overdispersion(m6)
performance::check_zeroinflation(m6)

performance::check_overdispersion(m7)
performance::check_zeroinflation(m7)
AIC(m5, m6, m7)

library(marginaleffects)
avg_predictions(m7, variables = "dow", type = "response")
