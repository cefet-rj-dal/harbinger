#'@title Anomaly detector using FBIAD
#'@description Anomaly detector using FBIAD
#'@param sw_size Window size for FBIAD
#'@return hanr_fbiad object
#'Forward and Backward Inertial Anomaly Detector (FBIAD) detects anomalies in time series. Anomalies are observations that differ from both forward and backward time series inertia <doi:10.1109/IJCNN55064.2022.9892088>.
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
#'model <- hanr_fbiad()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
# making detection using hanr_ml
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection |> dplyr::filter(event==TRUE))
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

  non_na <- which(!is.na(serie))

  sx <- daltoolbox::ts_data(stats::na.omit(serie), obj$sw_size)
  ma <- apply(sx, 1, mean)
  sxd <- obj$har_residuals(sx - ma)
  iF <- as.vector(obj$har_outliers(sxd[,ncol(sx)]))
  iF <- c(rep(FALSE, obj$sw_size-1), iF)

  sx <- ts_data(rev(stats::na.omit(serie)), obj$sw_size)
  ma <- apply(sx, 1, mean)
  sxd <- obj$har_residuals(sx - ma)
  iB <- as.vector(obj$har_outliers(sxd[,ncol(sx)]))
  iB <- rev(iB)
  iB <- c(iB, rep(FALSE, obj$sw_size-1))

  inon_na <- iF | iB

  i <- rep(NA, length(serie))
  i[non_na] <- inon_na

  detection <- data.frame(idx=1:length(serie), event = i, type="")
  detection$type[i] <- "anomaly"

  return(detection)
}
