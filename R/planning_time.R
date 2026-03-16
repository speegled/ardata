#' Planning Time by Participant and Task
#'
#' Planning time data from the Sokoban game-based assessment in Li et al. (2020).
#' This dataset contains planning times and solution route lengths for each
#' participant across 10 puzzle tasks, used to investigate the relationship
#' between planning and execution in problem solving.
#'
#' @format A data frame with rows for each participant-task combination and
#'   4 variables:
#' \describe{
#'   \item{subject}{Participant identifier, character. Unique across participants.}
#'   \item{task}{Task identifier (1–10), character. Each task is a distinct
#'     Sokoban puzzle with a unique required solution route.}
#'   \item{pt}{Planning time in milliseconds, integer. Recorded as the elapsed
#'     time from the start of a task to the participant's first move.
#'     Participants were instructed to plan before moving, as the first move
#'     could not be undone.}
#'   \item{step}{Number of steps in the optimal solution route, integer. Used
#'     as an indicator of task difficulty and route length. Positively correlated
#'     with both planning time (r = 0.59) and execution time (r = 0.97) on the
#'     log scale.}
#' }
#'
#' @details
#' ## Assessment Design
#' The Sokoban-based assessment was developed by Li et al. (2015) from a
#' Japanese puzzle game. In each task, participants maneuver a pusher to move
#' boxes onto target locations. Two constraints apply:
#' \itemize{
#'   \item Only one box may be pushed at a time
#'   \item Boxes cannot be pulled
#' }
#' Each task was redesigned so that the first move is the only correct move —
#' any other first move leads to an unsolvable state. This design allows clean
#' separation of planning time (time to first move) from execution time (time
#' from first move to task completion).
#'
#' ## Sample
#' Data were collected from 266 college students (65 male, 201 female) at a
#' Chinese university (age range 18–31, M = 20.70, SD = 1.56). Pass rates
#' ranged from 80% to 96% per task. Analyses in Li et al. (2020) focus on
#' the 119 participants who completed all 10 tasks successfully (43 male,
#' 76 female; age range 18–27, M = 20.70, SD = 1.48).
#'
#' ## Data Processing Notes
#' \itemize{
#'   \item Planning and execution times were right-skewed; a log transformation
#'     is recommended prior to analysis (Box-Cox analysis confirmed the log
#'     scale as optimal).
#'   \item After log transformation: execution time closely approximated
#'     normality (KS D = 0.03, p = 0.07); planning time was improved but
#'     still significantly non-normal (KS D = 0.04, p < 0.001).
#'   \item Only successful trials contribute execution times; failed trials
#'     (incorrect first move) have no execution time recorded.
#' }
#'
#' ## Key Findings from Li et al. (2020)
#' \itemize{
#'   \item Planning speed and execution speed were \strong{positively correlated}
#'     at the latent variable level, consistent with a general mental speed
#'     factor (Danthiir et al., 2012).
#'   \item After controlling for individual and item differences, observed
#'     planning time had a \strong{negative conditional dependency} on execution
#'     time: spending more time planning was associated with faster execution.
#'   \item The negative dependency varied significantly across tasks (item-specific
#'     dependency model outperformed the general dependency model) and to a
#'     lesser extent across persons.
#' }
#'
#' @source
#' Li, Z., De Boeck, P., & Li, J. (2020). Does planning help for execution?
#' The complex relationship between planning and execution.
#' \emph{PLOS ONE}, 15(8), e0237568. \doi{10.1371/journal.pone.0237568}
#'
#' Original assessment developed in:
#'
#' Li, J., Zhang, B., Du, H., Zhu, Z., & Li, Y. M. (2015). Metacognitive
#' planning: Development and validation of an online measure.
#' \emph{Psychological Assessment}, 27(1), 260–271.
#' \doi{10.1037/a0038075}
#'
#' Data and original analysis code available at:
#' \url{https://osf.io/8pw3d/}
#'
#' @seealso
#' \code{\link{log_transform_times}} for applying the recommended log
#' transformation before analysis.
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#' library(ggplot2)
#'
#' # Descriptive statistics per task
#' planning_time |>
#'   group_by(task) |>
#'   summarize(mean_pt = mean(pt), sd_pt = sd(pt), n = n())
#'
#' # Log-transform and visualize distribution
#' planning_time |>
#'   mutate(log_pt = log(pt)) |>
#'   ggplot(aes(x = log_pt)) +
#'   geom_histogram(bins = 30, fill = "steelblue", colour = "white") +
#'   facet_wrap(~ task) +
#'   labs(title = "Log Planning Time by Task",
#'        x = "Log Planning Time (ms)", y = "Count")
#'
#' # Correlation between route length (step) and mean log planning time
#' planning_time |>
#'   mutate(log_pt = log(pt)) |>
#'   group_by(task) |>
#'   summarize(mean_log_pt = mean(log_pt), mean_step = mean(step)) |>
#'   summarize(r = cor(mean_step, mean_log_pt))
#'
#' # Filter to participants who completed all 10 tasks
#' complete_subjects <- planning_time |>
#'   group_by(subject) |>
#'   summarize(n_tasks = n()) |>
#'   filter(n_tasks == 10) |>
#'   pull(subject)
#'
#' planning_complete <- planning_time |>
#'   filter(subject %in% complete_subjects)
#' }
"planning_time"
