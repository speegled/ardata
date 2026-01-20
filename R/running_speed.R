#' Running Speed and Negative Foot Velocity
#' 
#' Is the backward speed of a runner's foot at ground contact associated with running speed? Data was collected for 17 runners as they ran an 80 meter sprint.
#'
#' @format A data frame with 17 observations of 7 variables.
#' \describe{
#'   \item{ID}{consecutive integers from 1-17}
#'   \item{stride_length_m}{stride length in meters}
#'   \item{imu_top_speed_ms}{top speed over the 80 meters, in meters/second}
#'   \item{imu_avg_speed_ms}{average speed over the 80 meters}
#'   \item{vt_negative_foot_velocity_ms}{speed of the foot at ground strike in vertical component}
#'   \item{ap_negative_foot_velocity_ms}{speed of foot at ground strike in horizontal component}
#'   \item{magnitude_foot_velocity_ms}{total speed of foot strike}
#' }
#'
#' AI summary: Seventeen runners completed 80-meter sprints on an outdoor track while wearing a small sensor attached to their shoe that measured how fast their foot was moving at ground contact on every step. The researchers used these sensor data to analyze how different aspects of foot speed at touchdown were related to overall sprint speed and stride-by-stride running speed.
#'
#' From the authors: "Negative foot speed (i.e., the speed of the backward and downward motion of the foot relative to the body at ground contact) is a strong predictor of sprinting performance. Inertial measurement units (IMUs) are becoming a popular approach for assessing sports performance. The primary aim of this study was to use IMUs to investigate the relationship between negative foot speed and top running speed attained during a sprint on an outdoor track."
#'
#' @source https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0303920
"running_speed"