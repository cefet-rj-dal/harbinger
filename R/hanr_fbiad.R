#'@title Anomaly detector using FBIAD
#'@description Anomaly detector using FBIAD
#'@param sw_size Window size for FBIAD
#'@return hanr_fbiad object
#'Forward and Backward Inertial Anomaly Detector (FBIAD) detects anomalies in time series. Anomalies are observations that differ from both forward and backward time series inertia <doi:10.1109/IJCNN55064.2022.9892088>.
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
#' # Configure FBIAD detector
#' model <- hanr_fbiad()
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
#' - Lima, J., Salles, R., Porto, F., Coutinho, R., Alpis, P., Escobar, L., Pacitti, E.,
#'   Ogasawara, E. Forward and Backward Inertial Anomaly Detector: A Novel Time Series
#'   Event Detection Method. Proceedings of the International Joint Conference on Neural
#'   Networks, 2022. doi:10.1109/IJCNN55064.2022.9892088
#'
#'@export
hanr_fbiad <- function(sw_size = 30) {
  obj <- harbinger()
  obj$sw_size <- sw_size

  class(obj) <- append("hanr_fbiad", class(obj))
  return(obj)
}

#'@importFrom tspredit ts_data
#'@importFrom stats na.omit
#'@exportS3Method detect hanr_fbiad
detect.hanr_fbiad <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  sx <- tspredit::ts_data(obj$serie, obj$sw_size)
  ma <- apply(sx, 1, mean)
  resF <- obj$har_distance(sx[,ncol(sx)] - ma)
  iF <- obj$har_outliers(resF)
  iF <- obj$har_outliers_check(iF, resF)
  iF <- c(rep(FALSE, obj$sw_size-1), iF)
  resF <- c(rep(0, obj$sw_size-1), resF)

  sx <- tspredit::ts_data(rev(obj$serie), obj$sw_size)
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
