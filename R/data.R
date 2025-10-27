#' Time series for event detection
#' @description A list of time series for demonstrating event detection tasks.
#' \itemize{
#' \item nonstationarity: synthetic nonstationary time series.
#' \item global_temperature_yearly: yearly global temperature.
#' \item global_temperature_monthly: monthly global temperature.
#' \item multidimensional: multivariate series with a change point.
#' \item seattle_week: Seattle weekly temperature in 2019.
#' \item seattle_daily: Seattle daily temperature in 2019.
#' }
#'#'
#' @docType data
#' @usage data(examples_harbinger)
#' @format A list of time series.
#' @keywords datasets
#' @references \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @references Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series.
#'   1st ed. Cham: Springer Nature Switzerland, 2025. doi:10.1007/978-3-031-75941-3
#' @source \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @examples
#' data(examples_harbinger)
#' # Inspect a series (Seattle daily temperatures)
#' serie <- examples_harbinger$seattle_daily
#' head(serie)
"examples_harbinger"

#' Time series for anomaly detection
#' @description A list of time series designed for anomaly detection tasks.
#' \itemize{
#' \item simple: simple synthetic series with isolated anomalies.
#' \item contextual: contextual anomalies relative to local behavior.
#' \item trend: synthetic series with trend and anomalies.
#' \item multiple: multiple anomalies.
#' \item sequence: repeated anomalous sequences.
#' \item tt: train-test split synthetic series.
#' \item tt_warped: warped train-test synthetic series.
#' }
#'#'
#' @docType data
#' @usage data(examples_anomalies)
#' @format A list of time series for anomaly detection.
#' @keywords datasets
#' @references \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @references Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series.
#'   1st ed. Cham: Springer Nature Switzerland, 2025. doi:10.1007/978-3-031-75941-3
#' @source \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @examples
#' data(examples_anomalies)
#' # Select a simple anomaly series
#' serie <- examples_anomalies$simple
#' head(serie)
"examples_anomalies"

#' Time series for change point detection
#' @description A list of time series for change point experiments.
#' \itemize{
#' \item simple: simple synthetic series with one change point.
#' \item sinusoidal: sinusoidal pattern with a regime change.
#' \item incremental: gradual change in mean/variance.
#' \item abrupt: abrupt level shift.
#' \item volatility: variance change.
#' }
#'#'
#' @docType data
#' @usage data(examples_changepoints)
#' @format A list of time series for change point detection.
#' @keywords datasets
#' @references \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @references Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series.
#'   1st ed. Cham: Springer Nature Switzerland, 2025. doi:10.1007/978-3-031-75941-3
#' @source \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @examples
#' data(examples_changepoints)
#' # Select a simple change point series
#' serie <- examples_changepoints$simple
#' head(serie)
"examples_changepoints"

#' Time series for motif/discord discovery
#' @description A list of time series for motif (repeated patterns) and discord (rare patterns) discovery.
#' \itemize{
#' \item simple: simple synthetic series with motifs.
#' \item mitdb100: sample from MIT-BIH arrhythmia database (record 100).
#' \item mitdb102: sample from MIT-BIH arrhythmia database (record 102).
#' }
#'#'
#' @docType data
#' @usage data(examples_motifs)
#' @format A list of time series for motif discovery.
#' @keywords datasets
#' @references \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @references Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series.
#'   1st ed. Cham: Springer Nature Switzerland, 2025. doi:10.1007/978-3-031-75941-3
#' @source \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @examples
#' data(examples_motifs)
#' # Select a simple motif series
#' serie <- examples_motifs$simple
#' head(serie)
"examples_motifs"
