#' @title Anomaly detector using ARIMA
#' @description
#' Fits an ARIMA model to the series and flags observations with large
#' model residuals as anomalies. Wraps ARIMA from the `forecast` package.
#'
#' @details
#' The detector estimates ARIMA(p,d,q) and computes standardized residuals.
#' Residual magnitudes are summarized via a distance function and thresholded
#' with outlier heuristics from `harutils()`.
#'
#' @return `hanr_arima` object.
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
#' # Configure ARIMA anomaly detector
#' model <- hanr_arima()
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
#' - Box GEP, Jenkins GM, Reinsel GC, Ljung GM (2015). Time Series Analysis: Forecasting
#'   and Control. Wiley.
#'
#' @export
hanr_arima <- function() {
  obj <- harbinger()
  obj$sw_size <- NULL

  class(obj) <- append("hanr_arima", class(obj))
  return(obj)
}


#'@importFrom forecast auto.arima
#'@importFrom stats residuals
#'@importFrom stats na.omit
#'@exportS3Method fit hanr_arima
fit.hanr_arima <- function(obj, serie, ...) {
  # Validate input
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  # Omit missing values, select ARIMA order and cache parameters
  serie <- stats::na.omit(serie)

  obj$model <- forecast::auto.arima(serie, allowdrift = TRUE, allowmean = TRUE)
  order <- obj$model$arma[c(1, 6, 2, 3, 7, 4, 5)]
  obj$p <- order[1]
  obj$d <- order[2]
  obj$q <- order[3]
  obj$drift <- (NCOL(obj$model$xreg) == 1) && is.element("drift", names(obj$model$coef))
  params <- list(p = obj$p, d = obj$d, q = obj$q, drift = obj$drift)
  attr(obj, "params") <- params

  if (is.null(obj$sw_size))
    obj$sw_size <- max(obj$p, obj$d+1, obj$q)

  return(obj)
}


#'@importFrom forecast auto.arima
#'@importFrom stats residuals
#'@importFrom stats na.omit
#'@exportS3Method detect hanr_arima
detect.hanr_arima <- function(obj, serie, ...) {
  # Validate input
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  #Adjusting a model to the entire series
  model <- tryCatch(
    {
      forecast::Arima(obj$serie, order=c(obj$p, obj$d, obj$q), include.drift = obj$drift)
    },
    error = function(cond) {
      forecast::auto.arima(obj$serie, allowdrift = TRUE, allowmean = TRUE)
    }
  )

  res <- stats::residuals(model)

  # Distance and outlier detection on residuals
  res <- obj$har_distance(res)
  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)

  # Ignore initial warm-up window
  anomalies[1:obj$sw_size] <- FALSE

  # Restore detections to original indexing
  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}
