#' @title Harbinger Ensemble
#' @description
#' Majority-vote ensemble across multiple Harbinger detectors with optional
#' temporal fuzzification to combine nearby detections.
#' @param ... One or more detector objects.
#' @return A `har_ensemble` object
#'
#' @examples
#' library(daltoolbox)
#'
#' # Load anomaly example data
#' data(examples_anomalies)
#'
#' # Use a simple example
#' dataset <- examples_anomalies$simple
#' head(dataset)
#'
#' # Configure an ensemble of detectors
#' model <- har_ensemble(hanr_arima(), hanr_arima(), hanr_arima())
#' # model <- har_ensemble(hanr_fbiad(), hanr_arima(), hanr_emd())
#'
#' # Fit all ensemble members
#' model <- fit(model, dataset$serie)
#'
#' # Run ensemble detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected events
#' print(detection[(detection$event),])
#'
#' @references
#' - Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. 1st ed.
#'   Cham: Springer Nature Switzerland, 2025. doi:10.1007/978-3-031-75941-3
#'
#' @importFrom stats quantile
#' @export
har_ensemble <- function(...) {
  obj <- harbinger()
  obj$time_tolerance <- 0
  obj$models <- c(list(...))

  hutils <- harutils()
  obj$har_outliers_check <- NULL
  obj$har_fuzzify_detections <- hutils$har_fuzzify_detections_triangle

  class(obj) <- append("har_ensemble", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@exportS3Method fit har_ensemble
fit.har_ensemble <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  if (is.null(obj$har_outliers_check)) {
    hutils <- harutils()
    obj$har_outliers_check <- hutils$har_outliers_checks_highgroup
  }

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
  events <- res >= length(obj$models)/2
  type <- apply(types, 1, max)

  type[!events] <- ""
  anomalies <- type == "anomaly"
  change_point <- type == "changepoint"

  events <- obj$har_outliers(res)
  events <- obj$har_outliers_check(events, res)

  anomalies <- anomalies & events
  change_point <- change_point & events

  attr(anomalies, "threshold") <- attr(events, "threshold")


  detection <- obj$har_restore_refs(obj, anomalies = anomalies, change_point = change_point, res = res)

  return(detection)
}


