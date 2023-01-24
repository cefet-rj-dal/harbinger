#==== evtdet_changeFinder: Function for event detection  ====
# This method is composed by two steps: in the first, is the detection of anomalies. The adjustmentof an incremental learning model to 
# the series occurs. Then, a score is given for every observation occured. This said score is calculated according to its notions of learned model 
# deviance, based on quadratic errors. Higher scores can be understood as anomalies. Then, in the second and final step, the identification of change
# points happens. A new time series is then produced, one which consists of the scores' moving average obtained in the first step. Again, a new 
# incremental learning model is adjusted to the new series and a score given using the learned deviance 
# model. Through this method, the detection of change points is reduced to the task of finding anomalies inside a series.
#
# general input:
#   data: data.frame with one or more variables (time series) where the first variable refers to time.
#   na.action. Default value= "na.omit"
# method specific input:
#   mdl (model). Default value= linreg (linear regression)
#   m (moving average size). Minimum value= 30
#   alpha (alpha value). Default value= 1.5 


evtdet.changeFinder <- function(data,...){
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

  events <- evtdet(data,changepoints_v3,...)

  return(events)
}
