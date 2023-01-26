evtdet.anomalize <- function(data,...){
  if(is.null(data)) stop("No data was provided for computation",call. = FALSE)

  anomalize <- function(data,method_time_decompose="stl",frequency="auto",trend="auto",method_anomalize="iqr",alpha=0.05,max_anoms=0.2,na.action=na.omit,...){
    require(anomalize)
    require(magrittr)
    #browser()
    serie_name <- names(data)[-1]
    names(data) <- c("time","serie")

    e <- tryCatch(data$serie <- na.action(data$serie), error = function(e) NULL)
    if(is.null(e)) data <- na.action(data)

    anomalies <-   tibble::as.tibble(data)

    anomalies <-   anomalize::time_decompose(anomalies,serie, method=method_time_decompose, frequency=frequency, trend=trend)
    anomalies <-   anomalize::anomalize(anomalies, remainder, method=method_anomalize, alpha=alpha, max_anoms=max_anoms)
    anomalies <-   anomalize::time_recompose(anomalies)

    anomalies <- cbind.data.frame(time=anomalies[anomalies$anomaly=="Yes","time"],serie=serie_name,type="anomaly")
    names(anomalies) <- c("time","serie","type")

    return(anomalies)
  }

  events <- evtdet(data,anomalize,...)

  return(events)
}

optim.evtdet.anomalize <- function(test,par_options=expand.grid(method_time_decompose=c("stl","twitter"),
                                                                method_anomalize=c("iqr","gesd")),...){
  eval <- data.frame()
  events_list <- NULL
  for(par in 1:nrow(par_options)){

    events <- tryCatch(evtdet.anomalize(test,
                                        method_time_decompose=par_options[par,"method_time_decompose"],
                                        method_anomalize=par_options[par,"method_anomalize"],...),
                       error = function(e) NULL)

    eval_par <- tryCatch(evaluate(events, reference, metric="F1"),
                         error = function(e) NA)

    if(!is.null(events)) events_list[[par]] <- events
    else events_list[[par]] <- NA

    eval <- rbind(eval,cbind(par_options[par,],F1=eval_par))
  }

  events <- events_list[[which.max(eval$F1)]]
  par <- par_options[which.max(eval$F1),]
  rank <- eval

  return(list(par=par,events=events,rank=rank))
}


evtdet.eventdetect <- function(data,...){
  if(is.null(data)) stop("No data was provided for computation",call. = FALSE)

  eventdetect <- function(data,windowSize=200,nIterationsRefit=150,
                          dataPrepators="ImputeTSInterpolation",buildModelAlgo="ForecastBats",
                          postProcessors="bedAlgo",postProcessorControl = list(nStandardDeviationsEventThreshhold = 5),...){

    require(EventDetectR)

    #browser()
    names(data) <- c("time",names(data)[-1])
    series_names <- ifelse(length(names(data)[-1])>1,"all",names(data)[-1])

    anomalies <-
      detectEvents(subset(data, select=-c(time)),windowSize=windowSize,nIterationsRefit=nIterationsRefit,
                   dataPrepators=dataPrepators,buildModelAlgo=buildModelAlgo,
                   postProcessors=postProcessors,postProcessorControl=postProcessorControl,...)$classification

    anomalies <- cbind.data.frame(time=data[anomalies$Event==TRUE,"time"],serie=series_names,type="anomaly")
    #anomalies$time <- as.POSIXct(as.numeric(anomalies$time),origin="1960-01-01")
    names(anomalies) <- c("time","serie","type")

    return(anomalies)
  }

  events <- evtdet(data,eventdetect,...)

  return(events)
}


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

optim.evtdet.seminalChangePoint <- function(test,par_options=expand.grid(w=seq(0.01,0.1,0.02)*nrow(test)),...){
  eval <- data.frame()
  events_list <- NULL
  for(par in 1:nrow(par_options)){

    events <- tryCatch(evtdet.seminalChangePoint(test,
                                                 w=par_options[par,"w"],...),
                       error = function(e) NULL)

    eval_par <- tryCatch(evaluate(events, reference, metric="F1"),
                         error = function(e) NA)

    if(!is.null(events)) events_list[[par]] <- events
    else events_list[[par]] <- NA

    eval <- rbind(eval,cbind(par_options[par,],F1=eval_par))
  }

  events <- events_list[[which.max(eval$F1)]]
  par <- par_options[which.max(eval$F1),]
  rank <- eval

  return(list(par=par,events=events,rank=rank))
}

#====== Auxiliary Model definitions ======
changeFinder.ARIMA <- function(data) forecast::auto.arima(data)
changeFinder.AR <- function(data,p) forecast::Arima(data, order = c(p, 0, 0), seasonal = c(0, 0, 0))
changeFinder.garch <- function(data,spec,...) rugarch::ugarchfit(spec=spec,data=data,solver="hybrid", ...)@fit
changeFinder.ets <- function(data) forecast::ets(ts(data))
changeFinder.linreg <- function(data) {
  data <- as.data.frame(data)
  colnames(data) <- "x"
  data$t <- 1:nrow(data)
  lm(x~t, data)
}

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




optim.evtdet.changeFinder <- function(test,par_options=expand.grid(mdl_fun=c(ARIMA = changeFinder.ARIMA,
                                                                             AR = changeFinder.AR,
                                                                             ets = changeFinder.ets,
                                                                             linreg = changeFinder.linreg),
                                                                   m=seq(0.01,0.1,0.02)*nrow(test)),...){
  eval <- data.frame()
  events_list <- NULL

  #browser()
  for(par in 1:nrow(par_options)){

    events <- tryCatch(evtdet.changeFinder(test,
                                           mdl_fun=par_options[[par,"mdl_fun"]],
                                           m=par_options[par,"m"],...),
                       error = function(e) NULL)

    eval_par <- tryCatch(evaluate(events, reference, metric="F1"),
                         error = function(e) NA)

    if(!is.null(events)) events_list[[par]] <- events
    else events_list[[par]] <- NA

    eval <- rbind(eval,cbind(par_options[par,],F1=eval_par))
  }

  events <- events_list[[which.max(eval$F1)]]
  par <- par_options[which.max(eval$F1),]
  rank <- eval

  return(list(par=par,events=events,rank=rank))
}


evtdet.otsad <- function(data,...){
  if(is.null(data)) stop("No data was provided for computation",call. = FALSE)

  otsad <- function(data,method=c("CpPewma","ContextualAnomalyDetector","CpKnnCad",
                                  "CpSdEwma","CpTsSdEwma","IpPewma","IpKnnCad"),na.action=na.omit,...){
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

    method <- match.arg(method)
    require(otsad)

    func <-
      switch(method,
             "CpPewma" = function(data, ...) otsad::CpPewma(data,...)$is.anomaly,
             "ContextualAnomalyDetector" = function(data, reference, ...) otsad::ContextualAnomalyDetector(data,...)$is.anomaly,
             "CpKnnCad" = function(data, ...) otsad::CpKnnCad(data,...)$is.anomaly,
             "CpSdEwma" = function(data, ...) otsad::CpSdEwma(data,...)$is.anomaly,
             "CpTsSdEwma" = function(data, ...) otsad::CpTsSdEwma(data,...)$is.anomaly,
             "IpPewma" = function(data, ...) otsad::IpPewma(data,...)$is.anomaly,
             "IpKnnCad" = function(data, ...) otsad::IpKnnCad(data,...)$is.anomaly
      )

    index.outlier <- which(as.logical(func(data=serie,...)))

    if(omit) index.outlier <- non_nas[index.outlier]

    anomalies <- cbind.data.frame(time=data[index.outlier,"time"],serie=serie_name,type="anomaly")
    names(anomalies) <- c("time","serie","type")

    return(anomalies)
  }

  events <- evtdet(data,otsad,...)

  return(events)
}


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

