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
