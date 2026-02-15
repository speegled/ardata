accent = read.table(here::here("data_raw/accent/osfstorage-archive (2)/Data Files/accentRate.txt"), T)
summary(accent)
library(tidyverse)
aa <- accent |> 
  mutate(across(where(is.character), factor)) |> 
  as_tibble()
accent <- aa
save(accent, file = here::here("data/accent.rda"))
library(lmerTest)

# Basic model with random intercepts for participants and sentences
model1 <- lmer(rating ~ voiceC + (1|pp) + (1|sentence), data = accent)
summary(model1)

# Interpretation:
# - Fixed effect of voiceC tests whether ratings differ between self and other
# - Random intercept (1|pp) allows each participant to have their own baseline
#   rating tendency (some people might be systematically harsher raters)
# - Random intercept (1|sentence) allows each sentence to have its own baseline
#   difficulty (some sentences might be intrinsically harder to pronounce)

# Example 2: Model comparison to test the importance of random effects
# Is the participant random intercept necessary?
model_no_pp <- lmer(rating ~ voiceC + (1|sentence), data = accent)
anova(model1, model_no_pp)
