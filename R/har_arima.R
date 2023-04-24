#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
#'@import forecast
#'@import rugarch
#'@import TSPred
har_arima <- function(w = NULL, alpha = 1.5) {
  obj <- harbinger()
  obj$w <- w
  obj$alpha <- alpha
  class(obj) <- append("har_arima", class(obj))
  return(obj)
}

#'@export
detect.har_arima <- function(obj, serie) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  n <- length(serie)
  non_na <- which(!is.na(serie))

  serie <- na.omit(serie)

  #Adjusting a model to the entire series
  model <- forecast::auto.arima(serie)
  order <- model$arma[c(1, 6, 2, 3, 7, 4, 5)]
  w <- obj$w
  if (is.null(w))
    w <- max(order[1], order[2]+1, order[3])

  #Adjustment error on the entire series
  s <- residuals(model)^2
  outliers <- outliers.boxplot.index(s, obj$alpha)
  group_outliers <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
  outliers <- rep(FALSE, length(s))
  for (g in group_outliers) {
    if (length(g) > 0) {
      i <- min(g)
      outliers[i] <- TRUE
    }
  }
  outliers[1:w] <- FALSE
  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"

  return(detection)
}




