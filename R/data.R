#' Time series for event detection
#' @description A list of time series for event detection
#' \itemize{
#' \item nonstationarity: a synthetic nonstationarity time series
#' \item global_temperature_yearly: yearly global temperature of the world
#' \item global_temperature_monthly: monthly global temperature of the world
#' \item multidimensional: multidimensional time series with a change point
#' \item seattle_week: Seattle weakly temperature in 2019
#' \item seattle_daily: Seattle daily temperature in 2019
#' }
#'#'
#' @docType data
#' @usage data(examples_harbinger)
#' @format A list of time series.
#' @keywords datasets
#' @references \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @source \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @examples
#' data(examples_harbinger)
#' serie <- examples_harbinger$seattle_daily
"examples_harbinger"

#' Time series for anomaly detection
#' @description A list of time series for anomaly detection
#' \itemize{
#' \item simple: a simple synthetic time series
#' \item contextual: a contextual synthetic time series
#' \item simple: a trend synthetic time series
#' \item trend: a simple synthetic time series
#' \item multiple: a multiple anomalies synthetic time series
#' \item sequence: a sequence synthetic time series
#' \item tt: a train-test synthetic time series
#' \item tt_warped: a warped train-test synthetic time series
#' }
#'#'
#' @docType data
#' @usage data(examples_anomalies)
#' @format A list of time series for anomaly detection.
#' @keywords datasets
#' @references \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @source \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @examples
#' data(examples_anomalies)
#' serie <- examples_anomalies$simple
"examples_anomalies"

#' Time series for change point detection
#' @description A list of time series for change point
#' \itemize{
#' \item simple: a simple synthetic time series
#' \item sinusoidal: a sinusoidal synthetic time series
#' \item incremental: a incremental synthetic time series
#' \item abrupt: a abrupt synthetic time series
#' \item volatility: a volatility synthetic time series
#' }
#'#'
#' @docType data
#' @usage data(examples_changepoints)
#' @format A list of time series for change point detection.
#' @keywords datasets
#' @references \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @source \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @examples
#' data(examples_changepoints)
#' serie <- examples_changepoints$simple
"examples_changepoints"
