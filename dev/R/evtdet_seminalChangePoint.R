# ==== evtdet_seminalChangePoint: Function for event detection  ====
# For any given point in time, it applies adjustments of models to segments of data around 
# this given point. After that, the existence of a change point is determined depending on the 
# quantity of adjustment errors that occur throughout the region. The areas with 
# most errors are compared with the ones where this rate is the lowest.
#
# input:
#   data: data.frame with one or more variables (time series) where the first variable refers to time.
#   w (window size). Default value= 100 
#   alpha: alpha value. Default value= 1.5
#   na.action. Default value= "na.omit"

evtdet.seminalChangePoint <- function(data,...){
  if(is.null(data)) stop("No data was provided for computation",call. = FALSE)

  changepoints_v1 <- function(data,w=100,na.action=na.omit,...){
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

    #===== Creating sliding windows ======
    ts.sw <- function(x,k)
    {
      ts.lagPad <- function(x, k)
      {
        c(rep(NA, k), x)[1 : length(x)]
      }

      n <- length(x)-k+1
      sw <- NULL
      for(c in (k-1):0){
        t  <- ts.lagPad(x,c)
        sw <- cbind(sw,t,deparse.level = 0)
      }
      col <- paste("t",c((k-1):0), sep="")
      rownames(sw) <- NULL
      colnames(sw) <- col
      return (sw)
    }

    serie <- data.frame(ts.sw(serie, w))
    serie <- serie[complete.cases(serie), ]

    #===== Function to analyze each data window ======
    analyze_window <- function(data) {
      #browser()
      n <- length(data)
      y <- as.data.frame(data)#t(data)
      colnames(y) <- "y"
      y$t <- 1:n

      mdl <- lm(y~t, y)
      err <- mean(mdl$residuals^2)

      y_a <- y[1:floor(n/2),]
      mdl_a <- lm(y~t, y_a)
      y_d <- y[ceiling(n/2+1):n,]
      mdl_d <- lm(y~t, y_d)

      err_ad <- mean(c(mdl_a$residuals,mdl_d$residuals)^2)

      #return 1-error on whole window; 2-error on window halves; 3-error difference
      return(data.frame(mdl=err, mdl_ad=err_ad, mdl_dif=err-err_ad))
    }

    #===== Analyzing all data windows ======
    errors <- do.call(rbind,apply(serie,1,analyze_window))

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
    index.cp <- outliers.index(errors$mdl_dif)
    index.cp <- index.cp+floor(w/2)

    if(omit) index.cp <- non_nas[index.cp]

    anomalies <- cbind.data.frame(time=data[index.cp,"time"],serie=serie_name,type="change point")
    names(anomalies) <- c("time","serie","type")

    return(anomalies)
  }

  events <- evtdet(data,changepoints_v1,...)

  return(events)
}
