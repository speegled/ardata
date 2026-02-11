accent = read.table(here::here("data_raw/accent/osfstorage-archive (2)/Data Files/accentRate.txt"), T)
summary(accent)
library(tidyverse)
aa <- accent |> 
  mutate(across(where(is.character), factor)) |> 
  as_tibble()
accent <- aa
save(accent, file = here::here("data/accent.rda"))
