#' @title Anomaly detector using autoencoders
#' @description
#' Trains an encoder-decoder (autoencoder) to reconstruct sliding windows of the
#' series; large reconstruction errors indicate anomalies.
#'
#' @param input_size Integer. Input (and output) window size for the autoencoder.
#' @param encode_size Integer. Size of the encoded (bottleneck) representation.
#' @param encoderclass DALToolbox encoder-decoder constructor to instantiate.
#' @param ... Additional arguments forwarded to `encoderclass`.
#'
#' @return `han_autoencoder` object
#'
#' @examples
#' library(daltoolbox)
#' library(tspredit)
#'
#' # Load anomaly example data
#' data(examples_anomalies)
#'
#' # Use a simple example
#' dataset <- examples_anomalies$simple
#' head(dataset)
#'
#' # Configure an autoencoder-based anomaly detector
#' model <- han_autoencoder(input_size = 5, encode_size = 3)
#'
#' # Fit the model
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Inspect detected anomalies
#' print(detection[detection$event, ])
#'
#' @references
#' - Sakurada M, Yairi T (2014). Anomaly Detection Using Autoencoders with
#'   Nonlinear Dimensionality Reduction. MLSDA 2014.
#'
#'@importFrom stats na.omit
#'@importFrom daltoolbox autoenc_base_ed
#'@importFrom tspredit ts_norm_gminmax
#'@export
han_autoencoder <- function(input_size, encode_size, encoderclass = autoenc_base_ed, ...) {
  obj <- harbinger()

  obj$input_size <- input_size
  obj$encode_size <- encode_size
  obj$model <- encoderclass(obj$input_size, obj$encode_size, ...)
  obj$preproc <- tspredit::ts_norm_gminmax()

  hutils <- harutils()

  class(obj) <- append("han_autoencoder", class(obj))
  return(obj)
}

#'@importFrom daltoolbox fit
#'@importFrom tspredit ts_data
#'@importFrom stats na.omit
#'@exportS3Method fit han_autoencoder
fit.han_autoencoder <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  serie <- stats::na.omit(serie)

  ts <- tspredit::ts_data(serie, obj$input_size)

  obj$preproc <- daltoolbox::fit(obj$preproc, ts)
  ts <- daltoolbox::transform(obj$preproc, ts)
  ts <- as.data.frame(ts)

  obj$model <- daltoolbox::fit(obj$model, ts)

  return(obj)
}


#'@importFrom daltoolbox transform
#'@importFrom tspredit ts_data
#'@importFrom stats na.omit
#'@importFrom graphics hist
#'@exportS3Method detect han_autoencoder
detect.han_autoencoder <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  ts <- tspredit::ts_data(obj$serie, obj$input_size)
  ts <- daltoolbox::transform(obj$preproc, ts)
  ts <- as.data.frame(ts)

  result <- as.data.frame(daltoolbox::transform(obj$model, ts))
  res <- apply(ts - result, 1, sum, na.rm=TRUE)

  res <- obj$har_distance(res)
  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)

  threshold <- attr(anomalies, "threshold")

  res <- c(rep(0, obj$input_size - 1), res)
  anomalies <- c(rep(FALSE, obj$input_size - 1), anomalies)
  attr(anomalies, "threshold") <- threshold

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}
