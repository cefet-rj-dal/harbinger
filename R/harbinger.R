
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

#'@export
detect.harbinger <- function(obj, serie) {
  return(data.frame(idx = 1:length(serie), event = rep(FALSE, length(serie)), type = ""))
}

#'@export
evaluate.harbinger <- function(obj, detection, event, evaluation = hard_evaluation()) {
  return(evaluate(evaluation, detection, event))
}


