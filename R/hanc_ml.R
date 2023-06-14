#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
#'@import forecast
#'@import rugarch
#'@import TSPred
hanc_ml <- function(model, tune = NULL, alpha = 1.5) {
  obj <- harbinger()
  obj$model <- model
  obj$alpha <- alpha
  obj$tune <- tune
  class(obj) <- append("hanc_ml", class(obj))
  return(obj)
}

#'@import daltoolbox
#'@export
fit.hanc_ml <- function(obj, data) {
  obj$model <- daltoolbox::fit(obj$model, data)
  return(obj)
}

#'@export
detect.hanc_ml <- function(obj, data) {
  n <- nrow(data)
  non_na <- which(!is.na(apply(data, 1, max)))
  data <- na.omit(data)

  adjust <- predict(obj$model, data)
  outliers <- which(adjust[,1] < adjust[,2])
  group_outliers <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
  outliers <- rep(FALSE, nrow(data))
  for (g in group_outliers) {
    if (length(g) > 0) {
      i <- min(g)
      outliers[i] <- TRUE
    }
  }
  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"

  return(detection)
}
