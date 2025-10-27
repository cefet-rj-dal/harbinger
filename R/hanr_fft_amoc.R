#'@title Anomaly Detector using FFT with AMOC Cutoff
#'@description
#'This function implements an anomaly detection method that uses the Fast Fourier daltoolbox::transform (FFT)
#'combined with an automatic frequency cutoff strategy based on the AMOC (At Most One Change)
#'algorithm. The model analyzes the power spectrum of the time series and detects the optimal
#'cutoff frequency — the point where the frequency content significantly changes — using
#'a changepoint detection method from the `changepoint` package.
#'
#'All frequencies below the cutoff are removed from the spectrum, and the inverse FFT reconstructs
#'a filtered version of the original signal that preserves only high-frequency components.
#'The resulting residual signal is then analyzed to identify anomalous patterns based on
#'its distance from the expected behavior.
#'
#'This function extends the HARBINGER framework and returns an object of class `hanr_fft_amoc`.
#'@return `hanr_fft_amoc` object
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
#'model <- hanr_fft_amoc()
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
hanr_fft_amoc <- function() {
  obj <- harbinger()
  obj$sw_size <- NULL

  class(obj) <- append("hanr_fft_amoc", class(obj))
  return(obj)
}

#'@importFrom stats fft
#'@importFrom stats sd
#'@importFrom changepoint cpt.mean
#'@importFrom changepoint cpts
#'@exportS3Method detect hanr_fft_amoc
detect.hanr_fft_amoc <- function(obj, serie, ...) {
  compute_cut_index <- function(freqs) {
    resultado_cpt <- changepoint::cpt.mean(freqs, method="AMOC")
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
