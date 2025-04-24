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
#'@importFrom daltoolbox ts_norm_gminmax
#'@export
han_autoencoder <- function(input_size, encode_size, encoderclass = autoenc_ed, ...) {
  obj <- harbinger()

  obj$input_size <- input_size
  obj$encode_size <- encode_size
  obj$model <- encoderclass(obj$input_size, obj$encode_size, ...)
  obj$preproc <- daltoolbox::ts_norm_gminmax()

  hutils <- harutils()
  obj$har_outliers_check <- hutils$har_outliers_checks_highgroup

  class(obj) <- append("han_autoencoder", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@exportS3Method fit han_autoencoder
fit.han_autoencoder <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  serie <- stats::na.omit(serie)

  ts <- ts_data(serie, obj$input_size)

  obj$preproc <- fit(obj$preproc, ts)
  ts <- transform(obj$preproc, ts)
  ts <- as.data.frame(ts)

  obj$model <- fit(obj$model, ts)

  return(obj)
}


#'@import daltoolbox
#'@importFrom stats na.omit
#'@importFrom graphics hist
#'@exportS3Method detect han_autoencoder
detect.han_autoencoder <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  ts <- ts_data(obj$serie, obj$input_size)
  ts <- transform(obj$preproc, ts)
  ts <- as.data.frame(ts)

  result <- as.data.frame(transform(obj$model, ts))

  ts <- c(as.double(ts[1,1:(ncol(ts)-1)]),as.double(ts[,ncol(ts)]))
  ts_ae <- c(as.double(result[1,1:(ncol(result)-1)]),as.double(result[,ncol(result)]))

  res <- obj$har_distance(ts - ts_ae)
  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}
