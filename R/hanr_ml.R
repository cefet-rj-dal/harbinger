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
#'data(har_examples)
#'
#'#Using example 1
#'dataset <- har_examples$example1
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
#'print(detection |> dplyr::filter(event==TRUE))
#'
#'@export
hanr_ml <- function(model, sw_size = 15) {
  obj <- harbinger()
  obj$model <- model
  obj$sw_size <- sw_size

  class(obj) <- append("hanr_ml", class(obj))
  return(obj)
}

#'@export
fit.hanr_ml <- function(obj, serie, ...) {
  ts <- ts_data(serie, obj$sw_size)
  io <- ts_projection(ts)

  obj$model <- fit(obj$model, x=io$input, y=io$output)

  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom stats predict
#'@export
detect.hanr_ml <- function(obj, serie, ...) {
  n <- length(serie)
  non_na <- which(!is.na(serie))
  serie <- stats::na.omit(serie)

  ts <- ts_data(serie, obj$sw_size)
  io <- ts_projection(ts)

  adjust <- stats::predict(obj$model, io$input)

  s <- obj$har_residuals(io$output-adjust)
  outliers <- obj$har_outliers_idx(s)
  outliers <- obj$har_outliers_group(outliers, length(s))

  outliers <- c(rep(NA, obj$sw_size - 1), outliers)

  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"

  return(detection)
}
