cfARIMA <- function(data) forecast::auto.arima(data)

#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
#'@import forecast
#'@import rugarch
#'@import TSPred
change_finder_arima <- function(sw = 30, alpha = 1.5, m = 5) {
  obj <- harbinger()
  obj$sw <- sw
  obj$alpha <- alpha
  obj$m <- m
  obj$method <- cfARIMA
  class(obj) <- append("change_finder_arima", class(obj))
  return(obj)
}

cfETS <- function(data) forecast::ets(ts(data))

change_finder_ets <- function(sw = 30, alpha = 1.5, m = 5) {
  obj <- change_finder_arima(sw, alpha, m)
  obj$method <- cfETS
  class(obj) <- append("change_finder_ets", class(obj))
  return(obj)
}

#===== Boxplot analysis of results ======
outliers.index <- function(data, alpha = 3){
  org = length(na.omit(c(data)))
  index.cp = NULL

  if (org >= 30) {
    q = quantile(data,na.rm=TRUE)

    IQR = q[4] - q[2]
    lq1 = q[2] - alpha*IQR
    hq3 = q[4] + alpha*IQR

    cond = data > hq3 #data < lq1 | data > hq3

    index.cp = which(cond)
  }
  else  warning("Insufficient data (< 30)")

  return (index.cp)
}

#'@export
detect.change_finder_arima <- function(obj, serie) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  n <- length(serie)
  non_na <- which(!is.na(serie))

  serie <- na.omit(serie)

  #Adjusting a model to the entire series
  M1 <- obj$method(serie)

  #Adjustment error on the entire series
  s <- residuals(M1)^2
  outliers <- outliers.index(s)
  group_outliers <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
  outliers <- rep(FALSE, length(s))
  for (g in group_outliers) {
    i <- min(g)
    outliers[i] <- TRUE
  }
  outliers[1:obj$m] <- FALSE

  y <- TSPred::mas(s, obj$m)

  #Adjusting to the entire series
  M2 <- obj$method(y)

  #Adjustment error on the whole window
  u <- residuals(M2)^2

  u <- TSPred::mas(u, obj$m)
  cp <- outliers.index(u)
  group_cp <- split(cp, cumsum(c(1, diff(cp) != 1)))
  cp <- rep(FALSE, length(u))
  for (g in group_cp) {
    i <- min(g)
    cp[i] <- TRUE
  }
  cp[1:obj$m] <- FALSE
  cp <- c(rep(FALSE, length(s)-length(u)), cp)

  #cp <- c(rep(FALSE, length(outliers)-length(cp)), cp)

  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  i_cp <- rep(NA, n)
  i_cp[non_na] <- cp


  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"
  detection$event[cp] <- TRUE
  detection$type[cp] <- "change_point"

  return(detection)
}
