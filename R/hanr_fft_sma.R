#'@title Anomaly Detector using Adaptive FFT and Moving Average
#'@description
#'This function implements an anomaly detection model based on the Fast Fourier daltoolbox::transform (FFT),
#'combined with an adaptive moving average filter. The method estimates the dominant frequency
#'in the input time series using spectral analysis and then applies a moving average filter
#'with a window size derived from that frequency. This highlights high-frequency deviations,
#'which are likely to be anomalies.
#'
#'The residuals (original signal minus smoothed version) are then processed to compute the
#'distance from the expected behavior, and points significantly distant are flagged as anomalies.
#'The detection also includes a grouping strategy to reduce false positives by selecting
#'the most representative point in a cluster of consecutive anomalies.
#'
#'This function extends the HARBINGER framework and returns an object of class `hanr_fft_sma`.
#'@return `hanr_fft_sma` object
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
#'model <- hanr_fft_sma()
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
hanr_fft_sma <- function() {
  obj <- harbinger()
  obj$sw_size <- NULL

  class(obj) <- append("hanr_fft_sma", class(obj))
  return(obj)
}

#'@importFrom tspredit ts_data
#'@importFrom stats fft
#'@importFrom stats sd
#'@importFrom stats spec.pgram
#'@exportS3Method detect hanr_fft_sma
detect.hanr_fft_sma <- function(obj, serie, ...) {

  # Function to determine the best moving average window based on the FFT
  find_best_moving_average <- function(series) {
    periodogram <- stats::spec.pgram(series, plot = FALSE)

    # Determine the dominant frequency
    dominant_freq <- periodogram$freq[base::which.max(periodogram$spec)]

    # Convert frequency to the approximate period of the series
    best_window <- round(1 / dominant_freq)

    # Ensure that the moving average window is not larger than the length of the series
    best_window <- min(max(3, best_window), length(series) - 1)

    return(best_window)
  }

  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  # Dynamically apply the best moving average
  optimal_window <- find_best_moving_average(serie)

  sx <- tspredit::ts_data(serie, optimal_window)
  ts_sma <- apply(sx, 1, mean)

  filtered_series <- serie - ts_sma

  res <- obj$har_distance(filtered_series)

  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}

