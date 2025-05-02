#'@title Anomaly Detector using FFT with BinSeg and CUSUM Cutoff
#'@description
#'This function implements an anomaly detection method that combines the Fast Fourier Transform (FFT)
#'with a changepoint-based cutoff strategy using the Binary Segmentation (BinSeg) method applied
#'to the cumulative sum (CUSUM) of the frequency spectrum.
#'
#'The method first computes the FFT of the input time series and obtains its power spectrum.
#'Then, it applies a CUSUM transformation to the spectral density to enhance detection of gradual
#'transitions or accumulated changes in energy across frequencies. The Binary Segmentation method
#'is applied to the CUSUM-transformed spectrum to identify a changepoint that defines a cutoff
#'frequency.
#'
#'Frequencies below this cutoff are removed from the spectrum, and the signal is reconstructed
#'using the inverse FFT. This produces a filtered signal that retains only the high-frequency
#'components, emphasizing potential anomalies.
#'
#'Anomalies are then detected by measuring the deviation of the filtered signal from the original one,
#'and applying an outlier detection mechanism based on this residual.
#'
#'This function extends the HARBINGER framework and returns an object of class `hanr_fft_binseg_cusum`.
#'
#'
#'@return `hanr_fft_binseg_cusum` object
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
#'model <- hanr_fft_binseg_cusum()
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
hanr_fft_binseg_cusum <- function() {
  obj <- harbinger()
  obj$sw_size <- NULL

  hutils <- harutils()
  obj$har_outliers_check <- hutils$har_outliers_checks_highgroup

  class(obj) <- append("hanr_fft_binseg_cusum", class(obj))
  return(obj)
}

#'@importFrom stats fft
#'@importFrom stats sd
#'@importFrom changepoint cpt.mean
#'@importFrom changepoint cpts
#'@exportS3Method detect hanr_fft_binseg_cusum
detect.hanr_fft_binseg_cusum <- function(obj, serie, ...) {
  compute_cut_index <- function(freqs) {
    cusum_valores <- cumsum(freqs)
    resultado_cpt <- changepoint::cpt.mean(cusum_valores, method="BinSeg")
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
