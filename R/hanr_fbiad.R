#'@title Anomaly detector using FBIAD
#'@description Anomaly detector using FBIAD
#'@param sw Window size for FBIAD
#'@param alpha Threshold for outliers
#'@return hanr_fbiad object
#'@examples detector <- harbinger()
#'@export
hanr_fbiad <- function(sw = 30, alpha = 1.5) {
  obj <- harbinger()
  obj$sw <- sw
  obj$alpha <- alpha
  class(obj) <- append("hanr_fbiad", class(obj))
  return(obj)
}

#'@title Anomaly detector using Forward-Backward Inertia Anomaly Detection
#'@description Takes as input a "Harbinger" object and a time series
#'@param obj detector
#'@param serie time series
#'@param ... optional arguments.
#'@return A dataframe with information about the detected anomalous points
#'@import daltoolbox
#'@importFrom stats na.omit
#'@export
detect.hanr_fbiad <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  non_na <- which(!is.na(serie))

  sx <- daltoolbox::ts_data(stats::na.omit(serie), obj$sw)
  ma <- apply(sx, 1, mean)
  sxd <- (sx - ma)^2
  iF <- as.vector(har_outliers(sxd[,ncol(sx)], obj$alpha))
  iF <- c(rep(FALSE, obj$sw-1), iF)

  sx <- ts_data(rev(stats::na.omit(serie)), obj$sw)
  ma <- apply(sx, 1, mean)
  sxd <- (sx - ma)^2
  iB <- as.vector(har_outliers(sxd[,ncol(sx)], obj$alpha))
  iB <- rev(iB)
  iB <- c(iB, rep(FALSE, obj$sw-1))

  inon_na <- iF | iB

  i <- rep(NA, length(serie))
  i[non_na] <- inon_na

  detection <- data.frame(idx=1:length(serie), event = i, type="")
  detection$type[i] <- "anomaly"

  return(detection)
}
