#'@title Anomaly Detector using FFT with AMOC and CUSUM Cutoff
#'@description
#'This function implements an anomaly detection method based on the Fast Fourier Transform (FFT)
#'and a changepoint-based cutoff strategy using the AMOC (At Most One Change) algorithm applied
#'to the cumulative sum (CUSUM) of the power spectrum.
#'
#'The method first computes the FFT of the input time series and extracts the power spectrum.
#'It then applies a CUSUM transformation to the spectral data to emphasize gradual changes or
#'shifts in spectral energy. Using the AMOC algorithm, it detects a single changepoint in the
#'CUSUM-transformed spectrum, which serves as a cutoff index to remove the lower-frequency components.
#'
#'The remaining high-frequency components are then reconstructed into a time-domain signal
#'via inverse FFT, effectively isolating rapid or local deviations. Anomalies are detected
#'by evaluating the distance between this filtered signal and the original series,
#'highlighting points that deviate significantly from the expected pattern.
#'
#'This method is suitable for series where spectral shifts are subtle and a single significant
#'change in behavior is expected.
#'
#'This function extends the HARBINGER framework and returns an object of class `hanr_fft_amoc_cusum`.
#'
#'@return `hanr_fft_amoc_cusum` object
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
#'model <- hanr_fft_amoc_cusum()
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
hanr_fft_amoc_cusum <- function() {
  obj <- harbinger()
  obj$sw_size <- NULL

  class(obj) <- append("hanr_fft_amoc_cusum", class(obj))
  return(obj)
}

#'@importFrom stats fft
#'@importFrom stats sd
#'@importFrom changepoint cpt.mean
#'@importFrom changepoint cpts
#'@exportS3Method detect hanr_fft_amoc_cusum
detect.hanr_fft_amoc_cusum <- function(obj, serie, ...) {
  compute_cut_index <- function(freqs) {
    cusum_valores <- base::cumsum(freqs)
    resultado_cpt <- changepoint::cpt.mean(cusum_valores, method="AMOC")
    i <- length(changepoint::cpts(resultado_cpt))
    cutindex <- changepoint::cpts(resultado_cpt)[i]

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

  res <- obj$har_distance(filtered_series)

  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}
