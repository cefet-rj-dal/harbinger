#'@title Harbinger Ensemble
#'@description Ensemble detector
#'@param ... list of detectors
#'@return Harbinger object
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
#'# setting up time series emd detector
#'model <- har_ensemble(hanr_fbiad(), hanr_arima(), hanr_emd())
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'@import daltoolbox
#'@importFrom stats quantile
#'@export
har_ensemble <- function(...) {
  obj <- harbinger()
  obj$time_tolerance <- 0
  obj$models <- c(list(...))

  hutils <- harutils()
  obj$har_fuzzify_detections <- hutils$har_fuzzify_detections_triangle

  class(obj) <- append("har_ensemble", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@exportS3Method fit har_ensemble
fit.har_ensemble <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  serie <- stats::na.omit(serie)

  for (i in 1:length(obj$models)) {
    model <- obj$models[[i]]
    model <- fit(model, serie)
    obj$models[[i]] <- model
  }

  return(obj)
}

#'@importFrom stats na.omit
#'@exportS3Method detect har_ensemble
detect.har_ensemble <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  values <- NULL
  types <- NULL
  for (i in 1:length(obj$models)) {
    model <- obj$models[[i]]
    detection <- detect(model, obj$serie)

    varname <- sprintf("v%d", i)
    evt <- detection$event
    attr(evt, "type") <- detection$type
    if (is.null(values)) {
      evt <- obj$har_fuzzify_detections(evt, obj$time_tolerance)
      values <- as.double(evt)
      types <- as.data.frame(attr(evt, "type"))
    }
    else {
      evt <- obj$har_fuzzify_detections(evt, obj$time_tolerance)
      values <- cbind(values, as.double(evt))
      types <- cbind(types, attr(evt, "type"))
    }
  }
  res <- rowSums(values) # Every method has 1 vote
  event <- res >= length(obj$models)/2
  type <- apply(types, 1, max)


  type[!event] <- ""
  anomalies <- type == "anomaly"
  change_point <- type == "changepoint"
  anomalies <- har_outliers_boxplot(anomalies)
  anomalies <- obj$har_outliers_check(anomalies, res)
  change_point <- har_outliers_boxplot(change_point)
  change_point <- obj$har_outliers_check(change_point, res)

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, change_point = change_point, res = res)

  return(detection)
}


