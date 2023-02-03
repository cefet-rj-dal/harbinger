#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
#'@import forecast
#'@import rugarch
#'@import TSPred
har_tsreg_sw <- function(model, tune = NULL, sw_size = 15, alpha = 1.5) {
  obj <- harbinger()
  obj$model <- model
  obj$sw_size <- sw_size
  obj$alpha <- alpha
  obj$tune <- tune
  class(obj) <- append("har_tsreg_sw", class(obj))
  return(obj)
}

#'@export
fit.har_tsreg_sw <- function(obj, serie) {
  ts <- ts_data(serie, obj$sw_size)
  io <- ts_projection(ts)

  obj$model <- fit(obj$model, x=io$input, y=io$output)

  return(obj)
}

#'@export
detect.har_tsreg_sw <- function(obj, serie) {
  n <- length(serie)
  non_na <- which(!is.na(serie))
  serie <- na.omit(serie)

  ts <- ts_data(serie, obj$sw_size)
  io <- ts_projection(ts)

  adjust <- predict(obj$model, io$input)
  s <- abs(io$output-adjust)
  outliers <- outliers.boxplot.index(s)
  group_outliers <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
  outliers <- rep(FALSE, length(s))
  for (g in group_outliers) {
    if (length(g) > 0) {
      i <- min(g)
      outliers[i] <- TRUE
    }
  }
  outliers <- c(rep(NA, obj$sw_size - 1), outliers)
  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"

  return(detection)
}
