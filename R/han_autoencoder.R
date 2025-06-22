#'@title Anomaly detector using autoencoder
#'@description Anomaly detector using autoencoder
#'@param input_size Establish the input size for the autoencoder anomaly detector. It is the size of the output also.
#'@param encode_size The encode size for the autoencoder.
#'@param encoderclass The class of daltoolbox encoder-decoder.
#'@param ... optional arguments for encoder-decoder class.
#'@return han_autoencoder object
#'histogram based method to detect anomalies in time series. Bins with smaller amount of observations are considered anomalies. Values below first bin or above last bin are also considered anomalies.>.
#'@examples
#'#See an example of using `autoenc_ed` at this
#'#https://github.com/cefet-rj-dal/harbinger/blob/master/anomalies/han_autoenc_ed
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
