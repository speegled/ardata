library(tidyverse)
pp <- read.csv(here::here("data_raw/planning_time/sokoban_alldata.txt"), sep = " ") |> 
  janitor::clean_names() |> 
  as_tibble()
summary(pp)

pp <- pp |> 
  rowwise() |> 
  mutate(result = prod(c(result1, result2, result3, result4, result5, result6, result7, result8, result9, result10))) |>
  filter(result > 0) |> 
  ungroup()

library(lme4)
pp <- pp |> 
  select(matches("gender|age|pt|step")) |> 
  rownames_to_column(var = "subject")  |> 
  pivot_longer(matches("pt|step"), names_to = "name", values_to = "value") |>
  separate_wider_regex(name, c(measure = "[a-z]+", task = "[0-9]+"), too_few = "align_start") 

pp <- pp |> 
  group_by(subject, task) |> 
  mutate(rep = cumsum(measure == "pt")) 

pp <- pp |> 
  pivot_wider(values_from = value, names_from = measure, id_cols = c(subject, task, rep)) |> 
  select(-rep)
planning_time <- pp
save(planning_time, file = "data/planning_time.rda")
head(planning_time)
