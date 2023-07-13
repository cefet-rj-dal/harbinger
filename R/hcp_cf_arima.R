#'@title Change Finder using ARIMA
#'@description Change Finder using ARIMA
#'@param w Sliding window size
#'@return hcp_cf_arima object
#'@examples detector <- harbinger()
#'@export
hcp_cf_arima <- function(w = NULL) {
  obj <- harbinger()
  obj$w <- w

  class(obj) <- append("hcp_cf_arima", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom stats residuals
#'@importFrom TSPred mas
#'@importFrom forecast auto.arima
#'@export
detect.hcp_cf_arima <- function(obj, serie, ...) {
  n <- length(serie)
  non_na <- which(!is.na(serie))

  serie <- stats::na.omit(serie)

  #Adjusting a model to the entire series
  M1 <- forecast::auto.arima(serie)
  order <- M1$arma[c(1, 6, 2, 3, 7, 4, 5)]
  w <- obj$w
  if (is.null(w))
    w <- max(order[1], order[2]+1, order[3])

  #Adjustment error on the entire series
  s <- obj$har_residuals(stats::residuals(M1))
  outliers <- obj$har_outliers_idx(s)
  outliers <- obj$har_outliers_group(outliers, length(s))

  outliers[1:w] <- FALSE

  y <- TSPred::mas(s, w)

  #Adjusting to the entire series
  M2 <- forecast::auto.arima(y)

  #Adjustment error on the whole window
  u <- obj$har_residuals(stats::residuals(M2))

  u <- TSPred::mas(u, w)
  cp <- obj$har_outliers_idx(u)
  group_cp <- split(cp, cumsum(c(1, diff(cp) != 1)))
  cp <- rep(FALSE, length(u))
  for (g in group_cp) {
    if (length(g) > 0) {
      i <- min(g)
      cp[i] <- TRUE
    }
  }
  cp[1:w] <- FALSE
  cp <- c(rep(FALSE, length(s)-length(u)), cp)

  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  i_cp <- rep(NA, n)
  i_cp[non_na] <- cp

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"
  detection$event[cp] <- TRUE
  detection$type[cp] <- "changepoint"

  return(detection)
}

