library(tidyverse)
dd <- readxl::read_xlsx("data_raw/cardiac_arrest/journal.pone.0279776.s002.xlsx") |> 
  janitor::clean_names() 
summary(dd)

# Clean KORHN-PRO cardiac arrest dataset from:
# Lee et al. (2022), PLOS ONE 17(12): e0279776
# https://doi.org/10.1371/journal.pone.0279776
#
# This script:
#   1. reads the raw Excel file,
#   2. renames variables to cleaner R-friendly names,
#   3. converts categorical variables to factors with meaningful labels,
#   4. leaves continuous variables numeric.

library(readxl)
library(dplyr)
library(forcats)

# ---- read data ----
raw_dat <- readxl::read_xlsx("data_raw/cardiac_arrest/journal.pone.0279776.s002.xlsx")

# ---- rename variables ----
dat <- raw_dat %>%
  rename(
    id = ID,
    sex = `Sex (1, male; 2, female)`,
    age_years = `age (years)`,
    body_mass_index = `Body mass index`,
    coronary_artery_disease = `coroanry artery dz (1, yes; 0, no)`,
    heart_failure = `heart failure (1, yes; 0, no)`,
    hypertension = `hypertension (1, yes; 0, no)`,
    diabetes = `diabetes (1, yes; 0, no)`,
    previous_stroke = `previous stroke (1, yes; 0, no)`,
    pulmonary_disease = `pulmonary dz (1, yes; 0, no)`,
    renal_disease = `renal dz (1, yes; 0, no)`,
    liver_cirrhosis = `liver cirrhosis (1, yes; 0, no)`,
    witness_collapse = `Witness collapse (1, yes; 0, no)`,
    bystander_cpr = `Bystander CPR (1, yes; 0, no)`,
    shockable_rhythm = `Shockable rhythm (1, shockable; 0, non-shockable)`,
    cardiac_etiology = `cardiac etiology (1, cardiac; 0, non-cardiac)`,
    time_to_rosc = `time to ROSC`,
    epinephrine = epinephrine,
    lactate = lactate,
    paco2 = PaCO2,
    pao2 = PaO2,
    pre_ttm_shock = `Pre-TTM shock (1, yes; 2, no)`,
    sofa = SOFA,
    target_temperature = `Target temperature (1, 33-34; 2, 35-36)`,
    glucose_after_rosc = `glucose after ROSC`,
    maximum_glucose = `maximum glucose`,
    mean_glucose = `mean glucose`,
    sd_glucose = `SD of glucose`,
    minimum_glucose = `mininum glucose`,
    moderate_hypoglycemia = `moderatre hypoglycemia (1, yes; 0, no)`,
    severe_hypoglycemia = `severe hypoglycemia (1, yes; 0, no)`,
    neurological_outcome = `neurological outcome (1, poor; 0, good)`,
    insulin_method = `insulin administration method (1, SQI; 2, IBI; 3, CII)`
  )

# ---- helper for labelled factors ----
yes_no_factor <- function(x) {
  factor(x, levels = c(0, 1), labels = c("No", "Yes"))
}

# ---- convert categorical variables to factors ----
dat <- dat %>%
  mutate(
    sex = factor(sex, levels = c(1, 2), labels = c("Male", "Female")),
    
    coronary_artery_disease = yes_no_factor(coronary_artery_disease),
    heart_failure = yes_no_factor(heart_failure),
    hypertension = yes_no_factor(hypertension),
    diabetes = yes_no_factor(diabetes),
    previous_stroke = yes_no_factor(previous_stroke),
    pulmonary_disease = yes_no_factor(pulmonary_disease),
    renal_disease = yes_no_factor(renal_disease),
    liver_cirrhosis = yes_no_factor(liver_cirrhosis),
    witness_collapse = yes_no_factor(witness_collapse),
    bystander_cpr = yes_no_factor(bystander_cpr),
    
    shockable_rhythm = factor(
      shockable_rhythm,
      levels = c(0, 1),
      labels = c("Non-shockable", "Shockable")
    ),
    
    cardiac_etiology = factor(
      cardiac_etiology,
      levels = c(0, 1),
      labels = c("Non-cardiac", "Cardiac")
    ),
    
    pre_ttm_shock = factor(
      pre_ttm_shock,
      levels = c(1, 2),
      labels = c("Yes", "No")
    ),
    
    target_temperature = factor(
      target_temperature,
      levels = c(1, 2),
      labels = c("33-34 C", "35-36 C")
    ),
    
    moderate_hypoglycemia = yes_no_factor(moderate_hypoglycemia),
    severe_hypoglycemia = yes_no_factor(severe_hypoglycemia),
    
    neurological_outcome = factor(
      neurological_outcome,
      levels = c(0, 1),
      labels = c("Good", "Poor")
    ),
    
    insulin_method = factor(
      insulin_method,
      levels = c(1, 2, 3),
      labels = c("SQI", "IBI", "CII")
    )
  )

# ---- optional: set reference levels commonly used in modeling ----
dat <- dat %>%
  mutate(
    sex = fct_relevel(sex, "Male"),
    shockable_rhythm = fct_relevel(shockable_rhythm, "Non-shockable"),
    cardiac_etiology = fct_relevel(cardiac_etiology, "Non-cardiac"),
    pre_ttm_shock = fct_relevel(pre_ttm_shock, "No"),
    target_temperature = fct_relevel(target_temperature, "33-34 C"),
    neurological_outcome = fct_relevel(neurological_outcome, "Good"),
    insulin_method = fct_relevel(insulin_method, "CII")
  )

# ---- quick checks ----
str(dat)
summary(select(dat,
               sex, coronary_artery_disease, heart_failure, hypertension, diabetes,
               previous_stroke, pulmonary_disease, renal_disease, liver_cirrhosis,
               witness_collapse, bystander_cpr, shockable_rhythm, cardiac_etiology,
               pre_ttm_shock, target_temperature, moderate_hypoglycemia,
               severe_hypoglycemia, neurological_outcome, insulin_method
))

# dat is the cleaned analysis dataset
# Example:
# glm(neurological_outcome ~ mean_glucose + shockable_rhythm,
#     data = dat, family = binomial)

summary(dat)
cardiac_arrest <- dat
save(cardiac_arrest, file = "data/cardiac_arrest.rda")
