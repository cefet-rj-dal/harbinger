#====== Auxiliary Model definitions ======
changeFinder.ARIMA <- function(data) forecast::auto.arima(data)
changeFinder.garch <- function(data,spec,...) rugarch::ugarchfit(spec=spec,data=data,solver="hybrid", ...)@fit
changeFinder.ets <- function(data) forecast::ets(ts(data))
changeFinder.linreg <- function(data) {
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
  obj$method <- changeFinder.ARIMA
  class(obj) <- append("change_finder", class(obj))
  return(obj)
}



#'@export
detect.change_finder <- function(obj, serie, ) {

  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  non_na <- which(!is.na(serie))

  data <- na.omit(serie)

  #Adjusting a model to the whole window W
  M1 <- obj$method(data)

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


  inon_na <- index.cp

  i <- rep(NA, length(serie))
  i[non_na] <- inon_na

  detection <- data.frame(idx=1:length(serie), event = i, type="")
  detection$type[i] <- "change_finder"

  return(detection)
}
