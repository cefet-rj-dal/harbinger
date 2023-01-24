# ==== evtdet.garch_volatility_outlier: Function for event detection  ====
# The models of the GARCH type consist of the estimation of volatility using knowledge from past observations. 
# They are a non-linear time series model that are used to treat the non-linearity of data. They can then be 
# used to study the volatility of time series.
#
# general input:
#   data: data.frame with one or more variables (time series) where the first variable refers to time.
#   na.action. Default value= "na.omit"
# method specific input:
#   alpha: alpha value. Default value= 1.5  
#   spec (specifications):
#      distribution.model: conditional density model. Default value= "norm" (normal distribution)
#      variance.model. Default value for model = "sGARCH"
#                      Default value for garchOrder = (1, 1)
#      mean.model. Default value for include.mean = "TRUE"
#                  Default value:armaOrder = (1, 1)
#                  Default value:include.mean = "TRUE"
#   

evtdet.garch_volatility_outlier <- function(data,...){
  if(is.null(data)) stop("No data was provided for computation",call. = FALSE)

  garch_volatility_outlier <- function(data,spec,value=c("var","sigma"),alpha=1.5,na.action=na.omit,...){
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

    #====== GARCH - volatility ======
    #GARCH fit function
    garch <- function(data,spec,...) rugarch::ugarchfit(spec=spec,data=data,solver="hybrid", ...)

    #Modeling
    g <- garch(serie,spec)@fit

    #Getting instantaneous volatilities
    value <- match.arg(value)
    volatilities <- g[[value]]

    #===== Boxplot analysis of results ======
    outliers.index <- function(data, alpha = 1.5){
      org = length(data)

      index.cp <- NULL
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
    index.cp <- outliers.index(volatilities,alpha)

    if(omit) index.cp <- non_nas[index.cp]

    anomalies <- cbind.data.frame(time=data[index.cp,"time"],serie=serie_name,type="volatility anomaly")
    names(anomalies) <- c("time","serie","type")

    return(anomalies)
  }

  events <- evtdet(data,garch_volatility_outlier,...)

  return(events)
}
