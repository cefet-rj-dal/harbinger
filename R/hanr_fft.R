#' @title Anomaly detector using FFT
#' @description
#' High-pass filtering via FFT to isolate high-frequency components; anomalies
#' are flagged where the filtered magnitude departs strongly from baseline.
#'
#' @details
#' The spectrum is computed by FFT, a cutoff is selected from the power spectrum,
#' low frequencies are nulled, and the inverse FFT reconstructs a high-pass
#' signal. Magnitudes are summarized and thresholded using `harutils()`.
#'
#' @return `hanr_fft` object
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
#' # Configure FFT-based anomaly detector
#' model <- hanr_fft()
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
#' - Sobrinho, E. P., Souza, J., Lima, J., Giusti, L., Bezerra, E., Coutinho, R., Baroni, L.,
#'   Pacitti, E., Porto, F., Belloze, K., Ogasawara, E. Fine-Tuning Detection Criteria for
#'   Enhancing Anomaly Detection in Time Series. In: Simpósio Brasileiro de Banco de Dados
#'   (SBBD). SBC, 29 Sep. 2025. doi:10.5753/sbbd.2025.247063
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
#'@exportS3Method detect hanr_fft
detect.hanr_fft <- function(obj, serie, ...) {
  if (is.null(serie))
    stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  fft_signal <- stats::fft(obj$serie)

  spectrum <- base::Mod(fft_signal) ^ 2
  half_spectrum <- spectrum[1:(length(obj$serie) / 2 + 1)]

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
