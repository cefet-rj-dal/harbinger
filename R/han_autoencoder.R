#'@title Anomaly detector using autoencoder
#'@description Anomaly detector using autoencoder
#'@param input_size Establish the input size for the autoencoder anomaly detector. It is the size of the output also.
#'@param encode_size The encode size for the autoencoder.
#'@return han_autoencoder object
#'histogram based method to detect anomalies in time series. Bins with smaller amount of observations are considered anomalies. Values below first bin or above last bin are also considered anomalies.>.
#'@examples
#'# setting up time series regression model
#'#Use the same example of hanr_fbiad changing the constructor to:
#'model <- han_autoencoder(5,3)
#'@importFrom stats na.omit
#'@export
han_autoencoder <- function(input_size, encode_size) {
  obj <- harbinger()
  obj$input_size <- input_size
  obj$encode_size <- encode_size
  obj$auto <- autoenc_encode_decode(obj$input_size, obj$encode_size)
  obj$preproc <- ts_norm_gminmax()
  class(obj) <- append("han_autoencoder", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@export
fit.han_autoencoder <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  serie <- stats::na.omit(serie)

  ts <- ts_data(serie, obj$input_size)

  obj$preproc <- fit(obj$preproc, ts)
  ts <- transform(obj$preproc, ts)
  ts <- as.data.frame(ts)

  obj$auto <- fit(obj$auto, ts)

  return(obj)
}


#'@import daltoolbox
#'@importFrom stats na.omit
#'@importFrom graphics hist
#'@export
detect.han_autoencoder <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  non_na <- which(!is.na(serie))

  ts_data <- stats::na.omit(serie)

  anomalies <- rep(FALSE, length(ts_data))


  ts <- ts_data(ts_data, obj$input_size)
  ts <- transform(obj$preproc, ts)
  ts <- as.data.frame(ts)

  result <- as.data.frame(transform(obj$auto, ts))

  ts <- c(as.double(ts[1,1:(ncol(ts)-1)]),as.double(ts[,ncol(ts)]))
  ts_ae <- c(as.double(result[1,1:(ncol(result)-1)]),as.double(result[,ncol(result)]))

  sxd <- obj$har_residuals(ts - ts_ae)
  anomalies <- as.vector(obj$har_outliers(sxd))

  inon_na <- anomalies

  i <- rep(NA, length(serie))
  i[non_na] <- inon_na

  detection <- data.frame(idx=1:length(serie), event = i, type="")
  detection$type[i] <- "anomaly"

  return(detection)
}
