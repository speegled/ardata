#' AI-text detection exam data
#'
#' A student-facing version of the AI-text detection data used for the applied
#' regression final exam. The dataset is based on the paper by Milicka and
#' coauthors on whether people can learn to distinguish human-written text from
#' AI-generated text. The data are organized at the participant-trial level.
#'
#' The main outcome is `correct`, a binary indicator for whether the participant
#' correctly identified the human-written and AI-generated texts. The main
#' experimental condition is `feedback_condition`, and `trial_sequence` indexes
#' progress through the non-control trials. Each participant contributes repeated
#' observations, identified by `participant_id`.
#'
#' @format A data frame with 4,318 rows and 25 variables:
#' \describe{
#'   \item{participant_id}{Participant identifier; each participant contributes 17 non-control trials.}
#'   \item{feedback_condition}{Experimental condition: `feedback` for immediate feedback after each trial or `no_feedback` for no immediate feedback until the end.}
#'   \item{got_feedback}{Logical version of `feedback_condition`.}
#'   \item{trial_order}{Original trial order number from the experiment after control questions have been removed; values may skip numbers because control questions were removed.}
#'   \item{trial_sequence}{Simplified sequential trial number from 1 to 17 within participant after control questions have been removed.}
#'   \item{correct}{Binary outcome: 1 if the participant correctly identified which text was human-written and which was AI-generated; 0 otherwise.}
#'   \item{confidence}{Participant confidence rating on a 1 to 7 scale.}
#'   \item{more_readable_is_human}{Indicator equal to 1 if the participant judged the human-written text to be more readable; 0 otherwise.}
#'   \item{reaction_time_ms}{Trial reaction time in milliseconds.}
#'   \item{reaction_time_log2}{Base-2 logarithm of trial reaction time in milliseconds.}
#'   \item{correctness_total}{Total number of correct responses for the participant across 17 non-control trials.}
#'   \item{age}{Participant age.}
#'   \item{gender}{Participant gender response, simplified as reported in the Jamovi data.}
#'   \item{education_ordinal}{Ordinal coding of education level used by the authors.}
#'   \item{ai_usage_ordinal}{Ordinal coding of frequency of AI or LLM use used by the authors.}
#'   \item{reading_disorder}{Whether the participant reported a reading disorder, after the authors merged unknown with false.}
#'   \item{stylometric_distance}{Euclidean distance between the human and AI text pair on the authors' stylometric dimensions.}
#'   \item{dim1_difference}{Difference between AI and human text on stylometric dimension 1, computed as AI minus human in the authors' data.}
#'   \item{dim2_difference}{Difference between AI and human text on stylometric dimension 2, computed as AI minus human in the authors' data.}
#'   \item{dim3_difference}{Difference between AI and human text on stylometric dimension 3, computed as AI minus human in the authors' data.}
#'   \item{dim4_difference}{Difference between AI and human text on stylometric dimension 4, computed as AI minus human in the authors' data.}
#'   \item{dim5_difference}{Difference between AI and human text on stylometric dimension 5, computed as AI minus human in the authors' data.}
#'   \item{dim6_difference}{Difference between AI and human text on stylometric dimension 6, computed as AI minus human in the authors' data.}
#'   \item{dim7_difference}{Difference between AI and human text on stylometric dimension 7, computed as AI minus human in the authors' data.}
#'   \item{dim8_difference}{Difference between AI and human text on stylometric dimension 8, computed as AI minus human in the authors' data.}
#' }
#'
#' @source Student-facing CSV prepared from the authors' OSF/Jamovi materials for
#' Milicka and coauthors, "Learning to detect AI texts and learning the limits."
#'
#' @references Milicka and coauthors. "Learning to detect AI texts and learning
#' the limits." PLOS ONE. \doi{10.1371/journal.pone.0333007}
#'
#' @keywords datasets
"ai_detection"