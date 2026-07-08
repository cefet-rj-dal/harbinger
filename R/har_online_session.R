#' @title Harbinger online session
#' @description
#' Creates and runs a streaming session that reuses existing Harbinger
#' detectors without changing their offline APIs. The session layer is
#' intentionally additive: it orchestrates ingestion, batching, memory
#' management, tracing, and evaluation support around the detector already
#' provided by the package.
#'
#' The session supports:
#' - pull sources through `next_observation()`
#' - push ingestion through `ingest()`
#' - full or bounded memory policies
#' - explicit execution strategies
#' - structured tracing for Detection Probability (DP) and Detection Lag (DL)
#'
#' @param source Streaming source object. May be `NULL` for push-only sessions.
#' @param detector Any existing Harbinger detector.
#' @param executor Execution strategy. Defaults to `har_online_refit_full()`.
#' @param warmup_size Number of initial observations consumed before regular
#'   streaming detection starts.
#' @param batch_size Number of new observations required to trigger one online
#'   detection cycle.
#' @param memory Memory policy. Defaults to `har_memory_full()`.
#' @param mode Session mode:
#' - `"auto"`: behaves like pull mode when a source is available and like
#'   push mode when `source = NULL`;
#' - `"pull"`: observations are requested through `next_observation(source)`;
#' - `"push"`: observations must be provided explicitly through `ingest()`.
#' @return A `har_online_session` object.
#' @examples
#' source <- har_source_simulated(c(10, 11, 12, 20, 12, 11, 10))
#' session <- har_online_session(
#'   source = source,
#'   detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
#'   warmup_size = 3,
#'   batch_size = 2
#' )
#' session <- daltoolbox::fit(session)
#' session <- run_online(session)
#' head(collect_detection(session))
#' @export
har_online_session <- function(source,
                               detector,
                               executor = har_online_refit_full(),
                               warmup_size = 30,
                               batch_size = 30,
                               memory = har_memory_full(),
                               mode = c("auto", "pull", "push")) {
  if (missing(detector) || is.null(detector)) stop("detector must be provided.", call. = FALSE)
  mode <- match.arg(mode)

  warmup_size <- as.integer(warmup_size)
  batch_size <- as.integer(batch_size)
  if (is.na(warmup_size) || warmup_size < 0L) stop("warmup_size must be a non-negative integer.", call. = FALSE)
  if (is.na(batch_size) || batch_size < 1L) stop("batch_size must be a positive integer.", call. = FALSE)

  obj <- daltoolbox::dal_base()
  obj$source <- source
  obj$detector <- detector
  obj$executor <- executor
  obj$warmup_size <- warmup_size
  obj$batch_size <- batch_size
  obj$memory <- memory
  obj$mode <- mode

  obj$queue <- list()
  obj$pull_exhausted <- FALSE
  obj$fitted <- FALSE
  obj$closed <- FALSE

  obj$values <- list()
  obj$positions <- integer()
  obj$timestamps <- list()
  obj$batch_seen <- integer()
  obj$global_values <- list()
  obj$global_timestamps <- list()
  obj$global_count <- 0L

  obj$warmup_consumed <- 0L
  obj$pending_since_last_run <- 0L
  obj$run_count <- 0L
  obj$last_completed_batch <- 0L

  obj$trace_map <- list()
  obj$batch_log <- data.frame(
    batch_id = integer(),
    memory_size = integer(),
    fit_time_sec = numeric(),
    detect_time_sec = numeric(),
    total_time_sec = numeric(),
    stringsAsFactors = FALSE
  )

  class(obj) <- append("har_online_session", class(obj))
  obj
}

#' @title Add observations to an online session
#' @description
#' Pushes one observation or a collection of observations into the session
#' queue. This is the main entry point for push-style integrations.
#' @param obj Online session.
#' @param observation One observation, a list of observations, or a data frame.
#'   Each individual observation is normalized to the online observation
#'   contract used by `next_observation()`.
#' @return Updated `har_online_session`.
#' @export
ingest <- function(obj, observation) {
  if (!inherits(obj, "har_online_session")) {
    stop("ingest() expects a har_online_session object.", call. = FALSE)
  }

  observations <- har_as_observation_list(observation)
  for (obs in observations) {
    fallback_idx <- obj$global_count + length(obj$queue) + 1L
    obj$queue[[length(obj$queue) + 1L]] <- har_normalize_source_observation(obs, fallback_idx)
  }
  obj
}

#' @title Fit an online session
#' @description
#' Consumes the warm-up observations and optionally fits the wrapped detector
#' according to the execution strategy.
#' @param obj Online session.
#' @param ... Additional arguments forwarded to the wrapped detector `fit()`
#'   method when warm-up fitting is enabled.
#' @return Updated `har_online_session`.
#' @exportS3Method fit har_online_session
fit.har_online_session <- function(obj, ...) {
  while (obj$warmup_consumed < obj$warmup_size) {
    next_item <- har_session_fetch_one(obj)
    obj <- next_item$session
    if (!next_item$available) break
    obj <- har_session_store_observation(obj, next_item$observation)
    obj$warmup_consumed <- obj$warmup_consumed + 1L
  }

  if (isTRUE(obj$executor$fit_on_warmup) && length(obj$values) > 0L) {
    serie <- har_session_series(obj)
    obj$detector <- daltoolbox::fit(obj$detector, serie, ...)
    obj$fitted <- TRUE
  }

  obj
}

#' @title Run an online session
#' @description
#' Processes the session until the pull source is exhausted and the push queue is
#' empty, or until a fixed number of online detection cycles has been executed.
#' @param obj Online session.
#' @param max_batches Optional maximum number of detection cycles to execute.
#' @param ... Additional arguments forwarded to wrapped detector methods.
#' @return Updated `har_online_session`.
#' @export
run_online <- function(obj, max_batches = NULL, ...) {
  if (!inherits(obj, "har_online_session")) {
    stop("run_online() expects a har_online_session object.", call. = FALSE)
  }

  if (!is.null(max_batches)) {
    max_batches <- as.integer(max_batches)
    if (is.na(max_batches) || max_batches < 1L) {
      stop("max_batches must be a positive integer.", call. = FALSE)
    }
  }

  while (!is_finished(obj)) {
    before <- obj$run_count
    obj <- step_online(obj, ...)
    if (!is.null(max_batches) && obj$run_count >= max_batches) break
    if (obj$run_count == before && is_finished(obj)) break
  }
  obj
}

#' @title Step an online session once
#' @description
#' Consumes at most one new observation and triggers one batch detection cycle
#' when the batch threshold is reached.
#' @param obj Online session.
#' @param ... Additional arguments forwarded to wrapped detector methods.
#' @return Updated `har_online_session`.
#' @export
step_online <- function(obj, ...) {
  if (!inherits(obj, "har_online_session")) {
    stop("step_online() expects a har_online_session object.", call. = FALSE)
  }

  if (obj$closed) return(obj)

  if (obj$warmup_consumed < obj$warmup_size) {
    obj <- fit.har_online_session(obj, ...)
    return(obj)
  }

  next_item <- har_session_fetch_one(obj)
  obj <- next_item$session

  if (!next_item$available) {
    if (obj$pending_since_last_run > 0L) {
      obj <- har_session_execute_cycle(obj, ...)
      obj$pending_since_last_run <- 0L
    }
    obj$closed <- is_finished(obj)
    return(obj)
  }

  obj <- har_session_store_observation(obj, next_item$observation)
  obj$pending_since_last_run <- obj$pending_since_last_run + 1L

  if (obj$pending_since_last_run >= obj$batch_size) {
    obj <- har_session_execute_cycle(obj, ...)
    obj$pending_since_last_run <- 0L
  }

  obj$closed <- is_finished(obj)
  obj
}

#' @title Test whether an online session has finished
#' @description
#' Returns `TRUE` when there is no queued observation left and the pull source is
#' exhausted. In push mode, the session is considered finished when the queue is
#' empty.
#' @param obj Online session.
#' @return Logical scalar.
#' @export
is_finished <- function(obj) {
  if (!inherits(obj, "har_online_session")) {
    stop("is_finished() expects a har_online_session object.", call. = FALSE)
  }

  queue_empty <- length(obj$queue) == 0L
  if (identical(obj$mode, "push")) return(queue_empty)
  queue_empty && isTRUE(obj$pull_exhausted)
}

#' @title Collect final detection output
#' @description
#' Materializes the final detection table from the online session trace.
#' @param obj Online session.
#' @return A data frame with the usual `idx`, `event`, and `type` columns plus
#'   online summary columns:
#' - `detection_probability`
#' - `detection_lag_batches`
#' - `detection_lag_observations`
#' @export
collect_detection <- function(obj) {
  if (!inherits(obj, "har_online_session")) {
    stop("collect_detection() expects a har_online_session object.", call. = FALSE)
  }

  trace <- collect_trace(obj)
  if (nrow(trace) == 0L) {
    return(data.frame(idx = integer(), event = logical(), type = character(), stringsAsFactors = FALSE))
  }

  detection <- data.frame(
    idx = trace$idx,
    event = trace$detection_frequency > 0L,
    type = ifelse(trace$detection_frequency > 0L, trace$event_type, ""),
    detection_probability = trace$detection_probability,
    detection_lag_batches = trace$detection_lag_batches,
    detection_lag_observations = trace$detection_lag_observations,
    stringsAsFactors = FALSE
  )
  detection
}

#' @title Collect the online trace
#' @description
#' Returns one row per observed time point with the quantities needed to compute
#' Detection Probability (DP) and Detection Lag (DL).
#' @param obj Online session.
#' @return Data frame with one row per observation and columns:
#' - `idx`
#' - `timestamp`
#' - `batch_id_first_seen`
#' - `batch_frequency`
#' - `detection_frequency`
#' - `first_detected_batch`
#' - `last_detected_batch`
#' - `detection_probability`
#' - `detection_lag_batches`
#' - `detection_lag_observations`
#' - `event_type`
#' @export
collect_trace <- function(obj) {
  if (!inherits(obj, "har_online_session")) {
    stop("collect_trace() expects a har_online_session object.", call. = FALSE)
  }

  entries <- obj$trace_map
  if (length(entries) == 0L) {
    return(data.frame(
      idx = integer(),
      timestamp = numeric(),
      batch_id_first_seen = integer(),
      batch_frequency = integer(),
      detection_frequency = integer(),
      first_detected_batch = integer(),
      last_detected_batch = integer(),
      detection_probability = numeric(),
      detection_lag_batches = integer(),
      detection_lag_observations = integer(),
      event_type = character(),
      stringsAsFactors = FALSE
    ))
  }

  ordered_idx <- order(as.integer(names(entries)))
  keys <- as.integer(names(entries))[ordered_idx]
  rows <- lapply(keys, function(key) har_trace_entry_to_row(entries[[as.character(key)]], obj$batch_size))
  trace <- do.call(rbind, rows)
  rownames(trace) <- NULL
  trace
}

#' @title Collect batch execution log
#' @description Returns one row per completed online detection cycle.
#' @param obj Online session.
#' @return Data frame with one row per batch and columns:
#' - `batch_id`
#' - `memory_size`
#' - `fit_time_sec`
#' - `detect_time_sec`
#' - `total_time_sec`
#' @export
collect_batch_log <- function(obj) {
  if (!inherits(obj, "har_online_session")) {
    stop("collect_batch_log() expects a har_online_session object.", call. = FALSE)
  }
  obj$batch_log
}

har_as_observation_list <- function(observation) {
  if (is.data.frame(observation)) {
    return(lapply(seq_len(nrow(observation)), function(i) observation[i, , drop = FALSE]))
  }

  if (is.list(observation) && !is.data.frame(observation) && !is.null(observation$value)) {
    return(list(observation))
  }

  if (is.list(observation) && length(observation) > 0L && all(vapply(observation, is.list, logical(1)))) {
    return(observation)
  }

  list(observation)
}

har_session_fetch_one <- function(obj) {
  if (length(obj$queue) > 0L) {
    observation <- obj$queue[[1L]]
    obj$queue <- obj$queue[-1L]
    return(list(session = obj, observation = observation, available = TRUE))
  }

  if (identical(obj$mode, "push")) {
    return(list(session = obj, observation = NULL, available = FALSE))
  }

  if (is.null(obj$source)) {
    obj$pull_exhausted <- TRUE
    return(list(session = obj, observation = NULL, available = FALSE))
  }

  result <- next_observation(obj$source)
  obj$source <- result$source
  if (!isTRUE(result$available)) obj$pull_exhausted <- TRUE
  list(session = obj, observation = result$observation, available = isTRUE(result$available))
}

har_session_store_observation <- function(obj, observation) {
  idx <- obj$global_count + 1L
  observation <- har_normalize_source_observation(observation, idx)
  idx <- as.integer(observation$idx)

  obj$global_count <- max(obj$global_count, idx)
  obj$global_values[[length(obj$global_values) + 1L]] <- observation$value
  obj$global_timestamps[[length(obj$global_timestamps) + 1L]] <- observation$timestamp

  obj$values[[length(obj$values) + 1L]] <- observation$value
  obj$positions <- c(obj$positions, idx)
  obj$timestamps[[length(obj$timestamps) + 1L]] <- observation$timestamp
  obj$batch_seen <- c(obj$batch_seen, obj$run_count + 1L)

  if (is.null(obj$trace_map[[as.character(idx)]])) {
    obj$trace_map[[as.character(idx)]] <- list(
      idx = idx,
      timestamp = observation$timestamp,
      batch_id_first_seen = obj$run_count + 1L,
      batch_ids_present = integer(),
      detected_in_batches = integer(),
      first_detected_batch = NA_integer_,
      last_detected_batch = NA_integer_,
      event_type = "event"
    )
  }
  obj
}

har_session_execute_cycle <- function(obj, ...) {
  if (length(obj$values) == 0L) return(obj)

  batch_id <- obj$run_count + 1L
  for (pos in obj$positions) {
    entry <- obj$trace_map[[as.character(pos)]]
    entry$batch_ids_present <- unique(c(entry$batch_ids_present, batch_id))
    obj$trace_map[[as.character(pos)]] <- entry
  }

  serie <- har_session_series(obj)
  fit_time <- 0
  detect_time <- 0

  if (isTRUE(obj$executor$fit_each_run)) {
    fit_start <- proc.time()[["elapsed"]]
    obj$detector <- daltoolbox::fit(obj$detector, serie, ...)
    fit_time <- proc.time()[["elapsed"]] - fit_start
    obj$fitted <- TRUE
  } else if (!obj$fitted && isTRUE(obj$executor$fit_on_warmup)) {
    fit_start <- proc.time()[["elapsed"]]
    obj$detector <- daltoolbox::fit(obj$detector, serie, ...)
    fit_time <- proc.time()[["elapsed"]] - fit_start
    obj$fitted <- TRUE
  }

  if (identical(obj$executor$mode, "incremental") && !is.null(obj$detector$online_update)) {
    obj$detector <- obj$detector$online_update(obj$detector, serie, ...)
  }

  detect_start <- proc.time()[["elapsed"]]
  detection <- detect(obj$detector, serie, ...)
  detect_time <- proc.time()[["elapsed"]] - detect_start

  obj <- har_session_update_trace_from_detection(obj, detection, batch_id)
  obj$run_count <- batch_id
  obj$last_completed_batch <- batch_id
  obj$batch_log <- rbind(
    obj$batch_log,
    data.frame(
      batch_id = batch_id,
      memory_size = length(obj$values),
      fit_time_sec = fit_time,
      detect_time_sec = detect_time,
      total_time_sec = fit_time + detect_time,
      stringsAsFactors = FALSE
    )
  )

  obj <- har_session_apply_memory(obj)
  obj
}

har_session_series <- function(obj) {
  if (length(obj$values) == 0L) return(numeric())

  first_value <- obj$values[[1L]]
  if (is.data.frame(first_value)) {
    return(do.call(rbind, obj$values))
  }

  if (is.matrix(first_value)) {
    return(do.call(rbind, obj$values))
  }

  unlist(obj$values, use.names = FALSE)
}

har_session_update_trace_from_detection <- function(obj, detection, batch_id) {
  if (is.null(detection) || nrow(detection) == 0L) return(obj)
  if (!all(c("idx", "event") %in% names(detection))) {
    stop("Wrapped detector returned an invalid detection object.", call. = FALSE)
  }

  max_local <- min(nrow(detection), length(obj$positions))
  if (max_local == 0L) return(obj)

  for (i in seq_len(max_local)) {
    if (!isTRUE(detection$event[i])) next

    global_idx <- obj$positions[i]
    entry <- obj$trace_map[[as.character(global_idx)]]
    entry$detected_in_batches <- unique(c(entry$detected_in_batches, batch_id))
    if (is.na(entry$first_detected_batch)) entry$first_detected_batch <- batch_id
    entry$last_detected_batch <- batch_id

    if ("type" %in% names(detection) && nzchar(detection$type[i])) {
      entry$event_type <- detection$type[i]
    } else if (!nzchar(entry$event_type)) {
      entry$event_type <- "event"
    }

    obj$trace_map[[as.character(global_idx)]] <- entry
  }

  obj
}

har_session_apply_memory <- function(obj) {
  if (inherits(obj$memory, "har_memory_full")) return(obj)

  keep_idx <- seq_along(obj$values)
  if (inherits(obj$memory, "har_memory_last_observations")) {
    keep_n <- min(length(obj$values), obj$memory$n)
    keep_idx <- utils::tail(seq_along(obj$values), keep_n)
  } else if (inherits(obj$memory, "har_memory_sliding")) {
    keep_batches <- utils::tail(sort(unique(obj$batch_seen)), obj$memory$batches)
    keep_idx <- which(obj$batch_seen %in% keep_batches)
  }

  obj$values <- obj$values[keep_idx]
  obj$positions <- obj$positions[keep_idx]
  obj$timestamps <- obj$timestamps[keep_idx]
  obj$batch_seen <- obj$batch_seen[keep_idx]
  obj
}

har_trace_entry_to_row <- function(entry, batch_size) {
  bf <- length(unique(entry$batch_ids_present))
  df <- length(unique(entry$detected_in_batches))
  prob <- if (bf == 0L) 0 else df / bf
  lag_batches <- if (is.na(entry$first_detected_batch)) NA_integer_ else entry$first_detected_batch - entry$batch_id_first_seen
  lag_obs <- if (is.na(lag_batches)) NA_integer_ else (lag_batches + 1L) * batch_size

  data.frame(
    idx = entry$idx,
    timestamp = I(list(entry$timestamp)),
    batch_id_first_seen = entry$batch_id_first_seen,
    batch_frequency = bf,
    detection_frequency = df,
    first_detected_batch = entry$first_detected_batch,
    last_detected_batch = entry$last_detected_batch,
    detection_probability = prob,
    detection_lag_batches = lag_batches,
    detection_lag_observations = lag_obs,
    event_type = entry$event_type,
    stringsAsFactors = FALSE
  )
}
