#' @title Anomaly detector using GARCH
#' @description
#' Fits a GARCH model to capture conditional heteroskedasticity and flags
#' observations with large standardized residuals as anomalies. Wraps `rugarch`.
#'
#' @details
#' A sGARCH(1,1) with ARMA(1,1) mean is estimated. Standardized residuals are
#' summarized and thresholded via `harutils()`.
#'
#' @return `hanr_garch` object.
#'
#' @examples
#' library(daltoolbox)
#'
#' # Load anomaly example data
#' data(examples_anomalies)
#'
#' # Use a simple example
#' dataset <- examples_anomalies$simple
#' head(dataset)
#'
#' # Configure GARCH anomaly detector
#' model <- hanr_garch()
#'
#' # Fit the model
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected anomalies
#' print(detection[(detection$event),])
#'
#' @references
#' - Engle RF (1982). Autoregressive Conditional Heteroscedasticity with Estimates of
#'   the Variance of United Kingdom Inflation. Econometrica, 50(4):987–1007.
#' - Bollerslev T (1986). Generalized Autoregressive Conditional Heteroskedasticity.
#'   Journal of Econometrics, 31(3):307–327.
#'
#' @export
hanr_garch <- function() {
  obj <- harbinger()

  hutils <- harutils()

  class(obj) <- append("hanr_garch", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom rugarch ugarchspec
#'@importFrom rugarch ugarchfit
#'@exportS3Method detect hanr_garch
detect.hanr_garch <- function(obj, serie, ...) {
  obj <- obj$har_store_refs(obj, serie)

  spec <- rugarch::ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
                              mean.model = list(armaOrder = c(1, 1), include.mean = TRUE),
                              distribution.model = "norm")

  #Adjusting a model to the entire series
  model <- rugarch::ugarchfit(spec=spec, data=obj$serie, solver="hybrid")@fit

  #Adjustment error on the entire series
  res <- residuals(model, standardize = TRUE)

  res <- obj$har_distance(res)
  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}

