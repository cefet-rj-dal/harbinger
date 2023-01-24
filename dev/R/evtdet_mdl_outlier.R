#==== evdet_mdl_outlier: Function for event detection ====
# In this outlier (Model Outliers method), the model (mdl) is used as a parameter.
# The value of this parameter is a linear regression. In general, this method helps to
# find divergence points using outliers which can be treated as anomalies.
# input:
#   data: data.frame with one or more variables (time series) where the first variable refers to time.
#   mdl: model.
#   alpha: alpha value.


evtdet.mdl_outlier <- function(data,...){
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

  events <- evtdet(data,mdl_outlier,...)

  return(events)
}
