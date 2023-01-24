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

#===== Boxplot analysis of results ======
outliers.boxplot <- function(data, alpha = 1.5){
  org = nrow(data)
  cond <- rep(FALSE, org)
  i = ncol(data)
  q = quantile(data[,i], na.rm=TRUE)
  IQR = q[4] - q[2]
  lq1 = as.double(q[2] - alpha*IQR)
  hq3 = as.double(q[4] + alpha*IQR)
  cond = data[,i] < lq1 | data[,i] > hq3
  return (cond)
}

detect.fbiad <- function(obj, serie) {
  if(is.null(data)) stop("No data was provided for computation", call. = FALSE)

  non_na <- which(!is.na(serie))

  sx <- ts_data(na.omit(serie), obj$sw)
  ma <- apply(sx, 1, mean)
  sxd <- sx - ma
  iF <- as.vector(outliers.boxplot(sxd, obj$alpha))
  iF <- c(rep(FALSE, obj$sw-1), iF)

  sx <- ts_data(rev(na.omit(serie)), obj$sw)
  ma <- apply(sx, 1, mean)
  sxd <- sx - ma
  iB <- as.vector(outliers.boxplot(sxd, obj$alpha))
  iB <- rev(iB)
  iB <- c(iB, rep(FALSE, obj$sw-1))

  inon_na <- iF | iB

  i <- rep(NA, length(serie))
  i[non_na] <- inon_na

  events <- data.frame(idx=1:length(serie), event = i, type="")
  events$type[i] <- "anomaly"

  return(events)
}
