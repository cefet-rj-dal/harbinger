cfARIMA <- function(data) forecast::auto.arima(data)

#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
#'@import forecast
#'@import rugarch
#'@import TSPred
change_finder_arima <- function(sw = 30, alpha = 1.5, m = 5) {
  obj <- harbinger()
  obj$sw <- sw
  obj$alpha <- alpha
  obj$m <- m
  obj$method <- cfARIMA
  class(obj) <- append("change_finder_arima", class(obj))
  return(obj)
}

cfETS <- function(data) forecast::ets(ts(data))

change_finder_ets <- function(sw = 30, alpha = 1.5, m = 5) {
  obj <- change_finder_arima(sw, alpha, m)
  obj$method <- cfETS
  class(obj) <- append("change_finder_ets", class(obj))
  return(obj)
}

cfLR <- function(data) {
  data <- data.frame(t = 1:length(data), x = data)
  lm(x~t, data)
}

change_finder_lr <- function(sw = 30, alpha = 1.5, m = 5) {
  obj <- change_finder_arima(sw, alpha, m)
  obj$method <- cfLR
  class(obj) <- append("change_finder_lr", class(obj))
  return(obj)
}


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

#'@export
detect.change_finder_arima <- function(obj, serie) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  data <- data.frame(time = 1:length(serie), serie = serie)

  non_nas <- which(!is.na(data$serie))
  serie <- na.omit(data$serie)
  omit <- length(serie) < length(data$serie)

  #Adjusting a model to the entire series
  M1 <- obj$method(serie)

  #Adjustment error on the entire series
  s <- residuals(M1)^2

  P1 <- tryCatch(TSPred::arimaparameters(M1)$AR, error = function(e) 0)
  m1 <- ifelse(P1!=0,P1,m)

  s[1:(3*P1)] <- NA

  outliers <- outliers.index(s)
  outliers <- unlist(sapply(split(outliers, cumsum(c(1, diff(outliers) != 1))),
                            function(consec_values){
                              tryCatch(consec_values[c(1:(length(consec_values)-(2*P1-1)))],
                                       error = function(e) consec_values)
                            }
  )
  )
  outliers <- na.omit(outliers)

  y <- TSPred::mas(s,m1)

  #Creating dataframe with y
  Y <- data.frame(Y=y)

  #Adjusting an AR(P) model to the whole window W
  M2 <- tryCatch(obj$method(Y), error = function(e) NULL)
  if(is.null(M2)) return(NULL)

  #Adjustment error on the whole window
  u <- residuals(M2)^2

  P2 <- tryCatch(TSPred::arimaparameters(M2)$AR, error = function(e) 0)
  m2 <- ifelse(P2!=0,P2,m)

  u <- TSPred::mas(u,m2)

  cp <- outliers.index(u) + (m1-1) + (m2-1)

  cp <- unlist(sapply(split(cp, cumsum(c(1, diff(cp) != 1))),
                      function(consec_values){
                        tryCatch(consec_values[1],
                                 error = function(e) consec_values)
                      }
  )
  )

  outliers <- outliers[!outliers %in% cp]

  if(omit) {
    outliers <- non_nas[outliers]
    cp <- non_nas[cp]
  }

  detection <- data.frame(idx=1:length(serie), event = FALSE, type="")
  detection$event[outliers] <- TRUE
  detection$type[outliers] <- "anomaly"
  detection$event[cp] <- TRUE
  detection$type[cp] <- "change_point"

  return(detection)
}


library(dplyr)
data(har_examples)

dataset <- har_examples[[10]]
model <- change_finder_arima(sw=30, alpha=0.5)
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
print(detection |> dplyr::filter(event==TRUE))
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)
library(ggplot2)
grf <- plot(model, dataset$serie, detection)
plot(grf)
grf <- plot(model, dataset$serie, detection, dataset$event)
plot(grf)
