library(tidyverse)
dd <- read.csv("/Users/speegled/Downloads/2018-2021_Daily_Attendance_by_School.csv")
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

#source: https://catalog.data.gov/dataset/2018-2021-daily-attendance-by-school


