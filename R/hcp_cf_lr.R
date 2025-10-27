#' @title Change Finder using Linear Regression
#' @description
#' Change-point detection by modeling residual deviations with linear regression
#' and applying a second-stage smoothing and thresholding, inspired by
#' ChangeFinder <doi:10.1109/TKDE.2006.1599387>.
#'
#' @param sw_size Integer. Sliding window size for smoothing/statistics.
#' @return `hcp_cf_lr` object.
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
#' # Configure ChangeFinder-LR detector
#' model <- hcp_cf_lr()
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
hcp_cf_lr <- function(sw_size = 30) {
  obj <- harbinger()

  obj$sw_size <- sw_size
  class(obj) <- append("hcp_cf_lr", class(obj))
  return(obj)
}

#'@importFrom stats lm
#'@importFrom stats na.omit
#'@importFrom stats residuals
#'@exportS3Method detect hcp_cf_lr
detect.hcp_cf_lr <- function(obj, serie, ...) {
  linreg <- function(serie) {
    # Simple linear model y ~ t to capture trend
    data <- data.frame(t = 1:length(serie), x = serie)
    return(stats::lm(x~t, data))
  }

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  #Adjusting a model to the entire series
  model <- linreg(obj$serie)

  #Adjustment error on the entire series
  res <- stats::residuals(model)

  # Distance and outlier detection on residuals
  res <- obj$har_distance(res)
  anomalies <- obj$har_outliers(res)

  anomalies <- obj$har_outliers_check(anomalies, res)

  # Ignore initial warm-up window
  anomalies[1:obj$sw_size] <- FALSE

  y <- mas(res, obj$sw_size)

  #Adjusting to the entire series
  M2 <- linreg(y)

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

