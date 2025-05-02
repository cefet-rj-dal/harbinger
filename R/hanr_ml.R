#'@title Anomaly detector based on machine learning regression.
#'@description Anomaly detection using daltoolbox regression
#'The regression model adjusts to the time series. Observations distant from the model are labeled as anomalies.
#'A set of preconfigured regression methods are described in <https://cefet-rj-dal.github.io/daltoolbox/>.
#'They include: ts_elm, ts_conv1d, ts_lstm, ts_mlp, ts_rf, ts_svm
#'@param model DALToolbox regression model
#'@param sw_size sliding window size
#'@return `hanr_ml` object
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
#'model <- hanr_ml(ts_elm(ts_norm_gminmax(), input_size=4, nhid=3, actfun="purelin"))
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
hanr_ml <- function(model, sw_size = 15) {
  obj <- harbinger()
  obj$model <- model
  obj$sw_size <- sw_size

  class(obj) <- append("hanr_ml", class(obj))
  return(obj)
}

#'@exportS3Method fit hanr_ml
fit.hanr_ml <- function(obj, serie, ...) {
  ts <- ts_data(serie, obj$sw_size)
  io <- ts_projection(ts)

  obj$model <- fit(obj$model, x=io$input, y=io$output)

  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom stats predict
#'@exportS3Method detect hanr_ml
detect.hanr_ml <- function(obj, serie, ...) {
  obj <- obj$har_store_refs(obj, serie)

  ts <- ts_data(obj$serie, obj$sw_size)
  io <- ts_projection(ts)

  adjust <- stats::predict(obj$model, io$input)

  res <- io$output-adjust

  res <- obj$har_distance(res)
  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)
  threshold <- attr(anomalies, "threshold")

  res <- c(rep(NA, obj$sw_size - 1), res)
  anomalies <- c(rep(NA, obj$sw_size - 1), anomalies)
  attr(anomalies, "threshold") <- threshold

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}
