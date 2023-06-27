#'@title Anomaly detector using ARIMA
#'@description Anomaly detector using ARIMA
#'@param w Window size for warm-up ARIMA
#'@param alpha Threshold for outliers
#'@return hanr_arima object
#'@examples detector <- harbinger()
#'@export
hanr_arima <- function(w = NULL, alpha = 1.5) {
  obj <- harbinger()
  obj$w <- w
  obj$alpha <- alpha
  class(obj) <- append("hanr_arima", class(obj))
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
  model <- forecast::auto.arima(serie)
  order <- model$arma[c(1, 6, 2, 3, 7, 4, 5)]
  w <- obj$w
  if (is.null(w))
    w <- max(order[1], order[2]+1, order[3])

  #Adjustment error on the entire series
  s <- stats::residuals(model)^2
  outliers <- har_outliers_idx(s, obj$alpha)
  group_outliers <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
  outliers <- rep(FALSE, length(s))
  for (g in group_outliers) {
    if (length(g) > 0) {
      i <- min(g)
      outliers[i] <- TRUE
    }
  }
  outliers[1:w] <- FALSE
  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"

  return(detection)
}



