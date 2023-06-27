#'@title Change Finder using ARIMA
#'@description Change Finder using ARIMA
#'@param w Sliding window size
#'@param alpha Threshold for outliers
#'@return hcp_cf_arima object
#'@examples detector <- harbinger()
#'@export
hcp_cf_arima <- function(w = NULL, alpha = 1.5) {
  obj <- harbinger()
  obj$w <- w
  obj$alpha <- alpha
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
  s <- stats::residuals(M1)^2
  outliers <- har_outliers_idx(s, alpha = obj$alpha)
  group_outliers <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
  outliers <- rep(FALSE, length(s))
  for (g in group_outliers) {
    if (length(g) > 0) {
      i <- min(g)
      outliers[i] <- TRUE
    }
  }
  outliers[1:w] <- FALSE

  y <- TSPred::mas(s, w)

  #Adjusting to the entire series
  M2 <- forecast::auto.arima(y)

  #Adjustment error on the whole window
  u <- stats::residuals(M2)^2

  u <- TSPred::mas(u, w)
  cp <- har_outliers_idx(u)
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
  detection$type[cp] <- "hcp_scp"

  return(detection)
}


