aa <- read.csv("data_raw/ai_detection/milicka_ai_detection_exam_data.csv")
head(aa)
ai_detection <- aa
save(ai_detection, file = c("data/ai_detection.rda"))
