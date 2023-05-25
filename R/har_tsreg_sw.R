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

#'@title Implements the fit method of the har_tsreg_sw class to fit a regression model on the time series passed as series argument
#'
#'@description The function receives as parameter an object and a time series
#'
#'@details The function starts by creating a time series object with the ts_data function, which divides the series into sliding windows of size obj$sw_size and returns a list with two columns: input and output
#'
#'@param obj
#'@param serie
#'
#'@return The 'obj' object updated with the adjusted model
#'
#'@examples
#'@export
fit.har_tsreg_sw <- function(obj, serie) {
  ts <- ts_data(serie, obj$sw_size)
  io <- ts_projection(ts)

  obj$model <- fit(obj$model, x=io$input, y=io$output)

  return(obj)
}

#'@title Implements the detect method of the har_tsreg_sw class for detecting anomalies in time series
#'
#'@description The function receives as parameter an object and a time series
#'
#'@details The function starts by defining the length of the time series n and the index of non-missing observations non_na. The function then calls the ts_data function to create a time series object with sliding windows of size obj$sw_size and stores in io the array of input values and vector of output values for the model
#'
#'@param obj
#'@param serie
#'
#'@return The i_outliers array that is included in the detection data structure
#'@examples
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
