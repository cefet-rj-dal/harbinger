#==== evtdet: Function for event detection ====
# input:
#   data: data.frame with one or more variables (time series) where the first variable refers to time.
#   func: function for event detection having 'data' as input and a data.frame with three variables: 
#         time (events time/indexes), serie (corresponding time serie) and type (event type) as output.
#   ...: list of parameters for 'func'
#
# output:
#   data.frame with three variables: time (events time/indexes), serie (corresponding time serie), type (event type).
evtdet <- function(data,func,...){
  if(is.null(data)) stop("No data was provided for computation",call. = FALSE)
  
  events <- do.call(func,c(list(data),list(...)))
  
  return(events)
}


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


evtdet.seminalChangePoint2 <- function(data,...){
  if(is.null(data)) stop("No data was provided for computation",call. = FALSE)
  
  changepoints_v2 <- function(data,mdl,w=100,na.action=na.omit,...){
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
    analyze_window <- function(data,mdl_fun,...) {
      error_func <- function(x) mean(x^2)
      #Window W = {x_i:i=u,u+1,...,t} = {x_u, x_u+1, ..., x_t}, Where t=u+w-1 and |W| = w
      #Creating dataframe with W
      W <- as.data.frame(t(data))
      colnames(W) <- "x"
      
      #Adjusting an AR(P) model to the whole window W
      mdl <- tryCatch(mdl_fun(W,...), error = function(e) NULL)
      if(is.null(mdl)) mdl <- tryCatch(mdl_fun(W), error = function(e) NULL)
      if(is.null(mdl)) return(NULL)
      
      #Adjustment error on the whole window
      err <- error_func(residuals(mdl))
      
      #for each candidate event point x_v  (v = u+k-1,...,t-k ?)
      u <- 1
      t <- length(data)
      err_ad <- NULL
      
      for( v in u:t ){

        #Adjusting an AR(P) model to {x_u,...,x_v}
        #Data before the candidate event point
        W_a <- W[u:(v-1),]
        mdl_a <- tryCatch(mdl_fun(W_a), error = function(e) NULL)
        if(is.null(mdl_a)) mdl_a <- tryCatch(mdl_fun(W_a,k), error = function(e) NULL)
        
        #Adjusting an AR(P) model to {x_(v+1),...,x_t}
        #Data after the event point
        W_d <- W[(v+1):t,]
        mdl_d <- tryCatch(mdl_fun(W_d), error = function(e) NULL)
        if(is.null(mdl_d)) mdl_d <- tryCatch(mdl_fun(W_d,k), error = function(e) NULL)
        
        #Combined adjustment error on the window data before and after the event
        e_ad <- ifelse(is.null(mdl_a) | is.null(mdl_d), NA, error_func(c(residuals(mdl_a),residuals(mdl_d))))
        
        #return 1-error on whole window; 2-error on window parts (before & after); 3-error difference
        err_ad <- rbind(err_ad, data.frame(mdl=err, mdl_ad=e_ad, mdl_dif=err-e_ad))
      }
      
      return(err_ad)
    }
    
    #===== Boxplot analysis of results ======
    outliers.index <- function(data, alpha = 1.5){
      org = length(na.omit(data))
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
    
    
    #===== Analyzing all data windows ====== 
    outliers <- NULL
    for(i in 1:nrow(serie)){
      win_error <- analyze_window(serie[i,],mdl,...)
      
      out <- outliers.index(win_error$mdl_dif) + (i-1)
      
      outliers <- c(outliers, out)
    }
    
    out_freq <- as.data.frame(table(outliers))
    
    detection_freq <- cbind.data.frame(outliers=1:nrow(data))
    detection_freq <- merge(detection_freq,out_freq,all.x=TRUE,all.y=TRUE)
    detection_freq[is.na(detection_freq$Freq), "Freq"] <- 0
    
    #Returns index of observations with outlier detection frequences
    index.cp <- outliers.index(detection_freq$Freq)
    index.cp <- detection_freq$outliers[index.cp]
    
    if(omit) index.cp <- non_nas[index.cp]
    
    anomalies <- cbind.data.frame(time=data[index.cp,"time"],serie=serie_name,type="change point")
    names(anomalies) <- c("time","serie","type")
    
    return(anomalies)
  }
  
  events <- evtdet(data,changepoints_v2,...)
  
  return(events)
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

optim.evtdet.changeFinder <- function(test,par_options=expand.grid(mdl_fun=c(ARIMA = function(data) forecast::auto.arima(data),
                                                                                AR = function(data,p) forecast::Arima(data, order = c(p, 0, 0), seasonal = c(0, 0, 0)),
                                                                                ets = function(data) forecast::ets(ts(data)),
                                                                                linreg = function(data) {
                                                                                  data <- as.data.frame(data)
                                                                                  colnames(data) <- "x"
                                                                                  data$t <- 1:nrow(data)
                                                                                  lm(x~t, data)
                                                                                }),
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


evtdet.an_outliers <- function(data,...){
  if(is.null(data)) stop("No data was provided for computation",call. = FALSE)
  
  an_outliers <- function(data,w=100,alpha=1.5,na.action=na.omit,...){
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
    ts.sw <- function(x,k){
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
    
    #===== Boxplot analysis of results ======
    outliers.boxplot <- function(data, alpha = 1.5){
      org = nrow(data)
      cond <- rep(FALSE, org)
      if (org >= 30) {
        i = ncol(data)
        q = quantile(data[,i], na.rm=TRUE)
        IQR = q[4] - q[2]
        lq1 = q[2] - alpha*IQR
        hq3 = q[4] + alpha*IQR
        cond = data[,i] < lq1 | data[,i] > hq3
      }
      return (cond)
    }
    
    sx <- data.frame(ts.sw(serie, w))
    ma <- apply(sx, 1, mean)
    sxd <- sx - ma
    iF <- outliers.boxplot(sxd,alpha)
    
    sx <- data.frame(ts.sw(rev(serie), w))
    ma <- apply(sx, 1, mean)
    sxd <- sx - ma
    iB <- outliers.boxplot(sxd,alpha)
    iB <- rev(iB)
    
    i <- iF | iB
    i[1:w] <- iB[1:w]
    i[(length(serie)-w+1):length(serie)] <- iF[(length(serie)-w+1):length(serie)]
    
    index.outlier <- which(i)
    
    if(omit) index.outlier <- non_nas[index.outlier]
    
    anomalies <- cbind.data.frame(time=data[index.outlier,"time"],serie=serie_name,type="anomaly")
    names(anomalies) <- c("time","serie","type")
    
    return(anomalies)
  }
  
  events <- evtdet(data,an_outliers,...)
  
  return(events)
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
    g <- garch(test[,2],spec)@fit
    
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


evtdet.outliers <- function(data,...){
  
  outliers <- function(data,alpha=1.5){
    if(is.null(data)) stop("No data was provided for computation",call. = FALSE)
    
    #browser()
    serie_name <- names(data)[-1]
    names(data) <- c("time","serie")
    
    serie <- data$serie
    
    #===== Boxplot analysis of results ======
    outliers.index <- function(data, alpha = 1.5){
      org = length(data)
      
      if (org >= 30) {
        q = quantile(data)
        
        IQR = q[4] - q[2]
        lq1 = q[2] - alpha*IQR
        hq3 = q[4] + alpha*IQR
        cond = data < lq1 | data > hq3
        index.out = which(cond)#data[cond,]
      }
      return (index.out)
    }
    
    #Returns index of windows with outlier error differences
    index.out <- outliers.index(serie,alpha)
    
    anomalies <- cbind.data.frame(time=data[index.out,"time"],serie=serie_name,type="anomaly")
    names(anomalies) <- c("time","serie","type")
    
    return(anomalies)
  }
  
  events <- evtdet(data,outliers,...)
  
  return(events)
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

#==== evaluate: Function for evaluating quality of event detection ====
# input:
#   events: output from 'evtdet' function regarding a particular times series.
#   reference: data.frame of the same length as the time series with two variables: time, event (boolean indicating true events)
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


#==== plot: Function for plotting event detection ====
# input:
#   data: data.frame with one or more variables (time series) where the first variable refers to time.
#   events: output from 'evtdet' function regarding a particular times series.
#   reference: data.frame of the same length as the time series with two variables: time, event (boolean indicating true events)
# output:
#   plot.
evtplot <- function(data, events, reference=NULL, mark.cp=FALSE, ylim=NULL,...){
  
  serie_name <- names(data)[-1]
  names(data) <- c("time","serie")
  
  #Time of detected events
  events_true <- events
  #Time of detected events of type change points
  events_cp <- as.data.frame(events[events$type=="change point",])
  #Time of detected events of type anomaly
  events_a <- as.data.frame(events[events$type=="anomaly",])
  #Time of detected events of type volatility anomaly
  events_va <- as.data.frame(events[events$type=="volatility anomaly",])
  
  #Data observation of detected events
  data_events_true <- as.data.frame(data[data$time %in% events$time,])

  #If true events are identified
  if(!is.null(reference)) {
    names(reference) <- c("time","event")
    
    #Time of identified true events
    ref_true <- as.data.frame(reference[reference$event==TRUE,])
    #Time of identified true events that were correctly detected
    ref_events_true <- as.data.frame(ref_true[ref_true$time %in% events$time,])
    
    #Data observation of identified true events
    data_ref_true <- as.data.frame(data[data$time %in% ref_true$time,])
    #Data observation of identified true events that were correctly detected
    data_ref_events_true <- as.data.frame(data[data$time %in% ref_events_true$time,])
  }
 
  min_data <- min(data$serie)
  max_data <- max(data$serie)
  if(!is.null(ylim)){
    min_data <- ifelse(!is.na(ylim[1]), ylim[1], min(data$serie))
    max_data <- ifelse(!is.na(ylim[2]), ylim[2], max(data$serie))
  }
  
  top_1 <- max_data+(max_data-min_data)*0.02
  top_2 <- max_data+(max_data-min_data)*0.05
  bottom_1 <- min_data-(max_data-min_data)*0.02
  bottom_2 <- min_data-(max_data-min_data)*0.05
  
  
  require(ggplot2)
  #Plotting time series
  plot <- ggplot(data, aes(x=time, y=serie)) +
    geom_line()+
    xlab("Time")+
    ylab("")+#ylab(serie_name)+
    theme_bw()
  
  #Setting y limits if provided
  if(!is.null(ylim)) plot <- plot + ggplot2::ylim(bottom_2,top_2)
  #browser()
  #Plotting top bar
  tryCatch(if(nrow(ref_true)>0)
    plot <- plot + geom_segment(aes(x=time, y=top_1, xend=time, yend=top_2),data=ref_true, col="blue"),
           error = function(e) NULL)
  tryCatch(if(nrow(events_true)>0)
    plot <- plot + geom_segment(aes(x=time, y=top_1, xend=time, yend=top_2),data=events_true, col="red"),
           error = function(e) NULL)
  tryCatch(if(nrow(ref_events_true)>0)
    plot <- plot + geom_segment(aes(x=time, y=top_1, xend=time, yend=top_2),data=ref_events_true, col="green"),
           error = function(e) NULL)
  plot <- plot + geom_hline(yintercept = top_1, col="black", size = 0.5)
  plot <- plot + geom_hline(yintercept = top_2, col="black", size = 0.5)
  
  #Plotting bottom bar
  tryCatch(if(nrow(ref_true)>0)
    plot <- plot + geom_segment(aes(x=time, y=bottom_1, xend=time, yend=bottom_2),data=ref_true, col="blue"),
           error = function(e) NULL)
  tryCatch(if(nrow(events_true)>0)
    plot <- plot + geom_segment(aes(x=time, y=bottom_1, xend=time, yend=bottom_2),data=events_true, col="red"),
           error = function(e) NULL)
  tryCatch(if(nrow(ref_events_true)>0)
    plot <- plot + geom_segment(aes(x=time, y=bottom_1, xend=time, yend=bottom_2),data=ref_events_true, col="green"),
           error = function(e) NULL)
  plot <- plot + geom_hline(yintercept = bottom_1, col="black", size = 0.5)
  plot <- plot + geom_hline(yintercept = bottom_2, col="black", size = 0.5)
  
  #Plotting relevant event points of type anomaly
  tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=subset(data_ref_true,time %in% events_a$time), col="blue", size = 1),
           error = function(e) NULL)
  tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=subset(data_events_true,time %in% events_a$time), col="red", size = 1),
           error = function(e) NULL)
  tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=subset(data_ref_events_true,time %in% events_a$time), col="green", size = 1),
           error = function(e) NULL)
  
  #Plotting relevant event points of type volatility anomaly
  tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=subset(data_ref_true,time %in% events_va$time), shape = 17, col="blue", size = 2),
           error = function(e) NULL)
  tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=subset(data_events_true,time %in% events_va$time), shape = 17, col="red", size = 2),
           error = function(e) NULL)
  tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=subset(data_ref_events_true,time %in% events_va$time), shape = 17, col="green", size = 2),
           error = function(e) NULL)
  
  #Plotting relevant event points
  if(nrow(events_a)==0 & nrow(events_va)==0) {
    tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=data_ref_true, col="blue", size = 1),
             error = function(e) NULL)
    tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=data_events_true, col="red", size = 1),
             error = function(e) NULL)
    tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=data_ref_events_true, col="green", size = 1),
             error = function(e) NULL)
  }
  
  #Plotting change points
  if(mark.cp & nrow(events_cp)>0) 
    tryCatch(plot <- plot + geom_segment(aes(x=time, y=top_1, xend=time, yend=bottom_1),data=events_cp, col="grey", size = 1, linetype="dashed"),
             error = function(e) NULL)
  
  
  return(plot)
}