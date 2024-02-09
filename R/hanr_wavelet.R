#library(harbinger)
#library(TSPred)

#'@title Anomaly detector using WAVELET.
#'@description Anomaly detection using WAVELET
#'The function uses the discrete Wavelet transform to detect anomalies through the frequency component.
#'Observations in the frequency component that are outside the tolerance (2 * 2,698 standard deviations) are considered anomalies.
#'@return `hanr_wavelet` object
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
#'# setting up time series regression model
#'model <- hanr_wavelet()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
# making detection using hanr_ml
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'
#'@export
hanr_wavelet <- function() {
  obj <- harbinger()
  obj$sw_size <- NULL

  class(obj) <- append("hanr_wavelet", class(obj))
  return(obj)
}

#'@importFrom stats residuals
#'@importFrom stats na.omit
#'@export
detect.hanr_wavelet <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  desvios <- 2.698 *2

  # 1) "Blank" vector for marking events identified by the method
  matrix_forecast_cw <- rep(0, length(obj$serie))

  # 2) Performing the discrete wavelet transform
  wt <- WaveletT(obj$serie, filter="la8") # Opções de filtro: "haar", "d4", "la8", "bl14", "c6"

  # 3) Treating the coefficients Waveletwt@W$W1
  CoefWavelet <- wt$W1
  # 3.1 Disregarding ONLY the initial 6% of the coefficient vector
  discard <- ceiling(length(CoefWavelet)*0.06)
  CoefWavelet <-  CoefWavelet[-c(1:discard)]


  # 4) Calculating the trend component of Wavelet coefficients
  wt_ct <- attr(wt,"wt_obj")
  n <- length(wt_ct@V)
  for (i in 1:length(wt_ct@W)) {
    wt_ct@W[[i]] <- as.matrix(rep(0, length(wt_ct@W[[i]])), ncol=1)
  }

  # 5) Outlier analysis in the wavelet coefficient vector
  candidates <- boxplot.stats(CoefWavelet)$out
  candidates_limit <- min(abs(candidates))

  # 6) Marking candidates for anomalies
  # 6.1 Using the automatic threshold value to identify anomalies
  threshold <- candidates_limit
  anomaly_wavelet <- which(abs(wt$W1) >= threshold)
  # 6.2 Discard the initial 6% of the coefficient vector
  anomaly_wavelet <- anomaly_wavelet[anomaly_wavelet > discard]

  # 6.3 Selection of candidates based on frequency criteria
  cw_tol <- (desvios * sd(CoefWavelet))
  anomaly_cw_tol <- which(abs(wt$W1) > cw_tol)
  anomaly_cw_tol <- anomaly_cw_tol[anomaly_cw_tol > discard]
  anomaly_cw_tol <- (anomaly_cw_tol * length(obj$serie) / length(wt$W1)) - 4
  anomaly_cw_tol <- anomaly_cw_tol[anomaly_cw_tol > 0]

  # 6.4 Marking of events identified by the method
  for(i in anomaly_cw_tol){
    matrix_forecast_cw[i] <- 1
  }

  # 7) Assembling the output matrix
  anomalies <- obj$har_outliers_idx(matrix_forecast_cw)
  anomalies <- obj$har_outliers_group(anomalies, length(matrix_forecast_cw))

  detection <- obj$har_restore_refs(obj, anomalies = anomalies)
  return(detection)
}

