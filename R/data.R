#' Synthetic time series for event detection
#' @description A list of univariate time series for event detection
#' \itemize{
#' \item example1: a single (uncommon value) anomaly example in a stationary time series
#' \item example2: a single (common value) anomaly example in a stationary time series
#' \item example3: a single anomaly example in a trend time series
#' \item example4: a change point in a time series
#' \item example5: a change point with anomaly (uncommon value) in a time series
#' \item example6: a change point with anomaly (common value) in a time series
#' \item example7: a change point with anomaly (uncommon value) in a seasonal time series
#' \item example8: a change point with anomaly (common value) in a seasonal time series
#' \item example9: multi behavior time series (1-200: stationary, 201-400: trend, 401-600: structural break; 601-800: heteroscedasticity, 801:1000 random walk)
#' \item example10: multiple anomalies
#' \item example11: stationary time series
#' \item example12: trend time series
#' \item example13: structural break
#' \item example14: heterocedasticity
#' \item example15: motif
#' \item example16: discord
#' \item example17: repetitive anomaly
#' \item example18: repetitive anomaly
#' }
#'#'
#' @docType data
#' @usage data(har_examples)
#' @format A list of time series.
#' @keywords datasets
#' @references \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @source \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @examples
#' data(har_examples)
#' serie <- har_examples$example1
"har_examples"

#' Synthetic time series for event detection
#' @description A list of multivariate time series for event detection
#' \itemize{
#' \item example1: an single multivariate anomaly
#' }
#'#'
#' @docType data
#' @usage data(har_examples_multi)
#' @format A list of multivariate time series.
#' @keywords datasets
#' @references \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @source \href{https://github.com/cefet-rj-dal/harbinger}{Harbinger package}
#' @examples
#' data(har_examples_multi)
#' serie <- har_examples_multi$example1
"har_examples_multi"

