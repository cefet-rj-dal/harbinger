#'@title Change Finder using ETS
#'@description Change-point detection is related to event/trend change detection. Change Finder ETS detects change points based on deviations relative to trend component (T), a seasonal component (S), and an error term (E) model <doi:10.1109/TKDE.2006.1599387>.
#'It wraps the ETS model presented in the forecast library.
#'@param sw_size Sliding window size
#'@return `hcp_cf_ets` object
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
#'model <- hcp_cf_ets()
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
hcp_cf_ets <- function(sw_size = 7) {
  obj <- harbinger()

  obj$sw_size <- sw_size
  class(obj) <- append("hcp_cf_ets", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom stats ts
#'@importFrom stats residuals
#'@importFrom forecast ets
#'@importFrom TSPred mas
#'@export
detect.hcp_cf_ets <- function(obj, serie, ...) {
  obj <- obj$har_store_refs(obj, serie)

  #Adjusting a model to the entire series
  model <- forecast::ets(stats::ts(obj$serie))

  res <- stats::residuals(model)

  res <- obj$har_residuals(res)
  anomalies <- obj$har_outliers_idx(res)
  anomalies <- obj$har_outliers_group(anomalies, length(res))

  anomalies[1:obj$sw_size] <- FALSE

  y <- TSPred::mas(res, obj$sw_size)

  #Adjusting to the entire series
  M2 <- forecast::ets(ts(y))

  #Adjustment error on the whole window
  u <- obj$har_residuals(stats::residuals(M2))

  u <- TSPred::mas(u, obj$sw_size)
  cp <- obj$har_outliers_idx(u)
  cp <- obj$har_outliers_group(cp, length(u))
  cp[1:obj$sw_size] <- FALSE
  cp <- c(rep(FALSE, length(res)-length(u)), cp)

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, change_points = cp)

  return(detection)
}

