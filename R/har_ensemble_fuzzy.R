#' @title Harbinger Fuzzy Ensemble
#' @description
#' Score-based ensemble across multiple Harbinger detectors with optional
#' temporal fuzzification, thresholding, and non-maximum suppression.
#'
#' This variant preserves the richer aggregation logic that was previously mixed
#' into `har_ensemble()`, but keeps the simple majority-vote ensemble separate.
#'
#' @param ... One or more detector objects.
#' @return A `har_ensemble_fuzzy` object.
#'
#' @examples
#' library(daltoolbox)
#'
#' data(examples_changepoints)
#' dataset <- examples_changepoints$simple
#'
#' model <- har_ensemble_fuzzy(hcp_amoc(), hcp_pelt(), hcp_cf_lr())
#' model <- fit(model, dataset$serie)
#' detection <- detect(model, dataset$serie, time_tolerance = 8, use_nms = TRUE)
#' print(detection[detection$event, ])
#'
#' @references
#' - Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. 1st ed.
#'   Cham: Springer Nature Switzerland, 2025. doi:10.1007/978-3-031-75941-3
#'
#' @export
har_ensemble_fuzzy <- function(...) {
  obj <- harbinger()
  args <- list(...)
  exprs <- as.list(substitute(list(...)))[-1]
  arg_names <- names(args)
  if (is.null(arg_names)) arg_names <- rep("", length(args))
  arg_names <- mapply(function(nm, ex) {
    if (nm == "" || is.na(nm)) deparse(ex) else nm
  }, arg_names, exprs, USE.NAMES = FALSE)

  obj$models <- Map(function(mod, nm) list(model = mod, name = nm), args, arg_names)
  names(obj$models) <- arg_names
  hutils <- harutils()
  obj$har_outliers <- hutils$har_outliers_none
  obj$har_outliers_check <- hutils$har_outliers_checks_highgroup
  obj$har_fuzzify_detections <- hutils$har_fuzzify_detections_triangle
  obj$detection <- list(
    threshold = 0.5,
    threshold_type = "fixed",
    time_tolerance = 0,
    use_nms = FALSE
  )
  class(obj) <- append("har_ensemble_fuzzy", class(obj))
  obj
}

#' @importFrom stats na.omit
#' @exportS3Method fit har_ensemble_fuzzy
fit.har_ensemble_fuzzy <- function(obj, serie, ...) {
  if (is.null(serie)) stop("No data was provided for computation", call. = FALSE)
  serie <- stats::na.omit(serie)
  for (i in seq_along(obj$models)) {
    model_entry <- obj$models[[i]]
    model_entry$model <- fit(model_entry$model, serie)
    obj$models[[i]] <- model_entry
  }
  obj
}

#' @title Detect events using Harbinger Fuzzy Ensemble
#' @param obj A `har_ensemble_fuzzy` object.
#' @param serie Input time series.
#' @param threshold Numeric detection threshold.
#' @param threshold_type Either `"fixed"` or `"percentile"`.
#' @param time_tolerance Integer window for temporal fuzzification and NMS.
#' @param use_nms Logical; whether to apply non-maximum suppression.
#' @param outliers_check Optional refinement function.
#' @param outlier_filter Optional post-filter over the ensemble score. It may
#'   return a logical mask or integer positions.
#' @param ... Additional arguments.
#' @return A detection object with score and per-model events as attributes.
#' @exportS3Method detect har_ensemble_fuzzy
detect.har_ensemble_fuzzy <- function(
    obj,
    serie,
    threshold = NULL,
    threshold_type = NULL,
    time_tolerance = NULL,
    use_nms = NULL,
    outliers_check = NULL,
    outlier_filter = NULL,
    ...
) {
  if (is.null(serie)) stop("No data was provided for computation", call. = FALSE)
  if (is.null(threshold)) threshold <- obj$detection$threshold
  if (is.null(threshold_type)) threshold_type <- obj$detection$threshold_type
  threshold_type <- match.arg(threshold_type, c("fixed", "percentile"))
  if (is.null(time_tolerance)) time_tolerance <- obj$detection$time_tolerance
  if (is.null(use_nms)) use_nms <- obj$detection$use_nms
  if (is.null(outlier_filter)) outlier_filter <- obj$har_outliers
  if (is.null(outliers_check)) outliers_check <- obj$har_outliers_check

  obj <- obj$har_store_refs(obj, serie)
  score_matrix <- NULL
  type_matrix <- NULL
  model_events <- list()

  for (i in seq_along(obj$models)) {
    m <- obj$models[[i]]
    det <- detect(m$model, obj$serie)
    model_name <- if (!is.null(m$name) && m$name != "") m$name else paste0("model_", i)
    event <- as.logical(det$event)
    event[is.na(event)] <- FALSE
    type <- det$type
    type[is.na(type)] <- ""
    type[event & type == ""] <- "anomaly"
    type[!event] <- ""
    event_num <- as.numeric(event)
    attr(event_num, "type") <- type
    fuzzy <- obj$har_fuzzify_detections(event_num, time_tolerance)
    fuzzy <- as.numeric(fuzzy)
    fuzzy_type <- attr(fuzzy, "type")
    if (is.null(fuzzy_type)) fuzzy_type <- rep("", length(fuzzy))
    fuzzy_type[is.na(fuzzy_type)] <- ""
    score_matrix <- if (is.null(score_matrix)) matrix(fuzzy, ncol = 1) else cbind(score_matrix, fuzzy)
    type_matrix <- if (is.null(type_matrix)) matrix(fuzzy_type, ncol = 1) else cbind(type_matrix, fuzzy_type)
    model_events[[model_name]] <- list(raw = event, type = type)
  }

  if (is.null(score_matrix) || ncol(score_matrix) == 0) stop("Empty ensemble score matrix", call. = FALSE)
  n_models <- ncol(score_matrix)
  score <- rowSums(score_matrix, na.rm = TRUE)
  score <- pmin(pmax(score / n_models, 0), 1)

  type <- apply(type_matrix, 1, function(x) {
    x <- x[x != ""]
    if (length(x) == 0) return("")
    if ("changepoint" %in% x) return("changepoint")
    "anomaly"
  })

  if (threshold_type == "percentile") {
    valid <- score[score > 0]
    threshold_value <- if (length(valid) == 0) Inf else stats::quantile(valid, probs = threshold, na.rm = TRUE)
  } else {
    threshold_value <- threshold
  }

  event <- score >= threshold_value
  n <- length(score)
  out_mask <- rep(TRUE, n)
  if (!is.null(outlier_filter)) {
    out_raw <- outlier_filter(score)
    if (is.logical(out_raw) && length(out_raw) == n) {
      out_mask <- out_raw
    } else if (is.numeric(out_raw) && length(out_raw) > 0) {
      out_mask <- rep(FALSE, n)
      out_raw <- out_raw[!is.na(out_raw) & out_raw >= 1 & out_raw <= n]
      out_mask[out_raw] <- TRUE
    }
  }
  event <- event & out_mask
  if (!is.null(outliers_check)) event <- outliers_check(event, score)
  if (use_nms && sum(event) > 1 && time_tolerance > 0) {
    idx <- which(event)
    ord <- order(score[idx], decreasing = TRUE)
    selected <- integer(0)
    for (i in ord) {
      j <- idx[i]
      if (length(selected) == 0 || all(abs(j - selected) > time_tolerance)) selected <- c(selected, j)
    }
    tmp <- rep(FALSE, n)
    tmp[selected] <- TRUE
    event <- tmp
  }
  anomalies <- (type == "anomaly") & event
  changepoints <- (type == "changepoint") & event
  detection <- obj$har_restore_refs(obj, anomalies = anomalies, change_points = changepoints, res = score)
  detection$event <- event
  attr(detection, "model_events") <- model_events
  attr(detection, "threshold") <- threshold_value
  attr(detection, "type") <- type
  attr(detection, "score") <- score
  detection
}
