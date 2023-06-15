
#'@title Harbinger
#'@description Ancestor class for time series event detection
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@import daltoolbox
#'@export
harbinger <- function() {
  obj <- dal_base()
  class(obj) <- append("harbinger", class(obj))
  return(obj)
}

#'@title Fit a general detector
#'@description Takes as input a "Harbinger" object and a time series
#'@param obj detector
#'@param serie time series
#'@param ... optional arguments.
#'@return The "Harbinger" object without doing any processing or tuning of the model
#'@examples detector <- harbinger()
#'@import daltoolbox
#'@export
fit.harbinger <- function(obj, serie, ...) {
  return(obj)
}

#'@title Detect events in time series
#'@description Detect event using a Harbinger model for event detection
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

#'@title Generic detector
#'@description Takes as input a "Harbinger" object and a time series
#'@param obj detector
#'@param serie time series
#'@param ... optional arguments.
#'@return A dataframe with information about the detected anomalous points
#'@examples detector <- harbinger()
#'@export
detect.harbinger <- function(obj, serie, ...) {
  return(data.frame(idx = 1:length(serie), event = rep(FALSE, length(serie)), type = ""))
}

#'@title Evaluate the performance of the event detection model against true events
#'@description Takes as input a "Harbinger" object, a set of event detection (stored as a data frame) and a set of true events (also stored as a data frame)
#'@param obj detector
#'@param detection detected observations
#'@param event labeled events
#'@param evaluation evaluation object
#'@param ... optional arguments.
#'@return The result of the evaluation
#'@examples detector <- harbinger()
#'@import daltoolbox
#'@export
evaluate.harbinger <- function(obj, detection, event, evaluation = har_eval(), ...) {
  return(evaluate(evaluation, detection, event))
}


