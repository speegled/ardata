dd <- read.csv("/Users/speegled/Documents_No_Icloud/R_projects/ardata/data_raw/weatherHistory.csv")
dd <- janitor::clean_names(dd)
dd$pressure_millibars[dd$pressure_millibars < 1] <- NA

library(lubridate)
library(tidyverse)
dd <- dd %>% 
  mutate(date = floor_date(ymd_hms(formatted_date), "day"))

Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

dd <- dd %>% 
  group_by(date) %>% 
  summarize(across(where(is.numeric), mean),
            summary = factor(Mode(summary)),
            precip_type = factor(Mode(precip_type))) 

dd <- dd %>% 
  group_by(summary) %>% 
  mutate(n = n()) %>% 
  ungroup() %>% 
  mutate(summary = as.character(summary)) %>% 
  mutate(summary = ifelse(n < 15, NA_character_, summary)) %>% 
  mutate(summary = factor(summary)) %>%
  select(-apparent_temperature_c, -loud_cover, -n)

dd <- dd[round(seq(1, nrow(dd), length.out = 1000)),]
dd <- dd[sample(nrow(dd)),] %>% 
  select(-date)

weather_history <- dd
save(weather_history, file = "data/weather_history.rda")
