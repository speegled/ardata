aa <- read.csv("data_raw/exercise/li_ren_fan_psm1_english.csv")
head(aa)
exercise <- aa
save(exercise, file = c("data/exercise.rda"))
