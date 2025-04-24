#'@title Evaluation of event detection
#'@description Evaluation of event detection (traditional hard evaluation)
#'@return `har_eval` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(examples_anomalies)
#'
#'dataset <- examples_anomalies$simple
#'head(dataset)
#'
#'# setting up time change point using GARCH
#'model <- hcp_garch()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
#'# making detections
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'
#'# evaluating the detections
#'evaluation <- evaluate(har_eval(), detection$event, dataset$event)
#'print(evaluation$confMatrix)
#'
#'# ploting the results
#'grf <- har_plot(model, dataset$serie, detection, dataset$event)
#'plot(grf)
#'@export
har_eval <- function() {
  obj <- dal_base()
  class(obj) <- append("har_eval", class(obj))
  return(obj)
}

#'@importFrom daltoolbox evaluate
#'@exportS3Method evaluate har_eval
evaluate.har_eval <- function(obj, detection, event, ...) {
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
  return(s_metrics)
}



#'@importFrom daltoolbox evaluate
#'@exportS3Method evaluate harbinger
evaluate.harbinger <- function(obj, detection, event, ...) {
  return(har_eval(), detection, event)
}
