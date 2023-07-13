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
#'print(detection |> dplyr::filter(event==TRUE))
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
  n <- length(serie)
  non_na <- which(!is.na(serie))
  serie <- stats::na.omit(serie)

  spec <- rugarch::ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
                                 mean.model = list(armaOrder = c(1, 1), include.mean = TRUE),
                                 distribution.model = "norm")

  #Adjusting a model to the entire series
  model <- rugarch::ugarchfit(spec=spec, data=serie, solver="hybrid")@fit

  #Adjustment error on the entire series
  s <- obj$har_residuals(model$sigma)
  outliers <- obj$har_outliers_idx(s)
  outliers <- obj$har_outliers_group(outliers, length(s))

  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"

  return(detection)
}

