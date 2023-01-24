#==== evaluate: Function for evaluating quality of event detection ====
# The evaluate function uses a diverse number of metrics for the analysis of the quality of the many event detection methods. 
# Among these metric, are: true positive, false positive, true negative e false negative, which all compose the confusion matrix; 
# accuracy, which is the ratio between the number of true forecasts and total observations; sensitivity; specificity; prevalence; 
# pos_pred_value; neg_pred_value; detection rate; detection prevalence; balanced accuracy; precision; recall and F1.             
#
# input:
#   events: output from 'evtdet' function regarding a particular times series.
#   reference: data.frame of the same length as the time series with two variables: time, event (boolean indicating true events)
#   metric: String related to the evaluation metrics based on calculation that involve both the events detected, whether corretly 
#   or not, and their total number. Default values do not exist.
#   beta: beta value. Default value= 1
#
# output:
#   calculated metric value.


evaluate <- function(events, reference,
                     metric=c("confusion_matrix","accuracy","sensitivity","specificity","pos_pred_value","neg_pred_value","precision",
                              "recall","F1","prevalence","detection_rate","detection_prevalence","balanced_accuracy"), beta=1){
  #browser()
  if(is.null(events) | is.null(events$time)) stop("No detected events were provided for evaluation",call. = FALSE)

  names(reference) <- c("time","event")
  detected <- cbind.data.frame(time=reference$time,event=0)
  detected[detected$time %in% events$time, "event"] <- 1
  reference_vec <- as.logical(reference$event)
  detected_vec <- as.logical(detected$event)

  hardMetrics <- hard_metrics(detected_vec, reference_vec, beta=beta)

  metric <- match.arg(metric)

  metric_value <- switch(metric,
                         "confusion_matrix" = hardMetrics$confMatrix,
                         "accuracy" = hardMetrics$accuracy,
                         "sensitivity" = hardMetrics$sensitivity,
                         "specificity" = hardMetrics$specificity,
                         "pos_pred_value" = hardMetrics$PPV,
                         "neg_pred_value" = hardMetrics$NPV,
                         "precision" = hardMetrics$precision,
                         "recall" = hardMetrics$recall,
                         "F1" = hardMetrics$F1,
                         "prevalence" = hardMetrics$prevalence,
                         "detection_rate" = hardMetrics$detection_rate,
                         "detection_prevalence" = hardMetrics$detection_prevalence,
                         "balanced_accuracy" = hardMetrics$balanced_accuracy)

  return(metric_value)
}


hard_metrics <- function(detection,events, beta=1){
  TP <- sum(detection & events)
  FP <- sum(detection & !events)
  FN <- sum(!detection & events)
  TN <- sum(!detection & !events)

  confMatrix <- as.table(matrix(c(as.character(TRUE),as.character(FALSE),
                                  round(TP,2),round(FP,2),
                                  round(FN,2),round(TN,2)), nrow = 3, ncol = 2, byrow = TRUE,
                                dimnames = list(c("Detected", "TRUE","FALSE"),
                                                c("Events", ""))))

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

  F1 <- (1+beta^2)*precision*recall/((beta^2 * precision)+recall)

  s_metrics <- list(TP=TP,FP=FP,FN=FN,TN=TN,confMatrix=confMatrix,accuracy=accuracy,
                    sensitivity=sensitivity, specificity=specificity,
                    prevalence=prevalence, PPV=PPV, NPV=NPV,
                    detection_rate=detection_rate, detection_prevalence=detection_prevalence,
                    balanced_accuracy=balanced_accuracy, precision=precision,
                    recall=recall, F1=F1)

  return(s_metrics)
}
