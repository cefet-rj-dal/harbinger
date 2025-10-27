#' @title Anomaly detector using Wavelets
#' @description
#' Multiresolution decomposition via wavelets; anomalies are flagged where
#' aggregated wavelet detail coefficients indicate unusual energy.
#'
#' @details
#' The series is decomposed with MODWT and detail bands are aggregated to
#' compute a magnitude signal that is thresholded using `harutils()`.
#'
#' @param filter Character. Available wavelet filters: `haar`, `d4`, `la8`, `bl14`, `c6`.
#' @return `hanr_wavelet` object
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
#' # Configure wavelet-based anomaly detector
#' model <- hanr_wavelet()
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
#' - Mallat S (1989). A theory for multiresolution signal decomposition: The wavelet
#'   representation. IEEE Transactions on Pattern Analysis and Machine Intelligence, 11(7):674–693.
#'
#' @export
hanr_wavelet <- function(filter = "haar") {
  obj <- harbinger()
  obj$filter <- filter

  class(obj) <- append("hanr_wavelet", class(obj))
  return(obj)
}

#'@importFrom stats residuals
#'@importFrom stats na.omit
#'@importFrom wavelets modwt
#'@exportS3Method detect hanr_wavelet
detect.hanr_wavelet <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  wt <- wavelets::modwt(obj$serie, filter=obj$filter, boundary="periodic")

  W <- as.data.frame(wt@W)

  w_component <- apply(W, 1, sum)

  res <- obj$har_distance(w_component)
  anomalies <- obj$har_outliers(res)

  anomalies <- obj$har_outliers_check(anomalies, res)

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)
  return(detection)
}

