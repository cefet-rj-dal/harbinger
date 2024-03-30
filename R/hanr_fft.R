#'@title Anomaly detector using FFT
#'@description Anomaly detection using FFT
#'The FFT model adjusts to the time series. Observations distant from the model are labeled as anomalies.
#'It wraps the FFT model presented in the stats library.
#'@return `hanr_fft` object
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
#'# setting up time series fft detector
#'model <- hanr_fft()
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
hanr_fft <- function() {
  obj <- harbinger()
  obj$sw_size <- NULL

  class(obj) <- append("hanr_fft", class(obj))
  return(obj)
}

#'@importFrom stats fft
#'@importFrom stats sd
#'@export
detect.hanr_fft <- function(obj, serie, ...) {
  compute_cut_index <- function(freqs) {
    cutindex <- which.max(freqs)
    if (min(freqs) != max(freqs)) {
      threshold <- mean(freqs) + 2.968*sd(freqs)
      freqs[freqs < threshold] <- min(freqs) + max(freqs)
      cutindex <- which.min(freqs)
    }
    return(cutindex)
  }

  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  fft_signal <- stats::fft(obj$serie)

  spectrum <- base::Mod(fft_signal)^2
  half_spectrum <- spectrum[1:(length(obj$serie)/2 + 1)]

  cutindex <- compute_cut_index(half_spectrum)
  n <- length(fft_signal)

  fft_signal[1:cutindex] <- 0
  fft_signal[(n - cutindex):n] <- 0

  filtered_series <- base::Re(stats::fft(fft_signal, inverse = TRUE) / n)

  anomalies <- obj$har_outliers_idx(filtered_series)
  anomalies <- obj$har_outliers_group(anomalies, length(filtered_series))

  detection <- obj$har_restore_refs(obj, anomalies = anomalies)

  return(detection)
}
