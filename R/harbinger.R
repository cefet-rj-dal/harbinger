#' @title Harbinger
#' @description
#' Base class for time series event detection in the Harbinger framework.
#' It provides common state handling and helper methods used by anomaly,
#' change point, and motif detectors. Concrete detectors extend this class
#' and implement their own `fit()` and/or `detect()` S3 methods.
#'
#' @details
#' Internally, this class stores references to the original series, indices of
#' non-missing observations, and helper structures to restore detection results
#' in the original series index space. It also exposes utility hooks for
#' distance computation and outlier post-processing provided by `harutils()`.
#'
#' @return A `harbinger` object that can be extended by detectors.
#'
#' @examples
#' # See the specific detector examples for anomalies, change points, and motifs
#' # at https://cefet-rj-dal.github.io/harbinger
#'
#' @references
#' - Harbinger documentation: https://cefet-rj-dal.github.io/harbinger
#' - Salles, R., Escobar, L., Baroni, L., Zorrilla, R., Ziviani, A., Kreischer, V., Delicato, F.,
#'   Pires, P. F., Maia, L., Coutinho, R., Assis, L., Ogasawara, E. Harbinger: Um framework para
#'   integração e análise de métodos de detecção de eventos em séries temporais. Anais do
#'   Simpósio Brasileiro de Banco de Dados (SBBD). In: Anais do XXXV Simpósio Brasileiro de
#'   Bancos de Dados. SBC, 28 Sep. 2020. doi:10.5753/sbbd.2020.13626
#'
#' @importFrom daltoolbox dal_base
#' @importFrom stats quantile
#' @export
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
    threshold <- NULL
    startup <- obj$anomalies
    if (!is.null(change_points)) {
      obj$change_points[obj$non_na] <- change_points
      startup <- obj$change_points
    }
    if (!is.null(anomalies)) {
      obj$anomalies[obj$non_na] <- anomalies
      startup <- obj$anomalies
      threshold <- attr(anomalies, "threshold")
    }

    if (!is.null(res)) {
      obj$res[obj$non_na] <- res
    }

    detection <- data.frame(idx=1:length(obj$anomalies), event = startup, type="")
    detection$type[obj$anomalies] <- "anomaly"
    detection$event[obj$change_points] <- TRUE
    detection$type[obj$change_points] <- "changepoint"

    attr(detection, "res") <- obj$res
    attr(detection, "threshold") <- threshold
    return(detection)
  }
  obj <- dal_base()
  class(obj) <- append("harbinger", class(obj))
  obj$har_store_refs <- har_store_refs
  obj$har_restore_refs <- har_restore_refs

  hutils <- harutils()
  obj$har_distance <- hutils$har_distance_l2
  obj$har_outliers <- hutils$har_outliers_gaussian
  obj$har_outliers_check <- hutils$har_outliers_checks_firstgroup

  return(obj)
}

#' @title Detect events in time series
#' @description Generic S3 generic for event detection using a fitted Harbinger model.
#' Concrete methods are implemented by each detector class.
#' @param obj A `harbinger` detector object.
#' @param ... Additional arguments passed to methods.
#' @return A data frame with columns: `idx` (index), `event` (logical), and
#'   `type` (character: "anomaly", "changepoint", or ""). Some detectors may
#'   also attach attributes (e.g., `threshold`) or columns (e.g., `seq`, `seqlen`).
#' @examples
#' # See detector-specific examples in the package site for usage patterns
#' # and plotting helpers.
#' @export
detect <- function(obj, ...) {
  UseMethod("detect")
}

#'@exportS3Method detect harbinger
detect.harbinger <- function(obj, serie, ...) {
  return(data.frame(idx = 1:length(serie), event = rep(FALSE, length(serie)), type = ""))
}

#' @importFrom daltoolbox evaluate
#' @exportS3Method evaluate harbinger
evaluate.harbinger <- function(obj, detection, event, evaluation = har_eval(), ...) {
  return(evaluate(evaluation, detection, event))
}


