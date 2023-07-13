#'@title Anomaly detector using ARIMA
#'@description Anomaly detector using ARIMA
#'@param w Window size for warm-up ARIMA
#'@return hanr_arima object
#'@examples detector <- harbinger()
#'@export
hanr_arima <- function(w = NULL) {
  obj <- harbinger()
  obj$w <- w

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

  if (is.null(obj$w))
    obj$w <- max(obj$p, obj$d+1, obj$q)

  return(obj)
}


#'@importFrom forecast auto.arima
#'@importFrom stats residuals
#'@importFrom stats na.omit
#'@export
detect.hanr_arima <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  n <- length(serie)
  non_na <- which(!is.na(serie))
  serie <- stats::na.omit(serie)

  #Adjusting a model to the entire series
  model <- tryCatch(
    {
      forecast::Arima(serie, order=c(obj$p, obj$d, obj$q), include.drift = obj$drift)
    },
    error = function(cond) {
      forecast::auto.arima(serie, allowdrift = TRUE, allowmean = TRUE)
    }
  )

  #Adjustment error on the entire series
  s <- obj$har_residuals(stats::residuals(model))
  outliers <- obj$har_outliers_idx(s)
  outliers <- obj$har_outliers_group(outliers, length(s))

  outliers[1:obj$w] <- FALSE

  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"

  return(detection)
}



