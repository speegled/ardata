library(tidyverse)
physics <- read.csv("data_raw/phsyics/pone.0249086.s002.csv") |> 
  janitor::clean_names()
save(physics, file = "data/physics.rda")