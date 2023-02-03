#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
fbiad <- function(sw = 30, alpha = 1.5) {
  obj <- harbinger()
  obj$sw <- sw
  obj$alpha <- alpha
  class(obj) <- append("fbiad", class(obj))
  return(obj)
}

#'@export
detect.fbiad <- function(obj, serie) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  non_na <- which(!is.na(serie))

  sx <- ts_data(na.omit(serie), obj$sw)
  ma <- apply(sx, 1, mean)
  sxd <- (sx - ma)^2
  iF <- as.vector(outliers.boxplot(sxd[,ncol(sx)], obj$alpha))
  iF <- c(rep(FALSE, obj$sw-1), iF)

  sx <- ts_data(rev(na.omit(serie)), obj$sw)
  ma <- apply(sx, 1, mean)
  sxd <- (sx - ma)^2
  iB <- as.vector(outliers.boxplot(sxd[,ncol(sx)], obj$alpha))
  iB <- rev(iB)
  iB <- c(iB, rep(FALSE, obj$sw-1))

  inon_na <- iF | iB

  i <- rep(NA, length(serie))
  i[non_na] <- inon_na

  detection <- data.frame(idx=1:length(serie), event = i, type="")
  detection$type[i] <- "anomaly"

  return(detection)
}
