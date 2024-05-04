#'@title Anomaly detector using ARIMA.
#'@description Anomaly detection using ARIMA
#'The ARIMA model adjusts to the time series. Observations distant from the model are labeled as anomalies.
#'It wraps the ARIMA model presented in the forecast library.
#'@return `hanr_arima` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(examples_anomalies)
#'
#'#Using simple example
#'dataset <- examples_anomalies$simple
#'head(dataset)
#'
#'# setting up time series regression model
#'model <- hanr_arima()
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
hanr_arima <- function() {
  obj <- harbinger()
  obj$sw_size <- NULL

  class(obj) <- append("hanr_arima", class(obj))
  return(obj)
}


#'@importFrom forecast auto.arima
#'@importFrom stats residuals
#'@importFrom stats na.omit
#'@export
fit.hanr_arima <- function(obj, serie, ...) {
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


#'@importFrom forecast auto.arima
#'@importFrom stats residuals
#'@importFrom stats na.omit
#'@export
detect.hanr_arima <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

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

  res <- stats::residuals(model)

  res <- obj$har_residuals(res)
  anomalies <- obj$har_outliers_idx(res)
  anomalies <- obj$har_outliers_group(anomalies, length(res))

  anomalies[1:obj$sw_size] <- FALSE

  detection <- obj$har_restore_refs(obj, anomalies = anomalies)

  return(detection)
}
