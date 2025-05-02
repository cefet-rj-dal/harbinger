#'@title Harbinger
#'@description Ancestor class for time series event detection
#'@return Harbinger object
#'@examples
#'#See examples of detectors for anomalies, change points, and motifs
#'#at https://cefet-rj-dal.github.io/harbinger
#'@import daltoolbox
#'@importFrom stats quantile
#'@export
harbinger <- function() {
  har_store_refs <- function(obj, serie) {
    n <- length(serie)
    if (is.data.frame(serie)) {
      n <- nrow(serie)
      obj$non_na <- which(!is.na(apply(serie, 1, max)))
      obj$serie <- stats::na.omit(serie)
    }
    else {
      obj$non_na <- which(!is.na(serie))
      obj$serie <- stats::na.omit(serie)
    }
    obj$anomalies <- rep(NA, n)
    obj$change_points <- rep(NA, n)
    obj$res <- rep(NA, n)
    return(obj)
  }

  har_restore_refs <- function(obj, anomalies = NULL, change_points = NULL, res = NULL) {
    startup <- obj$anomalies
    if (!is.null(change_points)) {
      obj$change_points[obj$non_na] <- change_points
      startup <- obj$change_points
    }
    if (!is.null(anomalies)) {
      obj$anomalies[obj$non_na] <- anomalies
      startup <- obj$anomalies
      obj$threshold <- attr(anomalies, "threshold")
    }
    if (!is.null(res)) {
      obj$res[obj$non_na] <- res
    }

    if (is.null(obj$threshold))
      obj$threshold <- 0

    detection <- data.frame(idx=1:length(obj$anomalies), event = startup, type="")
    detection$type[obj$anomalies] <- "anomaly"
    detection$event[obj$change_points] <- TRUE
    detection$type[obj$change_points] <- "changepoint"

    attr(detection, "res") <- obj$res
    return(detection)
  }
  obj <- dal_base()
  class(obj) <- append("harbinger", class(obj))
  obj$har_store_refs <- har_store_refs
  obj$har_restore_refs <- har_restore_refs

  hutils <- harutils()
  obj$har_distance <- hutils$har_distance_l2
  obj$har_outliers <- hutils$har_outliers_boxplot
  obj$har_outliers_check <- hutils$har_outliers_checks_firstgroup

  return(obj)
}

#'@title Detect events in time series
#'@description Event detection using a fitted Harbinger model
#'@param obj harbinger object
#'@param ... optional arguments.
#'@return a data frame with the index of observations and if they are identified or not as an event, and their type
#'@examples
#'#See examples of detectors for anomalies, change points, and motifs
#'#at https://cefet-rj-dal.github.io/harbinger
#'@export
detect <- function(obj, ...) {
  UseMethod("detect")
}

#'@exportS3Method detect harbinger
detect.harbinger <- function(obj, serie, ...) {
  return(data.frame(idx = 1:length(serie), event = rep(FALSE, length(serie)), type = ""))
}

#'@import daltoolbox
#'@exportS3Method evaluate harbinger
evaluate.harbinger <- function(obj, detection, event, evaluation = har_eval(), ...) {
  return(evaluate(evaluation, detection, event))
}


