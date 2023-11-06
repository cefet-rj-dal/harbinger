#'@title Anomaly detector using GARCH
#'@description Anomaly detection using GARCH
#'The GARCH model adjusts to the time series. Observations distant from the model are labeled as anomalies.
#'It wraps the ugarch model presented in the rugarch library.
#'@return `hanr_garch` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(har_examples)
#'
#'#Using example 14
#'dataset <- har_examples$example14
#'head(dataset)
#'
#'# setting up time series regression model
#'model <- hanr_garch()
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
hanr_garch <- function() {
  obj <- harbinger()

  class(obj) <- append("hanr_garch", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom rugarch ugarchspec
#'@importFrom rugarch ugarchfit
#'@export
detect.hanr_garch <- function(obj, serie, ...) {
  obj <- obj$har_store_refs(obj, serie)

  spec <- rugarch::ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
                                 mean.model = list(armaOrder = c(1, 1), include.mean = TRUE),
                                 distribution.model = "norm")

  #Adjusting a model to the entire series
  model <- rugarch::ugarchfit(spec=spec, data=obj$serie, solver="hybrid")@fit

  #Adjustment error on the entire series
  res <- model$sigma

  res <- obj$har_residuals(res)
  anomalies <- obj$har_outliers_idx(res)
  anomalies <- obj$har_outliers_group(anomalies, length(res))

  detection <- obj$har_restore_refs(obj, anomalies = anomalies)

  return(detection)
}

