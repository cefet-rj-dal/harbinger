#' @title Resilient Transformation Anomaly Detector (RTAD)
#' @description
#' Hybrid anomaly detector built from the Resilient Transformation (RT) proposed
#' in the RT/RTAD paper. The series is decomposed with CEEMD, the highest-frequency
#' structure is selected from IMF roughness, the transformed signal is differentiated,
#' and local dispersion is used to normalize deviations before thresholding.
#'
#' RTAD is not a generic wrapper around EMD. It is the standalone detector obtained
#' when the resilient transformation is coupled with a simple decision rule.
#'
#' @param sw_size Sliding window size used to compute local dispersion.
#' @param noise CEEMD noise amplitude.
#' @param trials Number of CEEMD trials.
#' @param sigma Function used to compute local dispersion.
#'@return `hanr_rtad` object
#'@examples
#'library(daltoolbox)
#'library(zoo)
#'
#' # Load anomaly example data
#' data(examples_anomalies)
#'
#' # Use a simple example
#' dataset <- examples_anomalies$simple
#' head(dataset)
#'
#' # Configure RTAD detector
#' model <- hanr_rtad()
#'
#' # Fit the model
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected events
#' print(detection[(detection$event),])
#'
#' @references
#' - Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. 1st ed.
#'   Cham: Springer Nature Switzerland, 2025. doi:10.1007/978-3-031-75941-3
#'
#'@export
hanr_rtad <- function(sw_size = 30, noise = 0.001, trials = 5, sigma = sd) {
  obj <- harbinger()
  obj$sw_size <- sw_size
  obj$noise <- noise
  obj$trials <- trials
  obj$sigma <- sigma

  class(obj) <- append("hanr_rtad", class(obj))
  return(obj)
}

# Roughness of an IMF, used to select the high-frequency regime.
#'@importFrom stats sd
fc_rug <- function(x){
  firstD = diff(x)
  normFirstD = (firstD - mean(firstD)) / sd(firstD)
  roughness = (diff(normFirstD) ** 2) / 4
  return(mean(roughness))
}

# Sum a contiguous range of IMFs into a single reconstructed signal.
fc_somaIMF <- function(ceemd.result, inicio, fim){
  soma_imf <- rep(0, length(ceemd.result[["original.signal"]]))
  for (k in inicio:fim){
    soma_imf <- soma_imf + ceemd.result[["imf"]][,k]
  }
  return(soma_imf)
}

#'@importFrom stats median
#'@importFrom stats sd
#'@importFrom hht CEEMD
#'@importFrom zoo rollapply
#'@importFrom daltoolbox transform
#'@importFrom daltoolbox fit_curvature_max
#'@exportS3Method detect hanr_rtad
detect.hanr_rtad <- function(obj, serie, ...) {
  if (is.null(serie))
    stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  id <- 1:length(obj$serie)
  san_size <-  length(obj$serie)

  # CEEMD decomposition of the observed series.
  suppressWarnings(ceemd.result <- hht::CEEMD(obj$serie, id, verbose = FALSE, obj$noise, obj$trials))

  model_an <- ceemd.result

  if (model_an$nimf < 4){
    soma_an <- obj$serie - model_an$residue
  }else{
    # Measure roughness of each IMF and keep the high-frequency block.
    vec <- vector()
    for (n in 1:model_an$nimf){
      vec[n] <- fc_rug(model_an[["imf"]][,n])
    }

    # Use maximum curvature to select the split between retained and discarded IMFs.
    res <- daltoolbox::transform(daltoolbox::fit_curvature_max(), vec)
    div <- res$x

    # Reconstruct the transformed signal from the selected IMFs.
    soma_an <- fc_somaIMF(model_an, 1, div)
  }

  # First-order differencing of the reconstructed signal.
  diff_soma <- c(NA, diff(soma_an))
  diff_soma[1] <- diff_soma[2]


  # Detrend using the CEEMD residue when available.
  isEmpty <- function(x) {
    return(length(x)==0)
  }

  if(isEmpty(model_an$residue)){
    d_serie <- obj$serie
  }else{
    d_serie <- obj$serie-model_an$residue
  }

  # Local dispersion normalization over a sliding window.
  dm <-  rollapply(d_serie, obj$sw_size, obj$sigma, by = 1, partial=TRUE)

  # The normalized residual becomes the anomaly score.
  RTAD_transform <- diff_soma/dm

  res <- obj$har_distance(RTAD_transform)

  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}


