#'@title Change Finder using ARIMA
#'@description Change-point detection is related to event/trend change detection. Change Finder ARIMA detects change points based on deviations relative to ARIMA model <doi:10.1109/TKDE.2006.1599387>.
#'It wraps the ARIMA model presented in the forecast library.
#'@param sw_size Sliding window size
#'@return `hcp_cf_arima` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(examples_changepoints)
#'
#'#Using simple example
#'dataset <- examples_changepoints$simple
#'head(dataset)
#'
#'# setting up change point method
#'model <- hcp_cf_arima()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
# making detection using hanr_ml
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'
#'@export
hcp_cf_arima <- function(sw_size = NULL) {
  obj <- harbinger()
  obj$sw_size <- sw_size

  class(obj) <- append("hcp_cf_arima", class(obj))
  return(obj)
}

#'@importFrom forecast auto.arima
#'@importFrom stats residuals
#'@importFrom stats na.omit
#'@exportS3Method fit hcp_cf_arima
fit.hcp_cf_arima <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  serie <- stats::na.omit(serie)

  obj$model <- forecast::auto.arima(serie, allowdrift = TRUE, allowmean = TRUE)
  order <- obj$model$arma[c(1, 6, 2, 3, 7, 4, 5)]
  obj$p <- order[1]
  obj$d <- order[2]
  obj$q <- order[3]
  obj$drift <- (NCOL(obj$model$xreg) == 1) && is.element("drift", names(obj$model$coef))
  params <- list(p = obj$p, d = obj$d, q = obj$q, drift = obj$drift)
  attr(obj, "params") <- params

  if (is.null(obj$sw_size))
    obj$sw_size <- max(obj$p, obj$d+1, obj$q)

  return(obj)
}


#'@importFrom stats na.omit
#'@importFrom stats residuals
#'@importFrom forecast auto.arima
#'@exportS3Method detect hcp_cf_arima
detect.hcp_cf_arima <- function(obj, serie, ...) {
  obj <- obj$har_store_refs(obj, serie)

  #Adjusting a model to the entire series
  model <- tryCatch(
    {
      forecast::Arima(obj$serie, order=c(obj$p, obj$d, obj$q), include.drift = obj$drift)
    },
    error = function(cond) {
      forecast::auto.arima(obj$serie, allowdrift = TRUE, allowmean = TRUE)
    }
  )

  #Adjustment error on the entire series
  res <- stats::residuals(model)

  res <- obj$har_distance(res)
  anomalies <- obj$har_outliers(res)

  anomalies <- obj$har_outliers_check(anomalies, res)

  anomalies[1:obj$sw_size] <- FALSE

  y <- mas(res, obj$sw_size)

  #Adjusting to the entire series
  M2 <- forecast::auto.arima(y)

  #Adjustment error on the whole window
  u <- obj$har_distance(stats::residuals(M2))

  u <- mas(u, obj$sw_size)
  cp <- obj$har_outliers(u)
  cp <- obj$har_outliers_check(cp, u)
  cp[1:obj$sw_size] <- FALSE
  cp <- c(rep(FALSE, length(res)-length(u)), cp)

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, change_points = cp, res = res)

  return(detection)
}


