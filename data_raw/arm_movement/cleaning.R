library(tidyverse)
dd <- read.csv("data_raw/arm_movement/data_arm_movement_evaluation.csv")
arm_movement <- dd |> 
  janitor::clean_names() |> 
  select(id, datetime, baseline_mean, passive_middle, passive_out, passive_in, active_middle, active_out, active_in, sex, age)
arm_movement <- arm_movement |> 
  mutate(datetime = lubridate::ymd_hms(datetime))
save(arm_movement, file = "data/arm_movement.rda")
