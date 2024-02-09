#'@title Anomaly detector using ARIMA.
#'@description Anomaly detection using ARIMA
#'The ARIMA model adjusts to the time series. Observations distant from the model are labeled as anomalies.
#'It wraps the ARIMA model presented in the forecast library.
#'@return `hanr_arima` object
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
#'model <- hanr_arima()
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
hanr_emd <- function() {
  obj <- harbinger()
  obj$sw_size <- NULL

  class(obj) <- append("hanr_emd", class(obj))
  return(obj)
}

fit.hanr_emd <- function(obj, serie, noise = 0.1, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  serie <- stats::na.omit(serie)
  w=30
  noise.amp = noise
  trials=5
  serie <- stats::ts(serie)

  id <- 1:length(serie)
  obj$sw_size <-  length(serie)
  ceemd.result <- hht::CEEMD(serie, id, noise, trials)

  obj$model <- ceemd.result

  return(obj)
}


detect.hanr_emd <- function(obj, serie, ...) {
  ## Roughness Function
  fc_roughness <- function(x){
    firstD = diff(x)
    normFirstD = (firstD - mean(firstD)) / sd(firstD)
    roughness = (diff(normFirstD) ** 2) / 4
    return(mean(roughness))
  }

  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  ## calculate roughness for each imf
  vec <- vector()
  for (n in 1:obj$model$nimf){
    vec[n] <- fc_roughness(obj$model[["imf"]][,n])
  }

  ## Maximum curvature
  res <- transform(fit_curvature_max(), vec)
  div <- res$x
  sum_high_freq <- obj$model[["imf"]][,1]

  for (k in 2:div){
    sum_high_freq <- sum_high_freq + obj$model[["imf"]][,k]}

  ## identification of anomaly points
  diff_high_freq <- c(NA, diff(sum_high_freq))
  median_high_freq <- median(abs(diff_high_freq), na.rm= TRUE)
  distance <- abs(diff_high_freq) -  median_high_freq

  outliers_dist <- which(abs(distance)>2.698*sd(distance, na.rm=TRUE))

  obj$anomalies[1:obj$sw_size] <- FALSE
  if (!is.null(outliers_dist) & length(outliers_dist) > 0) {
    obj$anomalies[outliers_dist] <- TRUE
  }

  detection <- obj$har_restore_refs(obj, anomalies = obj$anomalies)
  return(detection)

}



