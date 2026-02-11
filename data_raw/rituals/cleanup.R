dd <- read.csv("data_raw/rituals/rituals.csv")
library(tidyverse)
dd <- dd |> 
  janitor::clean_names()
names(dd)
rituals <- dd
save(rituals, file = "data/rituals.rda")
