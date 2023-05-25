
#'@title Harbinger
#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
harbinger <- function() {
  obj <- list()
  obj$log <- FALSE
  obj$debug <- FALSE
  obj$reproduce <- FALSE
  attr(obj, "class") <- "harbinger"
  return(obj)
}

#fit
#'@title Fit a model for event detection
#'@description Basic ancestor function for build model for event detection
#'@details The fit function builds a model for time series event detection.
#'For some methods, the model is not needed to be build, so the function do nothing.
#'
#'@param obj harbinger object
#'@param ... optional arguments./ further arguments passed to or from other methods.
#'@return a harbinger object with model details
#'@examples data(har_examples)
#' dataset <- har_examples[[1]]
#' detector <- harbinger()
#' detector <- fit(detector, dataset$serie)
#'@export
fit <- function(obj, ...) {
  UseMethod("fit")
}

#'@title Fit a general outline of a fit function
#'
#'@description Takes as input a "Harbinger" object and a time series
#'
#'@details This function is a default implementation of the fit() function for the "Harbinger" class, which can be overridden by a specific subclass to perform proper model fit
#'
#'@param obj
#'@param serie
#'
#'@return The "Harbinger" object without doing any processing or tuning of the model
#'@examples
#'@export
fit.harbinger <- function(obj, serie) {
  return(obj)
}

#detect
#'@title Detect events in time series
#'@description Detect event using a Harbinger model for event detection
#'@details The fit function builds a model for time series event detection.
#'For some methods, the model is not needed to be build, so the function do nothing.
#'
#'@param obj harbinger object
#'@param ... optional arguments./ further arguments passed to or from other methods.
#'@return a harbinger object with model details
#'@examples data(har_examples)
#' dataset <- har_examples[[1]]
#' detector <- harbinger()
#' detector <- detect(detector, dataset$serie)
#'@export
detect <- function(obj, ...) {
  UseMethod("detect")
}

#'@title Generic outline for a time series event detection function
#'
#'@description Takes as input a "Harbinger" object and a time series
#'
#'@details The "idx" column represents the index of the observation in the time series, the "event" column indicates whether or not the event occurred in the observation (it is filled with "TRUE" or "FALSE") and the "type" column indicates the type of event detected (if any)
#'
#'@param obj
#'@param serie
#'
#'@return A table with information about detecting events in the time series
#'@example
#'@export
detect.harbinger <- function(obj, serie) {
  return(data.frame(idx = 1:length(serie), event = rep(FALSE, length(serie)), type = ""))
}

#'@title Evaluate the performance of the event detection model against true events
#'
#'@description Takes as input a "Harbinger" object, a set of event detection (stored as a data frame) and a set of true events (also stored as a data frame)
#'
#'@details This function calls the evaluate() function with the given arguments. The evaluate() function is responsible for calculating the appropriate evaluation metrics to compare event detections with true events
#'
#'@param obj
#'@param detection
#'@param event
#'@param evaluation
#'
#'@return The result of the evaluation
#'
#'@example
#'
#'@export
evaluate.harbinger <- function(obj, detection, event, evaluation = hard_evaluation()) {
  return(evaluate(evaluation, detection, event))
}


