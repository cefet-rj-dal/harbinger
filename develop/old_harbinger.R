har_old_evtdet <- function(data,func,...){
  if(is.null(data)) stop("No data was provided for computation",call. = FALSE)

  events <- do.call(func,c(list(data),list(...)))

  return(events)
}

#====== Auxiliary Model definitions ======
har_old_changeFinder.ARIMA <- function(data) forecast::auto.arima(data)
har_old_changeFinder.ets <- function(data) forecast::ets(ts(data))
har_old_changeFinder.linreg <- function(data) {
  data <- as.data.frame(data)
  colnames(data) <- "x"
  data$t <- 1:nrow(data)
  lm(x~t, data)
}

har_old_evtdet.changeFinder <- function(data,...){
  if(is.null(data)) stop("No data was provided for computation",call. = FALSE)

  changepoints_v3 <- function(data,mdl_fun,m=5,na.action=na.omit,...){
    #browser()
    serie_name <- names(data)[-1]
    names(data) <- c("time","serie")

    serie <- data$serie
    len_data <- length(data$serie)

    serie <- na.action(serie)

    omit <- FALSE
    if(length(serie)<len_data){
      non_nas <- which(!is.na(data$serie))
      omit <- TRUE
    }

    #Adjusting a model to the whole window W
    M1 <- tryCatch(mdl_fun(serie,...), error = function(e) NULL)
    if(is.null(M1)) M1 <- tryCatch(mdl_fun(serie), error = function(e) NULL)
    if(is.null(M1)) return(NULL)

    #Adjustment error on the whole window
    s <- residuals(M1)^2

    P1 <- tryCatch(TSPred::arimaparameters(M1)$AR, error = function(e) 0)
    m1 <- ifelse(P1!=0,P1,m)

    s[1:(3*P1)] <- NA

    #===== Boxplot analysis of results ======
    outliers.index <- function(data, alpha = 3){
      org = length(na.omit(c(data)))
      index.cp = NULL

      if (org >= 30) {
        q = quantile(data,na.rm=TRUE)

        IQR = q[4] - q[2]
        lq1 = q[2] - alpha*IQR
        hq3 = q[4] + alpha*IQR

        cond = data > hq3 #data < lq1 | data > hq3

        index.cp = which(cond)
      }
      else  warning("Insufficient data (< 30)")

      return (index.cp)
    }

    outliers <- outliers.index(s)
    outliers <- unlist(sapply(split(outliers, cumsum(c(1, diff(outliers) != 1))),
                              function(consec_values){
                                tryCatch(consec_values[c(1:(length(consec_values)-(2*P1-1)))],
                                         error = function(e) consec_values)
                              }
    )
    )
    outliers <- na.omit(outliers)

    #s[outliers.index(s)] <- NA

    y <- TSPred::mas(s,m1)

    #Creating dataframe with y
    Y <- as.data.frame(y)
    colnames(Y) <- "y"

    #Adjusting an AR(P) model to the whole window W
    M2 <- tryCatch(mdl_fun(Y,...), error = function(e) NULL)
    if(is.null(M2)) M2 <- tryCatch(mdl_fun(Y), error = function(e) NULL)
    if(is.null(M2)) return(NULL)

    #Adjustment error on the whole window
    u <- residuals(M2)^2

    P2 <- tryCatch(TSPred::arimaparameters(M2)$AR, error = function(e) 0)
    m2 <- ifelse(P2!=0,P2,m)

    u <- TSPred::mas(u,m2)

    cp <- outliers.index(u) + (m1-1) + (m2-1)

    cp <- unlist(sapply(split(cp, cumsum(c(1, diff(cp) != 1))),
                        function(consec_values){
                          tryCatch(consec_values[1],#c(1:(length(consec_values)-(m1+m2-1)))],
                                   error = function(e) consec_values)
                        }
    )
    )

    outliers <- outliers[!outliers %in% cp]

    if(omit) {
      outliers <- non_nas[outliers]
      cp <- non_nas[cp]
    }

    events <- c(outliers,cp)
    events <- events[order(events)]
    anomalies <- cbind.data.frame(time=data[events,"time"],serie=serie_name,type="anomaly")
    anomalies$type <- as.character(anomalies$type)
    anomalies[anomalies$time %in% data[cp,"time"], "type"] <- "change point"
    names(anomalies) <- c("time","serie","type")

    return(anomalies)
  }

  events <- har_old_evtdet(data,changepoints_v3,...)

  return(events)
}

har_old_evtdet.mdl_outlier <- function(data,...){
  if(is.null(data)) stop("No data was provided for computation",call. = FALSE)

  mdl_outlier <- function(data,mdl,alpha=1.5,na.action=na.omit,...){
    #browser()
    serie_name <- names(data)[-1]
    names(data) <- c("time","serie")

    serie <- data$serie
    len_data <- length(data$serie)

    serie <- na.action(serie)

    omit <- FALSE
    if(length(serie)<len_data){
      non_nas <- which(!is.na(data$serie))
      omit <- TRUE
    }

    #Adjusting a model to the whole window W
    M1 <- tryCatch(mdl(serie,...), error = function(e) NULL)
    if(is.null(M1)) M1 <- tryCatch(mdl(serie), error = function(e) NULL)
    if(is.null(M1)) return(NULL)

    errors <- tryCatch(residuals(M1), error = function(e) NULL)
    if(is.null(errors)) errors <- M1$residuals

    #===== Boxplot analysis of results ======
    outliers.index <- function(data, alpha = 1.5){
      org = length(data)

      if (org >= 30) {
        q = quantile(data)

        IQR = q[4] - q[2]
        lq1 = q[2] - alpha*IQR
        hq3 = q[4] + alpha*IQR
        cond = data < lq1 | data > hq3
        index.cp = which(cond)#data[cond,]
      }
      return (index.cp)
    }

    #Returns index of windows with outlier error differences
    index.cp <- outliers.index(errors,alpha)

    if(omit) index.cp <- non_nas[index.cp]

    anomalies <- cbind.data.frame(time=data[index.cp,"time"],serie=serie_name,type="anomaly")
    names(anomalies) <- c("time","serie","type")

    return(anomalies)
  }

  events <- har_old_evtdet(data,mdl_outlier,...)

  return(events)
}


har_old_evaluate <- function(events, reference,
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
