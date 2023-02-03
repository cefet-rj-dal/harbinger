#'@title Harbinger
#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
hard_evaluation <- function() {
  obj <- list()
  attr(obj, "class") <- "hard_evaluation"
  return(obj)
}

#evaluation
#'@title Fit a model for event detection
#'@description Basic ancestor function for build model for event detection
#'@details The fit function builds a model for time series event detection.
#'For some methods, the model is not needed to be build, so the function do nothing.
#'
#'@param obj harbinger object
#'@param ... optional arguments./ further arguments passed to or from other methods.
#'@return a harbinger object with model details
#'@examples evaluation <- hard_evaluation()
#' evaluation <- evaluate(evaluation, c(1, 0, 1, 0), c(0, 0, 1, 0))
#'@export
evaluate <- function(obj, ...) {
  UseMethod("evaluate")
}

#'@export
evaluate.default <- function(obj, detection, event) {
  return(obj)
}

#'@export
evaluate.hard_evaluation <- function(obj, detection, event) {
  detection[is.na(detection)] <- FALSE
  TP <- sum(detection & event)
  FP <- sum(detection & !event)
  FN <- sum(!detection & event)
  TN <- sum(!detection & !event)

  confMatrix <- as.table(matrix(c(as.character(TRUE),as.character(FALSE),
                                  round(TP,2),round(FP,2),
                                  round(FN,2),round(TN,2)), nrow = 3, ncol = 2, byrow = TRUE,
                                dimnames = list(c("detection", "TRUE","FALSE"),
                                                c("event", ""))))

  accuracy <- (TP+TN)/(TP+FP+FN+TN)
  sensitivity <- TP/(TP+FN)
  specificity <- TN/(FP+TN)
  prevalence <- (TP+FN)/(TP+FP+FN+TN)
  PPV <- (sensitivity * prevalence)/((sensitivity*prevalence) + ((1-specificity)*(1-prevalence)))
  NPV <- (specificity * (1-prevalence))/(((1-sensitivity)*prevalence) + ((specificity)*(1-prevalence)))
  detection_rate <- TP/(TP+FP+FN+TN)
  detection_prevalence <- (TP+FP)/(TP+FP+FN+TN)
  balanced_accuracy <- (sensitivity+specificity)/2
  precision <- TP/(TP+FP)
  recall <- TP/(TP+FN)

  beta <- 1
  F1 <- (1+beta^2)*precision*recall/((beta^2 * precision)+recall)

  s_metrics <- list(TP=TP,FP=FP,FN=FN,TN=TN,confMatrix=confMatrix,accuracy=accuracy,
                    sensitivity=sensitivity, specificity=specificity,
                    prevalence=prevalence, PPV=PPV, NPV=NPV,
                    detection_rate=detection_rate, detection_prevalence=detection_prevalence,
                    balanced_accuracy=balanced_accuracy, precision=precision,
                    recall=recall, F1=F1)
  obj <- append(obj, s_metrics)
  attr(obj, "class") <- "hard_evaluation"
  return(obj)
}
