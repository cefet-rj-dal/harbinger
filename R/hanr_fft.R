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
#'data(examples_anomalies)
#'
#'#Using simple example
#'dataset <- examples_anomalies$simple
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

  class(obj) <- append("hanr_fft", class(obj))
  return(obj)
}

compute_cut_index <- function(freqs) {
  cutindex <- which.max(freqs)
  if (min(freqs) != max(freqs)) {
    threshold <- mean(freqs) + 2.698 * sd(freqs)
    freqs[freqs < threshold] <- min(freqs) + max(freqs)
    cutindex <- which.min(freqs)
  }
  return(cutindex)
}

#'@importFrom stats fft
#'@importFrom stats sd
#'@export
detect.hanr_fft <- function(obj, serie, ...) {
  if (is.null(serie))
    stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  fft_signal <- stats::fft(obj$serie)

  spectrum <- base::Mod(fft_signal) ^ 2
  half_spectrum <- spectrum[1:(length(obj$serie) / 2 + 1)]

  cutindex <- compute_cut_index(half_spectrum)
  n <- length(fft_signal)

  fft_signal[1:cutindex] <- 0
  fft_signal[(n - cutindex):n] <- 0

  filtered_series <-
    base::Re(stats::fft(fft_signal, inverse = TRUE) / n)

  noise <- filtered_series # obj$har_residuals(filtered_series)

  anomalies <- obj$har_outliers_idx(noise)
  anomalies <- obj$har_outliers_group(anomalies, length(noise))

  detection <- obj$har_restore_refs(obj, anomalies = anomalies)

  return(detection)
}
