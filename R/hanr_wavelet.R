#'@title Anomaly detector using Wavelet
#'@description Anomaly detection using Wavelet
#'The Wavelet model adjusts to the time series. Observations distant from the model are labeled as anomalies.
#'It wraps the Wavelet model presented in the stats library.
#'@param filter Availables wavelet filters: haar, d4, la8, bl14, c6
#'@return `hanr_wavelet` object
#'
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(examples_anomalies)
#'
#'#Using simple example
#'dataset <- examples_anomalies$simple
#'head(dataset)
#'
#'# setting up time series fft detector
#'model <- hanr_wavelet()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
# making detection
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'
#'@export
hanr_wavelet <- function(filter = "haar") {
  obj <- harbinger()
  obj$filter <- filter

  class(obj) <- append("hanr_wavelet", class(obj))
  return(obj)
}

#'@importFrom stats residuals
#'@importFrom stats na.omit
#'@importFrom wavelets modwt
#'@export
detect.hanr_wavelet <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  wt <- wavelets::modwt(obj$serie, filter=obj$filter, boundary="periodic")

  W <- as.data.frame(wt@W)

  w_component <- apply(W, 1, sum)

  noise <- obj$har_residuals(w_component)

  anomalies <- obj$har_outliers_idx(noise)
  anomalies <- obj$har_outliers_group(anomalies, length(noise))

  detection <- obj$har_restore_refs(obj, anomalies = anomalies)
  return(detection)
}

