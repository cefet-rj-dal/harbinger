#'@title Anomaly detector using FBIAD
#'@description Anomaly detector using FBIAD
#'@param sw_size Window size for FBIAD
#'@return hanr_fbiad object
#'Forward and Backward Inertial Anomaly Detector (FBIAD) detects anomalies in time series. Anomalies are observations that differ from both forward and backward time series inertia <doi:10.1109/IJCNN55064.2022.9892088>.
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
#'# setting up time series regression model
#'model <- hanr_fbiad()
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
hanr_fbiad <- function(sw_size = 30) {
  obj <- harbinger()
  obj$sw_size <- sw_size

  class(obj) <- append("hanr_fbiad", class(obj))
  return(obj)
}

#'@import daltoolbox
#'@importFrom stats na.omit
#'@export
detect.hanr_fbiad <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  sx <- daltoolbox::ts_data(obj$serie, obj$sw_size)
  ma <- apply(sx, 1, mean)
  resF <- obj$har_distance(sx[,ncol(sx)] - ma)
  iF <- obj$har_outliers(resF)
  iF <- obj$har_outliers_check(iF, resF)
  iF <- c(rep(FALSE, obj$sw_size-1), iF)
  resF <- c(rep(0, obj$sw_size-1), resF)

  sx <- ts_data(rev(obj$serie), obj$sw_size)
  ma <- apply(sx, 1, mean)
  resB <- obj$har_distance(sx[,ncol(sx)] - ma)
  iB <- obj$har_outliers(resB)
  iB <- obj$har_outliers_check(iB, resB)
  iB <- rev(iB)
  iB <- c(iB, rep(FALSE, obj$sw_size-1))
  resB <- rev(resB)
  resB <- c(resB, rep(0, obj$sw_size-1))

  res <- (resB + resF)/2

  anomalies <- iF | iB

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}
