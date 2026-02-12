#' Stroop Mean Reaction Times by Participant and Condition
#'
#' Aggregated reaction time data from the Stroop task in Lin et al. (2020). 
#' This dataset contains mean reaction times for each participant across 
#' conditions (control/deplete) and congruency levels (congruent/incongruent),
#' derived from the trial-level `stroop` dataset.
#'
#' @format A data frame with 2,740 rows and 5 variables:
#' \describe{
#'   \item{study_id}{Study identifier (s1, s2, s3, s4), character. Indicates 
#'     which of the four studies the participant was in.}
#'   \item{participant_id}{Participant identifier within study, character. 
#'     Unique within each study but not across studies.}
#'   \item{condition}{Experimental condition, factor with 2 levels:
#'     \itemize{
#'       \item \strong{control}: Low-demand initial task
#'       \item \strong{deplete}: High-demand initial task (ego depletion manipulation)
#'     }}
#'   \item{congruency}{Stroop trial congruency, factor with 2 levels:
#'     \itemize{
#'       \item \strong{congruent}: Word and color match
#'       \item \strong{incongruent}: Word and color mismatch (requires inhibition)
#'     }}
#'   \item{rt}{Mean reaction time in seconds, numeric. Calculated as the mean 
#'     of all valid trials for this participant-condition-congruency combination.}
#' }
#'
#' @details
#' ## Data Processing
#' This dataset was created from the trial-level `stroop` data by:
#' \enumerate{
#'   \item Grouping by participant (`pno`), `condition`, `study`, and `congruency`
#'   \item Calculating mean reaction time across trials (excluding NAs)
#'   \item Separating the composite `pno` variable into `study_id` and 
#'     `participant_id` components
#'   \item Removing the redundant `study` variable
#' }
#' 
#' ## Experimental Design
#' Each participant completed both control and deplete conditions (within-subjects 
#' design), with each condition containing both congruent and incongruent Stroop 
#' trials. This yields 4 observations per participant (2 conditions × 2 congruency 
#' levels).
#' 
#' ## Key Findings from Lin et al. (2020)
#' The high-demand (deplete) manipulation:
#' \itemize{
#'   \item Reliably elicited strong effort phenomenology
#'   \item Reduced response caution (boundary parameter in drift-diffusion models)
#'   \item Did NOT reduce information-processing speed (drift rate)
#'   \item Did NOT affect subsequent inhibitory control on the Stroop task
#' }
#' 
#' The authors concluded that effort exertion reduces response caution rather 
#' than inhibitory control, suggesting people become less cautious and more 
#' disengaged after exerting effort.
#'
#' @source
#' Derived from the `stroop` dataset in this package, which contains the 
#' original trial-level data from:
#' 
#' Lin, H., Saunders, B., Friese, M., Evans, N. J., & Inzlicht, M. (2020). 
#' Strong Effort Manipulations Reduce Response Caution: A Preregistered 
#' Reinvention of the Ego-Depletion Paradigm. \emph{Psychological Science}, 
#' \doi{10.1177/0956797620904990}
#'
#' @seealso \code{\link{stroop}} for the original trial-level data
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#' library(ggplot2)
#' 
#' # Compare reaction times across conditions
#' stroop_means |>
#'   group_by(condition, congruency) |>
#'   summarize(mean_rt = mean(rt), sd_rt = sd(rt))
#' 
#' # Calculate Stroop effect (incongruent - congruent) by condition
#' stroop_effect <- stroop_means |>
#'   pivot_wider(names_from = congruency, values_from = rt) |>
#'   mutate(stroop_effect = incongruent - congruent)
#' 
#' # Visualize Stroop effect by condition
#' stroop_means |>
#'   ggplot(aes(x = condition, y = rt, fill = congruency)) +
#'   geom_boxplot() +
#'   facet_wrap(~ study_id) +
#'   labs(title = "Stroop Performance by Condition and Study",
#'        y = "Mean RT (seconds)",
#'        x = "Condition")
#' 
#' # Test depletion effect on Stroop interference
#' library(lme4)
#' model <- lmer(rt ~ condition * congruency + (1|study_id/participant_id),
#'               data = stroop_means)
#' summary(model)
#' }
"stroop_means"