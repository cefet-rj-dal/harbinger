#' @title Harbinger Ensemble
#' @description
#' Majority-vote ensemble across multiple Harbinger detectors.
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
#' @export
har_ensemble <- function(...) {
  obj <- harbinger()
  obj$models <- c(list(...))
  obj$har_outliers_check <- NULL

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

  votes <- NULL
  types <- NULL
  for (i in 1:length(obj$models)) {
    model <- obj$models[[i]]
    detection <- detect(model, obj$serie)
    evt <- as.logical(detection$event)
    evt[is.na(evt)] <- FALSE
    typ <- detection$type
    typ[is.na(typ)] <- ""
    if (is.null(votes)) {
      votes <- matrix(as.numeric(evt), ncol = 1)
      types <- matrix(typ, ncol = 1)
    } else {
      votes <- cbind(votes, as.numeric(evt))
      types <- cbind(types, typ)
    }
  }
  res <- rowSums(votes)
  events <- res > length(obj$models) / 2
  type <- apply(types, 1, function(x) {
    x <- x[x != ""]
    if (length(x) == 0) return("")
    if ("changepoint" %in% x) return("changepoint")
    "anomaly"
  })

  type[!events] <- ""
  anomalies <- type == "anomaly"
  change_point <- type == "changepoint"

  anomalies <- anomalies & events
  change_point <- change_point & events

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, change_points = change_point, res = res)
  detection$event <- events
  attr(detection, "score") <- res
  attr(detection, "type") <- type

  return(detection)
}


