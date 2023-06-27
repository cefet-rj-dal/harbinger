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

#'@export
detect.harbinger <- function(obj, serie, ...) {
  return(data.frame(idx = 1:length(serie), event = rep(FALSE, length(serie)), type = ""))
}

#'@import daltoolbox
#'@export
evaluate.harbinger <- function(obj, detection, event, evaluation = har_eval(), ...) {
  return(evaluate(evaluation, detection, event))
}


