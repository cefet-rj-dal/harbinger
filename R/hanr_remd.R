#'@title Anomaly detector using REMD
#'@description Anomaly detection using REMD
#'The EMD model adjusts to the time series. Observations distant from the model are labeled as anomalies.
#'It wraps the EMD model presented in the forecast library.
#'@param noise nosie
#'@param trials trials
#'@return `hanr_remd` object
#'
#'@examples
#'library(daltoolbox)
#'
#' # Load anomaly example data
#' data(examples_anomalies)
#'
#' # Use a simple example
#' dataset <- examples_anomalies$simple
#' head(dataset)
#'
#' # Configure REMD detector
#' model <- hanr_remd()
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
#' - Souza, J., Paixão, E., Fraga, F., Baroni, L., Alves, R. F. S., Belloze, K., Dos Santos, J.,
#'   Bezerra, E., Porto, F., Ogasawara, E. REMD: A Novel Hybrid Anomaly Detection Method Based on
#'   EMD and ARIMA. Proceedings of the International Joint Conference on Neural Networks, 2024.
#'   doi:10.1109/IJCNN60899.2024.10651192
#'
#'@export
hanr_remd <- function(noise = 0.1, trials = 5) {
  obj <- hanr_emd(noise, trials)
  class(obj) <- append("hanr_remd", class(obj))

  hutils <- harutils()
  obj$har_distance <- hutils$har_distance_l1
  obj$har_outliers <- hutils$har_outliers_ratio

  return(obj)
}

#'@importFrom stats median
#'@importFrom stats sd
fc_roughness <- function(x) {
  firstD = diff(x)
  normFirstD = (firstD - mean(firstD)) / sd(firstD)
  roughness = (diff(normFirstD) ** 2) / 4
  return(mean(roughness))
}

#'@importFrom tspredit ts_data
#'@importFrom tspredit ts_projection
#'@importFrom tspredit ts_arima
#'@importFrom daltoolbox transform
#'@importFrom daltoolbox fit_curvature_min
#'@importFrom stats median
#'@importFrom stats sd
#'@importFrom hht CEEMD
#'@exportS3Method detect hanr_remd
detect.hanr_remd <- function(obj, serie, ...) {
  if (is.null(serie))
    stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  id <- 1:length(obj$serie)
  obj$sw_size <-  length(obj$serie)

  suppressWarnings(ceemd.result <- hht::CEEMD(obj$serie, id, verbose = FALSE, obj$noise, obj$trials))

  obj$model <- ceemd.result
  #  calculate roughness for each imf
  vec <- vector()
  for (n in 1:obj$model$nimf) {
    vec[n] <- fc_roughness(obj$model[["imf"]][, n])
  }

  vec <- cumsum(vec)

  #  Maximum curvature
  res <- daltoolbox::transform(daltoolbox::fit_curvature_min(), vec)
  div <- res$x
  sum_high_freq <- obj$model[["imf"]][, 1]

  if (div > 1) {
    for (k in 2:div) {
      sum_high_freq <- sum_high_freq + obj$model[["imf"]][, k]
    }
  }

  ts <- tspredit::ts_data(sum_high_freq, 0)
  io <- tspredit::ts_projection(ts)
  model <- tspredit::ts_arima()
  model <- fit(model, x = io$input, y = io$output)
  adjust <- predict(model, io$input)
  adjust <- as.vector(adjust)

  # Calculation of inverse probability
  res <- obj$har_distance(adjust - sum_high_freq)
  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}
