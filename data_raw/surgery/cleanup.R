library(tidyverse)
dd <- read.csv(here::here("data_raw/back_surgery/pone.0334455.s001.csv"))
dd <- dd |> 
  as_tibble() |> 
  janitor::clean_names()

data <- dd
required_names <- c(
  "identification_code",
  "sex",
  "age",
  "height",
  "bmi_kg_m2",
  "asa_score",
  "time_before_surgery",
  "low_back_pain",
  "rheumatoid_arthritis",
  "history_of_surgical_anesthesia",
  "physical_activity",
  "first_pass_success",
  "number_of_attempts",
  "total_operation_time",
  "vas_score",
  "nrs_score",
  "satisfaction",
  "dysesthesia",
  "puncture_method",
  "postoperative_low_back_pain",
  "postoperative_headache",
  "fracture_type",
  "anesthesiologist"
)
missing_names <- setdiff(required_names, names(data))

if (length(missing_names) > 0) {
  stop(
    "The following required columns are missing: ",
    paste(missing_names, collapse = ", "),
    call. = FALSE
  )
}

dd <- dplyr::as_tibble(data) |>
  dplyr::mutate(
    identification_code = as.character(identification_code),
    sex = factor(sex, levels = c(1, 2), labels = c("Male", "Female")),
    asa_score = factor(asa_score, levels = c(1, 2), labels = c("ASA I-II", "ASA III")),
    low_back_pain = factor(low_back_pain, levels = c(0, 1), labels = c("No", "Yes")),
    rheumatoid_arthritis = factor(rheumatoid_arthritis, levels = c(0, 1), labels = c("No", "Yes")),
    history_of_surgical_anesthesia = factor(
      history_of_surgical_anesthesia,
      levels = c(0, 1),
      labels = c("No", "Yes")
    ),
    physical_activity = factor(
      physical_activity,
      levels = c(1, 2),
      labels = c("Mild-Moderate", "Severe")
    ),
    first_pass_success = factor(
      first_pass_success,
      levels = c(0, 1),
      labels = c("No", "Yes")
    ),
    satisfaction = factor(satisfaction, levels = c(0, 1), labels = c("No", "Yes")),
    dysesthesia = factor(dysesthesia, levels = c(0, 1), labels = c("No", "Yes")),
    puncture_method = factor(
      puncture_method,
      levels = c(1, 2),
      labels = c("Median", "Paramedian")
    ),
    postoperative_low_back_pain = factor(
      postoperative_low_back_pain,
      levels = c(0, 1),
      labels = c("No", "Yes")
    ),
    postoperative_headache = factor(
      postoperative_headache,
      levels = c(0, 1),
      labels = c("No", "Yes")
    ),
    fracture_type = factor(
      fracture_type,
      levels = c(1, 2),
      labels = c("Distal lower limb", "Proximal lower limb")
    ),
    anesthesiologist = factor(
      anesthesiologist,
      levels = c(1, 2, 3, 4),
      labels = c("A", "B", "C", "D")
    )
  ) 

back_surgery <- dd
surgery <- back_surgery
save(surgery, file = "data/surgery.rda")
rm("data/back_surgery.rda")
