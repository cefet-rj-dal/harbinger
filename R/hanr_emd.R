#'@title Anomaly detector using EMD
#'@description Anomaly detection using EMD
#'The EMD model adjusts to the time series. Observations distant from the model are labeled as anomalies.
#'It wraps the EMD model presented in the forecast library.
#'@param noise nosie
#'@param w window size
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
hanr_emd <- function(noise = 0.1, w = 30, trials = 5) {
  obj <- harbinger()
  obj$noise <- noise
  obj$w <- w
  obj$trials <- trials

  obj$sw_size <- NULL

  class(obj) <- append("hanr_emd", class(obj))
  return(obj)
}

#'@importFrom hht CEEMD
#'@export
fit.hanr_emd <- function(obj, serie,  ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  serie <- stats::na.omit(serie)

  serie <- stats::ts(serie)

  id <- 1:length(serie)
  obj$sw_size <-  length(serie)
  ceemd.result <- hht::CEEMD(serie, id, obj$noise, obj$trials)

  obj$model <- ceemd.result

  return(obj)
}


#'@export
#'@importFrom stats median
#'@importFrom stats sd
detect.hanr_emd <- function(obj, serie, ...) {

  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  sum_high_freq <- obj$model[["imf"]][,1]

  ## identification of anomaly points
  diff_high_freq <- c(NA, diff(sum_high_freq))
  median_high_freq <- stats::median(abs(diff_high_freq), na.rm= TRUE)
  distance <- abs(diff_high_freq) -  median_high_freq

  outliers_dist <- which(abs(distance) > 2.698*stats::sd(distance, na.rm=TRUE))

  obj$anomalies[1:obj$sw_size] <- FALSE
  if (!is.null(outliers_dist) & length(outliers_dist) > 0) {
    obj$anomalies[outliers_dist] <- TRUE
  }

  detection <- obj$har_restore_refs(obj, anomalies = obj$anomalies)
  return(detection)

}



