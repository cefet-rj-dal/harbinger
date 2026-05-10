#'@title Anomaly Detector using FFT with BinSeg and CUSUM Cutoff
#'@description
#'This detector combines FFT-based spectral filtering with a Binary Segmentation
#'change-point cutoff applied to the cumulative spectrum. The lower-frequency
#'components are removed, the signal is reconstructed, and the residual is scored
#'for anomalies.
#'
#'This function extends the HARBINGER framework and returns an object of class `hanr_fft_binseg_cusum`.
#'
#'
#'@return `hanr_fft_binseg_cusum` object
#'
#'@examples
#'library(daltoolbox)
#'
#' # Load anomaly example data
#' data(examples_anomalies)
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
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'
#' @references
#' - Sobrinho, E. P., Souza, J., Lima, J., Giusti, L., Bezerra, E., Coutinho, R., Baroni, L.,
#'   Pacitti, E., Porto, F., Belloze, K., Ogasawara, E. Fine-Tuning Detection Criteria for
#'   Enhancing Anomaly Detection in Time Series. In: Simpósio Brasileiro de Banco de Dados
#'   (SBBD). SBC, 29 Sep. 2025. doi:10.5753/sbbd.2025.247063
#'
#'@export
hanr_fft_binseg_cusum <- function() {
  obj <- harbinger()
  obj$sw_size <- NULL

  hutils <- harutils()
  obj$har_outliers_check <- hutils$har_candidate_selection_highgroup

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

  # Validate input
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  fft_signal <- stats::fft(obj$serie)

  spectrum <- base::Mod(fft_signal)^2
  half_spectrum <- spectrum[1:(length(obj$serie)/2 + 1)]

  cutindex <- compute_cut_index(half_spectrum)
  n <- length(fft_signal)

  # Zero out low frequencies (high-pass)
  fft_signal[1:cutindex] <- 0
  fft_signal[(n - cutindex):n] <- 0

  filtered_series <- base::Re(stats::fft(fft_signal, inverse = TRUE) / n)

  # Distance and outlier detection on filtered magnitude
  res <- obj$har_distance(filtered_series)

  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)

  # Restore detections to original indexing
  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}
