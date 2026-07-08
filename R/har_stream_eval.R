#' @title Streaming evaluation for online detection
#' @description
#' Evaluates structured online traces produced by `har_online_session()`. This
#' evaluator complements `har_eval()` by computing the metrics introduced in the
#' Nexus paper, namely Detection Probability (DP) and Detection Lag (DL), while
#' also exposing conventional end-of-run classification metrics when labels are
#' available.
#' @return A `har_stream_eval` object.
#' @examples
#' source <- har_source_simulated(c(1, 1, 1, 10, 1, 1))
#' session <- har_online_session(
#'   source = source,
#'   detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
#'   warmup_size = 3,
#'   batch_size = 1
#' )
#' session <- daltoolbox::fit(session)
#' session <- run_online(session)
#' trace <- collect_trace(session)
#' daltoolbox::evaluate(har_stream_eval(), trace)
#' @export
har_stream_eval <- function() {
  obj <- daltoolbox::dal_base()
  class(obj) <- append("har_stream_eval", class(obj))
  obj
}

#' @title Evaluate a streaming trace
#' @description
#' Computes trace-level summaries and, when a reference label vector is
#' provided, combines them with the standard Harbinger hard evaluation.
#' @param obj A `har_stream_eval` object.
#' @param detection Trace data frame returned by `collect_trace()`.
#' @param reference Optional logical or numeric event reference aligned with the
#'   observation index.
#' @param probability_threshold Optional DP threshold used to derive an
#'   additional filtered detection vector.
#' @param ... Unused.
#' @return A named list with per-observation trace metrics and aggregate
#'   summaries. The returned list always includes:
#' - `summary`: aggregate DP and DL statistics;
#' - `by_observation`: the original trace table.
#'
#' When `reference` is provided, it also includes:
#' - `hard_metrics`: standard final binary evaluation using `har_eval()`.
#'
#' When `probability_threshold` is provided, it also includes:
#' - `threshold`: the threshold value;
#' - `threshold_detection`: logical vector derived from DP filtering.
#'
#' When both `reference` and `probability_threshold` are provided, it also
#' includes:
#' - `threshold_hard_metrics`: hard evaluation after DP thresholding.
#' @exportS3Method evaluate har_stream_eval
evaluate.har_stream_eval <- function(obj, detection, reference = NULL, probability_threshold = NULL, ...) {
  if (is.null(detection) || !is.data.frame(detection)) {
    stop("detection must be a trace data.frame returned by collect_trace().", call. = FALSE)
  }

  required <- c("idx", "batch_frequency", "detection_frequency", "detection_probability", "detection_lag_batches", "detection_lag_observations")
  if (!all(required %in% names(detection))) {
    stop("detection does not contain the required trace columns.", call. = FALSE)
  }

  observed <- detection$detection_frequency > 0L
  detected_rows <- detection[observed, , drop = FALSE]

  summary <- list(
    n_observations = nrow(detection),
    n_detected = sum(observed),
    mean_detection_probability = if (nrow(detection) == 0L) NA_real_ else mean(detection$detection_probability, na.rm = TRUE),
    median_detection_probability = if (nrow(detection) == 0L) NA_real_ else stats::median(detection$detection_probability, na.rm = TRUE),
    mean_detection_lag_batches = if (nrow(detected_rows) == 0L) NA_real_ else mean(detected_rows$detection_lag_batches, na.rm = TRUE),
    median_detection_lag_batches = if (nrow(detected_rows) == 0L) NA_real_ else stats::median(detected_rows$detection_lag_batches, na.rm = TRUE),
    mean_detection_lag_observations = if (nrow(detected_rows) == 0L) NA_real_ else mean(detected_rows$detection_lag_observations, na.rm = TRUE),
    median_detection_lag_observations = if (nrow(detected_rows) == 0L) NA_real_ else stats::median(detected_rows$detection_lag_observations, na.rm = TRUE),
    zero_lag_rate = if (nrow(detected_rows) == 0L) NA_real_ else mean(detected_rows$detection_lag_batches == 0L, na.rm = TRUE)
  )

  result <- list(
    summary = summary,
    by_observation = detection
  )

  if (!is.null(probability_threshold)) {
    result$threshold <- probability_threshold
    result$threshold_detection <- detection$detection_probability >= probability_threshold
  }

  if (!is.null(reference)) {
    reference <- as.logical(reference)
    hard <- har_eval()

    final_detection <- rep(FALSE, length(reference))
    idx <- detection$idx[detection$detection_frequency > 0L]
    idx <- idx[idx >= 1L & idx <= length(reference)]
    final_detection[idx] <- TRUE

    result$hard_metrics <- evaluate(hard, final_detection, reference)

    if (!is.null(probability_threshold)) {
      dp_detection <- rep(FALSE, length(reference))
      idx <- detection$idx[detection$detection_probability >= probability_threshold]
      idx <- idx[idx >= 1L & idx <= length(reference)]
      dp_detection[idx] <- TRUE
      result$threshold_hard_metrics <- evaluate(hard, dp_detection, reference)
    }
  }

  result
}
