#'@title Change Finder using ETS
#'@description Change-point detection is related to event/trend change detection. Change Finder ETS detects change points based on deviations relative to trend component (T), a seasonal component (S), and an error term (E) model <doi:10.1109/TKDE.2006.1599387>.
#'It wraps the ETS model presented in the forecast library.
#'@param sw_size Sliding window size
#'@return `hcp_cf_ets` object
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
#'@exportS3Method detect hcp_cf_ets
detect.hcp_cf_ets <- function(obj, serie, ...) {
  obj <- obj$har_store_refs(obj, serie)

  #Adjusting a model to the entire series
  model <- forecast::ets(stats::ts(obj$serie))

  res <- stats::residuals(model)

  res <- obj$har_distance(res)
  anomalies <- obj$har_outliers(res)

  anomalies <- obj$har_outliers_check(anomalies, res)

  anomalies[1:obj$sw_size] <- FALSE

  y <- mas(res, obj$sw_size)

  #Adjusting to the entire series
  M2 <- forecast::ets(ts(y))

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

