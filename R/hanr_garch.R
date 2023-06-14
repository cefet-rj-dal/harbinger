#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
#'@import forecast
#'@import rugarch
#'@import TSPred
hanr_garch <- function(w = 5, alpha = 1.5) {
  obj <- harbinger()
  obj$alpha <- alpha
  obj$w <- w

  class(obj) <- append("hanr_garch", class(obj))
  return(obj)
}

#'@title Performs anomaly event detection in the time series using the GARCH model
#'
#'@description This function takes a hanr_garch object and a time series series as input
#'
#'@details First, the function fits a GARCH model to the series, calculates the squared residuals and applies a boxplot test to detect outliers. Detected outliers are classified as "anomalies"
#'
#'@param obj
#'@param serie
#'
#'@return A data frame with information about the events detected, including the index of the data point, whether it is an event or not, and the type of event
#'@examples

#'@export
detect.hanr_garch <- function(obj, serie) {
  n <- length(serie)
  non_na <- which(!is.na(serie))
  serie <- na.omit(serie)

  spec <- rugarch::ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
                                 mean.model = list(armaOrder = c(1, 1), include.mean = TRUE),
                                 distribution.model = "norm")

  #Adjusting a model to the entire series
  model <- rugarch::ugarchfit(spec=spec, data=serie, solver="hybrid")@fit

  #Adjustment error on the entire series
  s <- model$sigma
  outliers <- har_outliers_idx(s, obj$alpha)
  group_outliers <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
  outliers <- rep(FALSE, length(s))
  for (g in group_outliers) {
    if (length(g) > 0) {
      i <- min(g)
      outliers[i] <- TRUE
    }
  }
  outliers[1:obj$w] <- FALSE
  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"

  return(detection)
}

