#' Accent Rating Data
#'
#' Data from a study investigating whether second-language English learners 
#' perceive their own accent as better than that of their peers. Twenty-four 
#' participants rated the accentedness of 60 English sentences on a scale from 
#' 1 (native-like) to 6 (heavily accented). Each participant rated sentences 
#' spoken by themselves and by other non-native speakers.
#'
#' @format A data frame with 5,760 rows and 15 variables:
#' \describe{
#'   \item{pair}{Factor identifying the listener-speaker pair (e.g., "1_1" means 
#'         listener 1 rating speaker 1)}
#'   \item{pp}{Integer participant identifier (1-24)}
#'   \item{group}{Factor indicating which group of four participants (A-E)}
#'   \item{sentence}{Integer identifying which of 60 sentences was spoken (1-60)}
#'   \item{spk_thisTrial}{Integer indicating which participant spoke on this trial (1-24)}
#'   \item{voice}{Factor with levels "self" and "other" indicating whether the rater 
#'         is listening to their own voice or someone else's}
#'   \item{wavfile}{Factor giving the audio filename}
#'   \item{trial}{Integer trial number (0-239)}
#'   \item{rating}{Integer accent rating from 1 (native-like) to 6 (heavily accented)}
#'   \item{rt}{Numeric reaction time in seconds}
#'   \item{participant}{Integer participant code (same as pp)}
#'   \item{voiceC}{Numeric contrast-coded predictor where -0.5 = self, 0.5 = other}
#'   \item{trialC}{Numeric centered trial number (mean of zero)}
#'   \item{recognition}{Numeric difference in self vs. other similarity ratings}
#'   \item{simRatingPair}{Numeric similarity rating of the speaker-listener pair}
#' }
#'
#' @details
#' This dataset is ideal for demonstrating random intercept models because:
#' \enumerate{
#'   \item Multiple ratings come from the same participant (participant effects)
#'   \item Multiple ratings are given for the same sentence (sentence effects)
#'   \item The research question asks whether people systematically rate their own
#'         accent as better while accounting for individual differences in rating
#'         tendencies and sentence difficulty
#' }
#' 
#' Key findings: Participants rated their own accent as significantly less 
#' accented (M = 2.09) than the accents of others (M = 2.59), t(21.6) = 5.30, 
#' p < .001.
#'
#' @source Mitterer, H. (2019). "My English Sounds Better Than Yours: 
#'   Second-language learners perceive their own accent as better than that 
#'   of their peers"
#'
#' @examples
#' \dontrun{
#' # Example 1: Simple random intercepts model
#' # Research question: Do people rate their own accent as less accented than 
#' # others' accents, accounting for baseline differences between raters and 
#' # sentences?
#' 
#' library(lmerTest)
#' 
#' # Basic model with random intercepts for participants and sentences
#' model1 <- lmer(rating ~ voiceC + (1|pp) + (1|sentence), data = accent)
#' summary(model1)
#' 
#' # Interpretation:
#' # - Fixed effect of voiceC tests whether ratings differ between self and other
#' # - Random intercept (1|pp) allows each participant to have their own baseline
#' #   rating tendency (some people might be systematically harsher raters)
#' # - Random intercept (1|sentence) allows each sentence to have its own baseline
#' #   difficulty (some sentences might be intrinsically harder to pronounce)
#' 
#' # Example 2: Model comparison to test the importance of random effects
#' # Is the participant random intercept necessary?
#' model_no_pp <- lmer(rating ~ voiceC + (1|sentence), data = accent)
#' anova(model1, model_no_pp)
#' 
#' # Is the sentence random intercept necessary?
#' model_no_sent <- lmer(rating ~ voiceC + (1|pp), data = accent)
#' anova(model1, model_no_sent)
#' 
#' # Example 3: Exploring the random effects
#' # Extract and examine random intercepts for participants
#' library(lattice)
#' dotplot(ranef(model1, condVar = TRUE))
#' 
#' # Which participants are the harshest raters?
#' pp_effects <- ranef(model1)$pp
#' pp_effects$participant <- rownames(pp_effects)
#' pp_effects[order(pp_effects$`(Intercept)`), ]
#' 
#' # Example 4: Visualization
#' library(ggplot2)
#' 
#' # Plot showing self vs other ratings for each participant
#' ggplot(accent, aes(x = voice, y = rating, group = pp)) +
#'   stat_summary(fun = mean, geom = "line", alpha = 0.3) +
#'   stat_summary(aes(group = 1), fun = mean, geom = "line", 
#'                color = "red", size = 1.5) +
#'   stat_summary(aes(group = 1), fun.data = mean_se, geom = "errorbar", 
#'                width = 0.2, color = "red") +
#'   labs(x = "Voice Type", 
#'        y = "Accent Rating (1=native-like, 6=heavily accented)",
#'        title = "Self vs. Other Accent Ratings",
#'        subtitle = "Gray lines = individual participants, Red = group mean") +
#'   theme_minimal()
#' }
"accent"
