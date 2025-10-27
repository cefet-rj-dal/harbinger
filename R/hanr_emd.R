#' @title Anomaly detector using EMD
#' @description
#' Empirical Mode Decomposition (CEEMD) to extract intrinsic mode functions and
#' flag anomalies from high-frequency components. Wraps `hht::CEEMD`.
#'
#' @param noise Numeric. Noise amplitude for CEEMD.
#' @param trials Integer. Number of CEEMD trials.
#' @return `hanr_emd` object
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
#' # Configure EMD-based anomaly detector
#' model <- hanr_emd()
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
#' - Huang NE, et al. (1998). The empirical mode decomposition and the Hilbert spectrum
#'   for nonlinear and non-stationary time series analysis. Proc. Royal Society A.
#'
#'@export
hanr_emd <- function(noise = 0.1, trials = 5) {
  obj <- harbinger()
  obj$noise <- noise
  obj$trials <- trials

  hutils <- harutils()
  obj$har_outliers_check <- hutils$har_outliers_checks_highgroup

  class(obj) <- append("hanr_emd", class(obj))
  return(obj)
}

#'@importFrom stats median
#'@importFrom stats sd
#'@importFrom hht CEEMD
#'@exportS3Method detect hanr_emd
detect.hanr_emd <- function(obj, serie, ...) {
  # Validate input
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  id <- 1:length(obj$serie)

  # CEEMD decomposition
  suppressWarnings(ceemd.result <- hht::CEEMD(obj$serie, id, verbose = FALSE, obj$noise, obj$trials))

  obj$model <- ceemd.result

  # Use the highest-frequency IMF as anomaly signal
  sum_high_freq <- obj$model[["imf"]][,1]

  # Distance and outlier detection on high-frequency component
  res <- obj$har_distance(sum_high_freq)
  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)

  # Restore detections to original indexing
  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}



