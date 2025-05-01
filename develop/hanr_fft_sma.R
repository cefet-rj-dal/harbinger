#'@title Anomaly Detector using Adaptive FFT and Moving Average
#'@description
#'This function implements an anomaly detection model based on the Fast Fourier Transform (FFT),
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
#'
#'@return `hanr_fft_sma` object
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
hanr_fft_sma <- function() {
  obj <- harbinger()
  obj$sw_size <- NULL
  
  class(obj) <- append("hanr_fft_sma", class(obj))
  return(obj)
}

library(forecast)
har_outliers_group <- function(outliers, size, values = NULL) {
  group <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
  outliers <- rep(FALSE, size)
  for (g in group) {
    if (length(g) > 0) {
      if (is.null(values)) {
        i <- min(g)
        outliers[i] <- TRUE
      }
      else {
        i <- which.max(values[g])
        i <- g[i]
        outliers[i] <- TRUE
      }
    }
  }
  return(outliers)
}

#'@importFrom stats fft
#'@importFrom stats sd
#'@export
detect.hanr_fft_sma <- function(obj, serie, ...) {
  
  # Função para determinar a melhor janela de média móvel com base na FFT
  find_best_moving_average <- function(series) {
    periodogram <- spec.pgram(series, plot = FALSE)
    
    # Determinar a frequência dominante
    dominant_freq <- periodogram$freq[which.max(periodogram$spec)]
    
    # Converter frequência para período aproximado da série
    best_window <- round(1 / dominant_freq)
    
    # Garantir que a janela da média móvel não seja maior que o tamanho da série
    best_window <- min(max(3, best_window), length(series) - 1)
    
    return(best_window)
  }
  
  
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)
  
  obj <- obj$har_store_refs(obj, serie)
  
  # Aplicar a melhor média móvel dinamicamente
  optimal_window <- find_best_moving_average(serie)
  ts_sma <- TTR::SMA(serie, n = optimal_window)
  
  filtered_series <- serie - ts_sma
  # 
  # anomalies <- obj$har_outliers(filtered_series)
  # #anomalies <- obj$har_outliers_group(anomalies, length(filtered_series))
  # anomalies <- har_outliers_group(anomalies, length(filtered_series))
  # 
  # detection <- obj$har_restore_refs(obj, anomalies = anomalies)
  
  res <- obj$har_distance(filtered_series)
  
  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)
  
  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)
  
  return(detection)
}

