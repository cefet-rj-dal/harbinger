#' @title Change Finder using ETS
#' @description
#' Change-point detection by modeling residual deviations with ETS and applying
#' a second-stage smoothing and thresholding, inspired by ChangeFinder
#' <doi:10.1109/TKDE.2006.1599387>. Wraps ETS from the `forecast` package.
#'
#' @param sw_size Integer. Sliding window size for smoothing/statistics.
#' @return `hcp_cf_ets` object.
#'
#' @examples
#' library(daltoolbox)
#'
#' # Load change-point example data
#' data(examples_changepoints)
#'
#' # Use a simple example
#' dataset <- examples_changepoints$simple
#' head(dataset)
#'
#' # Configure ChangeFinder-ETS detector
#' model <- hcp_cf_ets()
#'
#' # Fit the model
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected change points
#' print(detection[(detection$event),])
#'
#'@export
hcp_cf_ets <- function(sw_size = 7) {
  obj <- harbinger()

  obj$sw_size <- sw_size
  class(obj) <- append("hcp_cf_ets", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom stats ts
#'@importFrom stats residuals
#'@importFrom forecast ets
#'@exportS3Method detect hcp_cf_ets
detect.hcp_cf_ets <- function(obj, serie, ...) {
  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  # Adjust ETS to the entire series
  model <- forecast::ets(stats::ts(obj$serie))

  res <- stats::residuals(model)

  # Distance and outlier detection on residuals
  res <- obj$har_distance(res)
  anomalies <- obj$har_outliers(res)

  anomalies <- obj$har_outliers_check(anomalies, res)

  anomalies[1:obj$sw_size] <- FALSE

  y <- mas(res, obj$sw_size)

  # Adjust ETS to the smoothed residual signal
  M2 <- forecast::ets(ts(y))

  #Adjustment error on the whole window
  u <- obj$har_distance(stats::residuals(M2))

  u <- mas(u, obj$sw_size)
  cp <- obj$har_outliers(u)
  cp <- obj$har_outliers_check(cp, u)
  cp[1:obj$sw_size] <- FALSE
  cp <- c(rep(FALSE, length(res)-length(u)), cp)

  # Restore anomalies and change points to original indexing
  detection <- obj$har_restore_refs(obj, anomalies = anomalies, change_points = cp, res = res)

  return(detection)
}

