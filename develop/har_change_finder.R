#====== Auxiliary Model definitions ======
har_changeFinder.ARIMA <- function(data) forecast::auto.arima(data)
har_changeFinder.ets <- function(data) forecast::ets(ts(data))
har_changeFinder.linreg <- function(data) {
  data <- as.data.frame(data)
  colnames(data) <- "x"
  data$t <- 1:nrow(data)
  lm(x~t, data)
}



#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
#'@import forecast
#'@import rugarch
#'@import TSPred
change_finder <- function(sw = 30, alpha = 1.5) {
  obj <- harbinger()
  obj$sw <- sw
  obj$alpha <- alpha
  obj$method <- har_changeFinder.ARIMA
  class(obj) <- append("change_finder", class(obj))
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



changepoints_v3 <- function(data, mdl_fun, m=5){
  #browser()
  serie_name <- names(data)[-1]
  names(data) <- c("time","serie")

  serie <- data$serie
  len_data <- length(data$serie)

  serie <- na.omit(serie)

  omit <- FALSE
  if(length(serie)<len_data){
    non_nas <- which(!is.na(data$serie))
    omit <- TRUE
  }

  #Adjusting a model to the whole window W
  M1 <- tryCatch(mdl_fun(serie), error = function(e) NULL)
  if(is.null(M1)) return(NULL)

  #Adjustment error on the whole window
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

  #s[outliers.index(s)] <- NA

  y <- TSPred::mas(s,m1)

  #Creating dataframe with y
  Y <- as.data.frame(y)
  colnames(Y) <- "y"

  #Adjusting an AR(P) model to the whole window W
  M2 <- tryCatch(mdl_fun(Y), error = function(e) NULL)
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

  events <- c(outliers,cp)
  events <- events[order(events)]
  anomalies <- cbind.data.frame(time=data[events,"time"],serie=serie_name,type="anomaly")
  anomalies$type <- as.character(anomalies$type)
  anomalies[anomalies$time %in% data[cp,"time"], "type"] <- "change point"
  names(anomalies) <- c("time","serie","type")

  return(anomalies)
}


#'@export
detect.change_finder <- function(obj, serie) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  data <- data.frame(time = 1:length(serie), serie = serie)

  events <- changepoints_v3(data, har_changeFinder.ARIMA)

  return(events)
  #recolocar o tratamento de na ao final
}


library(dplyr)
data(har_examples)

dataset <- har_examples[[1]]
model <- change_finder(sw=30, alpha=0.5)
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
