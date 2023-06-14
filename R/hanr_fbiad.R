#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
hanr_fbiad <- function(sw = 30, alpha = 1.5) {
  obj <- harbinger()
  obj$sw <- sw
  obj$alpha <- alpha
  class(obj) <- append("hanr_fbiad", class(obj))
  return(obj)
}

#'@title Implements a time series anomaly detection method
#'
#'@description Takes as input an object and a time series. It uses the hanr_fbiad method to detect anomalies in the time series.
#'
#'@details First, the function checks if there is data available in the time series. Then, the series is divided into windows of size 'obj$sw', and the average in each window is calculated. The quadratic difference between the original series and the mean of the window is then calculated and subjected to a boxplot-based anomaly detection test with threshold defined by 'obj$alpha'
#'
#'@param obj
#'@param serie
#'
#'@return A detection table is returned with the index of each data point, its anomaly state (TRUE or FALSE) and an event type (defined as "anomaly" in this function)
#'
#'@examples
#'@import daltoolbox
#'@export
detect.hanr_fbiad <- function(obj, serie) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  non_na <- which(!is.na(serie))

  sx <- daltoolbox::ts_data(na.omit(serie), obj$sw)
  ma <- apply(sx, 1, mean)
  sxd <- (sx - ma)^2
  iF <- as.vector(har_outliers(sxd[,ncol(sx)], obj$alpha))
  iF <- c(rep(FALSE, obj$sw-1), iF)

  sx <- ts_data(rev(na.omit(serie)), obj$sw)
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
