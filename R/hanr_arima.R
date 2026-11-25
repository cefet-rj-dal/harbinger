#' @title Anomaly detector using ARIMA (ARIMA++)
#' @description
#' Fits an ARIMA model to the series and flags observations with large model
#' residuals as anomalies.
#'
#' @details
#' This is the backport of the Python `pyharbinger::HanrArima` releitura. Instead
#' of `forecast::auto.arima`, the ARIMA order is selected by the DAL ARIMA
#' auto-selector [tspredit::fit_arima()] -- the native (base `stats::arima`)
#' replacement for `auto.arima` -- so `harbinger` no longer depends on the
#' `forecast` package. `auto = "aicc"` (default) is a compact AICc search; the
#' detector flags points whose in-sample ARIMA residual is unusually large.
#'
#' The first `sw_size = max(p, d + 1, q)` residuals are a warm-up window: they are
#' neutralised **before** the outlier statistics (not only masked afterwards), so a
#' large initialisation transient cannot inflate the threshold and hide the real
#' anomalies. Residual magnitudes are summarised via a distance function and
#' thresholded with the outlier heuristics from `harutils()`.
#'
#' @param auto Order selector forwarded to [tspredit::fit_arima()]: `"aicc"`
#'   (default, compact AICc search) or `"cv"` (the heavier ARIMA++ rolling-origin
#'   cross-validated selector, tuned for forecasting).
#' @param max_order Cap for the ACF/PACF-driven candidate lags (ARIMA++ `"cv"`).
#' @param cv_folds Number of rolling origins for the CV selection (ARIMA++ `"cv"`).
#' @param horizon CV horizon (ARIMA++ `"cv"`); `NULL` -> the detected seasonal period.
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
#' - Hyndman RJ, Khandakar Y (2008). Automatic time series forecasting: the forecast
#'   package for R. Journal of Statistical Software, 27(3). doi:10.18637/jss.v027.i03
#'
#' @export
hanr_arima <- function(auto = "aicc", max_order = 12, cv_folds = 2, horizon = NULL) {
  obj <- harbinger()
  obj$auto <- auto
  obj$max_order <- max_order
  obj$cv_folds <- cv_folds
  obj$horizon <- horizon
  obj$sw_size <- NULL

  class(obj) <- append("hanr_arima", class(obj))
  return(obj)
}


#'@importFrom tspredit fit_arima
#'@importFrom stats na.omit
#'@exportS3Method fit hanr_arima
fit.hanr_arima <- function(obj, serie, ...) {
  # Validate input
  if (is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Omit missing values and select the ARIMA order with the DAL auto-selector.
  serie <- stats::na.omit(serie)
  sel <- tspredit::fit_arima(
    as.numeric(serie),
    auto = obj$auto,
    max_order = obj$max_order,
    cv_folds = obj$cv_folds,
    horizon = obj$horizon
  )

  obj$p <- sel$order[1]
  obj$d <- sel$order[2]
  obj$q <- sel$order[3]
  obj$include_mean <- isTRUE(sel$include_mean)
  obj$model <- sel$model
  attr(obj, "params") <- list(p = obj$p, d = obj$d, q = obj$q)

  if (is.null(obj$sw_size))
    obj$sw_size <- max(obj$p, obj$d + 1, obj$q)

  return(obj)
}


#'@importFrom stats residuals
#'@exportS3Method detect hanr_arima
detect.hanr_arima <- function(obj, serie, ...) {
  # Validate input
  if (is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  # Select the order and fit the model on the entire (stored) series.
  obj <- fit(obj, obj$serie)

  res <- as.numeric(stats::residuals(obj$model))
  n <- length(obj$serie)
  if (length(res) != n) {
    pad <- max(n - length(res), 0)
    res <- c(rep(0, pad), res)[seq_len(n)]
  }

  # Neutralise the warm-up window *before* the outlier statistics so an
  # initialisation transient cannot dominate the threshold (matches the Python
  # releitura pyharbinger::HanrArima).
  warm <- min(obj$sw_size, n)
  if (warm >= 1) res[seq_len(warm)] <- 0

  # Distance and outlier detection on residuals
  res <- obj$har_distance(res)
  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res, obj$serie)

  # Ignore the warm-up window in the detections as well
  if (warm >= 1) anomalies[seq_len(warm)] <- FALSE

  # Restore detections to original indexing
  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}
