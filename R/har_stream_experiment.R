#' @title Streaming experiment runner
#' @description
#' Runs a reproducible grid of online streaming experiments by combining
#' detectors, source factories, batch settings, memory policies, and optional
#' labeled references.
#'
#' The experiment runner is intentionally lightweight. It reuses the online
#' session layer and returns both the raw runs and a compact summary table.
#' @param detectors Named list of detector objects. An unnamed list is also
#'   accepted and will be labeled by class.
#' @param source_factory Function that creates a fresh source object for each
#'   run. This keeps each execution independent and reproducible.
#' @param warmup_grid Integer vector of warm-up sizes.
#' @param batch_grid Integer vector of batch sizes.
#' @param memory_grid List of memory policy objects.
#' @param executor Execution strategy. Defaults to `har_online_refit_full()`.
#' @param reference Optional event reference vector.
#' @param mode Session mode: `"auto"`, `"pull"`, or `"push"`.
#' @param ... Additional arguments forwarded to `run_online()`.
#' @return A `har_stream_experiment` object with:
#' - `runs`: a list of raw run objects containing session, trace, and evaluation;
#' - `summary`: a compact data frame for cross-configuration comparison.
#' @examples
#' factory <- function() har_source_simulated(c(1, 1, 1, 10, 1, 1))
#' experiment <- har_stream_experiment(
#'   detectors = list(page = hcp_page_hinkley(min_instances = 3, threshold = 1)),
#'   source_factory = factory,
#'   warmup_grid = 3,
#'   batch_grid = c(1, 2),
#'   memory_grid = list(har_memory_full())
#' )
#' experiment$summary
#' @export
har_stream_experiment <- function(detectors,
                                  source_factory,
                                  warmup_grid,
                                  batch_grid,
                                  memory_grid,
                                  executor = har_online_refit_full(),
                                  reference = NULL,
                                  mode = c("auto", "pull", "push"),
                                  ...) {
  if (!is.function(source_factory)) stop("source_factory must be a function.", call. = FALSE)
  if (!is.list(detectors) || length(detectors) == 0L) stop("detectors must be a non-empty list.", call. = FALSE)
  if (!is.list(memory_grid) || length(memory_grid) == 0L) stop("memory_grid must be a non-empty list.", call. = FALSE)

  mode <- match.arg(mode)

  detector_names <- names(detectors)
  if (is.null(detector_names) || any(!nzchar(detector_names))) {
    detector_names <- vapply(detectors, function(det) class(det)[1], character(1))
  }

  runs <- list()
  summary_rows <- list()
  run_id <- 0L

  for (d_idx in seq_along(detectors)) {
    detector <- detectors[[d_idx]]
    detector_name <- detector_names[[d_idx]]

    for (warmup_size in warmup_grid) {
      for (batch_size in batch_grid) {
        for (memory in memory_grid) {
          run_id <- run_id + 1L
          source <- source_factory()
          session <- har_online_session(
            source = source,
            detector = detector,
            executor = executor,
            warmup_size = warmup_size,
            batch_size = batch_size,
            memory = memory,
            mode = mode
          )

          session <- fit(session)
          session <- run_online(session, ...)

          trace <- collect_trace(session)
          evaluation <- evaluate(har_stream_eval(), trace, reference = reference)

          runs[[run_id]] <- list(
            detector_name = detector_name,
            warmup_size = warmup_size,
            batch_size = batch_size,
            memory = memory,
            session = session,
            trace = trace,
            evaluation = evaluation
          )

          summary_rows[[run_id]] <- har_stream_experiment_row(
            detector_name = detector_name,
            warmup_size = warmup_size,
            batch_size = batch_size,
            memory = memory,
            evaluation = evaluation,
            batch_log = collect_batch_log(session)
          )
        }
      }
    }
  }

  summary <- do.call(rbind, summary_rows)
  rownames(summary) <- NULL

  structure(
    list(
      runs = runs,
      summary = summary
    ),
    class = "har_stream_experiment"
  )
}

har_stream_experiment_row <- function(detector_name, warmup_size, batch_size, memory, evaluation, batch_log) {
  hard <- evaluation$hard_metrics
  data.frame(
    detector = detector_name,
    warmup_size = warmup_size,
    batch_size = batch_size,
    memory = har_memory_label(memory),
    n_batches = nrow(batch_log),
    mean_detection_probability = evaluation$summary$mean_detection_probability,
    median_detection_probability = evaluation$summary$median_detection_probability,
    mean_detection_lag_batches = evaluation$summary$mean_detection_lag_batches,
    median_detection_lag_batches = evaluation$summary$median_detection_lag_batches,
    mean_batch_time_sec = if (nrow(batch_log) == 0L) NA_real_ else mean(batch_log$total_time_sec, na.rm = TRUE),
    accuracy = if (is.null(hard)) NA_real_ else hard$accuracy,
    precision = if (is.null(hard)) NA_real_ else hard$precision,
    recall = if (is.null(hard)) NA_real_ else hard$recall,
    F1 = if (is.null(hard)) NA_real_ else hard$F1,
    stringsAsFactors = FALSE
  )
}
