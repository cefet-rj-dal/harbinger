#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
#'@import forecast
#'@import rugarch
#'@import TSPred
har_cla <- function(model, tune = NULL, alpha = 1.5) {
  obj <- harbinger()
  obj$model <- model
  obj$alpha <- alpha
  obj$tune <- tune
  class(obj) <- append("har_cla", class(obj))
  return(obj)
}

#'@export
fit.har_cla <- function(obj, data) {
  obj$model <- fit(obj$model, data)
  return(obj)
}

#'@export
detect.har_cla <- function(obj, data) {
  n <- nrow(data)
  non_na <- which(!is.na(data))
  data <- na.omit(data)

  adjust <- predict(obj$model, data)
  outliers <- which(adjust > 0)
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
