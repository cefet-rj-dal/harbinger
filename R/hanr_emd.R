#'@title Anomaly detector using EMD
#'@description Anomaly detection using EMD
#'The EMD model adjusts to the time series. Observations distant from the model are labeled as anomalies.
#'It wraps the EMD model presented in the hht library.
#'@param noise nosie
#'@param trials trials
#'@return `hanr_emd` object
#'
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(har_examples)
#'
#'#Using example 1
#'dataset <- har_examples$example1
#'head(dataset)
#'
#'# setting up time series emd detector
#'model <- hanr_emd()
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
hanr_emd <- function(noise = 0.1, trials = 5) {
  obj <- harbinger()
  obj$noise <- noise
  obj$trials <- trials

  obj$sw_size <- NULL

  class(obj) <- append("hanr_emd", class(obj))
  return(obj)
}

#'@importFrom stats median
#'@importFrom stats sd
#'@importFrom hht CEEMD
#'@export
detect.hanr_emd <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  id <- 1:length(obj$serie)
  obj$sw_size <-  length(obj$serie)
  ceemd.result <- hht::CEEMD(obj$serie, id, obj$noise, obj$trials)

  obj$model <- ceemd.result


  sum_high_freq <- obj$model[["imf"]][,1]

  anomalies <- obj$har_outliers_idx(sum_high_freq)
  anomalies <- obj$har_outliers_group(anomalies, length(sum_high_freq))

  detection <- obj$har_restore_refs(obj, anomalies = anomalies)

  return(detection)
}



