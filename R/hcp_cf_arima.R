#'@title Change Finder using ARIMA
#'@description Change-point detection is related to event/trend change detection. Change Finder ARIMA detects change points based on deviations relative to ARIMA model <doi:10.1109/TKDE.2006.1599387>.
#'It wraps the ARIMA model presented in the forecast library.
#'@param sw_size Sliding window size
#'@return `hcp_cf_arima` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(har_examples)
#'
#'#Using example 6
#'dataset <- har_examples$example6
#'head(dataset)
#'
#'# setting up time series regression model
#'model <- hcp_cf_arima()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
# making detection using hanr_ml
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection |> dplyr::filter(event==TRUE))
#'
#'@export
hcp_cf_arima <- function(sw_size = NULL) {
  obj <- harbinger()
  obj$sw_size <- sw_size

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
  sw_size <- obj$sw_size
  if (is.null(sw_size))
    sw_size <- max(order[1], order[2]+1, order[3])

  #Adjustment error on the entire series
  s <- obj$har_residuals(stats::residuals(M1))
  outliers <- obj$har_outliers_idx(s)
  outliers <- obj$har_outliers_group(outliers, length(s))

  outliers[1:sw_size] <- FALSE

  y <- TSPred::mas(s, sw_size)

  #Adjusting to the entire series
  M2 <- forecast::auto.arima(y)

  #Adjustment error on the whole window
  u <- obj$har_residuals(stats::residuals(M2))

  u <- TSPred::mas(u, sw_size)
  cp <- obj$har_outliers_idx(u)
  group_cp <- split(cp, cumsum(c(1, diff(cp) != 1)))
  cp <- rep(FALSE, length(u))
  for (g in group_cp) {
    if (length(g) > 0) {
      i <- min(g)
      cp[i] <- TRUE
    }
  }
  cp[1:sw_size] <- FALSE
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


