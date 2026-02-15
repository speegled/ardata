library(afex)
library(tidyverse)

data(stroop)

stroop_means <- stroop %>%
  group_by(pno, condition, study, congruency) %>%
  summarize(rt = mean(rt, na.rm = TRUE), .groups="drop")
ss <- stroop_means |> 
  separate_wider_delim(pno, delim = "_", names = c("study_id", "participant_id")) |> 
  select(-study)
stroop_means <- ss
save(stroop_means, file = "stroop_means.rda")
