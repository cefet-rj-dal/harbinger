#' @title Streaming data sources for Harbinger
#' @description
#' The online layer of Harbinger consumes observations through source objects.
#' A source abstracts how new observations are collected, allowing the online
#' session to work with simulated vectors, data frames, callback-based feeds,
#' and external stream collectors.
#'
#' The source API is intentionally small:
#' - `next_observation()` requests the next observation in pull mode;
#' - `source_info()` exposes source metadata.
#'
#' An observation consumed by the online layer is normalized to a list with:
#' - `idx`: logical position in the stream when known;
#' - `value`: the payload used by the detector;
#' - `timestamp`: optional temporal marker;
#' - `payload`: original payload preserved for adapters that need it.
#'
#' Kafka support in this package is intentionally limited to a stub interface.
#' Actual collection is expected to be delegated to Python code integrated via
#' `reticulate`.
#'
#' @return Source object.
#' @importFrom daltoolbox dal_base
#' @name har_online_sources
NULL

#' @title Base source object
#' @description Creates the common base used by Harbinger streaming sources.
#' @param name Human-readable source name.
#' @return A `har_source` object.
#' @keywords internal
har_source <- function(name = "source") {
  obj <- dal_base()
  obj$name <- name
  class(obj) <- append("har_source", class(obj))
  obj
}

#' @title Get the next observation from a source
#' @description
#' Generic used by Harbinger online sessions to request one observation in
#' pull mode.
#' @param obj Source object.
#' @param ... Additional arguments passed to methods.
#' @return A list with fields:
#' - `source`: the updated source object;
#' - `observation`: a normalized observation or `NULL`;
#' - `available`: logical flag indicating whether a new observation was returned.
#' @export
next_observation <- function(obj, ...) {
  UseMethod("next_observation")
}

#' @export
next_observation.default <- function(obj, ...) {
  list(source = obj, observation = NULL, available = FALSE)
}

#' @title Retrieve source metadata
#' @description Returns descriptive metadata about a Harbinger source object.
#' @param obj Source object.
#' @param ... Additional arguments passed to methods.
#' @return A named list with source metadata.
#' @export
source_info <- function(obj, ...) {
  UseMethod("source_info")
}

#' @export
source_info.default <- function(obj, ...) {
  list(name = class(obj)[1])
}

#' @title Simulated source
#' @description
#' Creates a replay source from an in-memory vector or data frame. This is the
#' recommended source for reproducible streaming experiments and is the direct
#' replacement for the simulated data flow used in the Nexus prototype.
#' @param data Numeric vector, matrix, or data frame containing observations in
#'   time order.
#' @param timestamp Optional vector with one timestamp per observation.
#' @param name Source name.
#' @return A `har_source_simulated` object.
#' @examples
#' source <- har_source_simulated(c(1, 2, 3))
#' obs <- next_observation(source)
#' obs$observation$value
#' @export
har_source_simulated <- function(data, timestamp = NULL, name = "simulated") {
  if (is.null(data)) stop("data must be provided.", call. = FALSE)

  n <- if (is.data.frame(data) || is.matrix(data)) nrow(data) else length(data)
  if (!is.null(timestamp) && length(timestamp) != n) {
    stop("timestamp must have the same length as data.", call. = FALSE)
  }

  obj <- har_source(name)
  obj$data <- data
  obj$timestamp <- timestamp
  obj$cursor <- 0L
  obj$n <- n
  class(obj) <- append("har_source_simulated", class(obj))
  obj
}

#' @export
next_observation.har_source_simulated <- function(obj, ...) {
  if (obj$cursor >= obj$n) {
    return(list(source = obj, observation = NULL, available = FALSE))
  }

  obj$cursor <- obj$cursor + 1L
  i <- obj$cursor
  value <- if (is.data.frame(obj$data) || is.matrix(obj$data)) obj$data[i, , drop = FALSE] else obj$data[i]
  timestamp <- if (is.null(obj$timestamp)) NA else obj$timestamp[i]

  observation <- list(
    idx = i,
    value = value,
    timestamp = timestamp,
    payload = value
  )

  list(source = obj, observation = observation, available = TRUE)
}

#' @export
source_info.har_source_simulated <- function(obj, ...) {
  list(
    name = obj$name,
    type = "simulated",
    n = obj$n,
    cursor = obj$cursor
  )
}

#' @title Data-frame source
#' @description
#' Convenience wrapper around `har_source_simulated()` for table-shaped inputs.
#' @param data Data frame in time order.
#' @param timestamp_col Optional timestamp column name or position.
#' @param value_cols Optional value columns. Defaults to all columns except the
#'   timestamp column when provided.
#' @param name Source name.
#' @return A `har_source_dataframe` object.
#' @examples
#' df <- data.frame(ts = 1:3, value = c(10, 11, 9))
#' source <- har_source_dataframe(df, timestamp_col = "ts", value_cols = "value")
#' obs <- next_observation(source)
#' obs$observation$timestamp
#' @export
har_source_dataframe <- function(data, timestamp_col = NULL, value_cols = NULL, name = "dataframe") {
  if (!is.data.frame(data)) stop("data must be a data.frame.", call. = FALSE)

  ts_idx <- NULL
  if (!is.null(timestamp_col)) {
    ts_idx <- if (is.character(timestamp_col)) match(timestamp_col, names(data)) else as.integer(timestamp_col)
    if (is.na(ts_idx) || ts_idx < 1 || ts_idx > ncol(data)) {
      stop("timestamp_col does not reference a valid column.", call. = FALSE)
    }
  }

  if (is.null(value_cols)) {
    value_idx <- seq_len(ncol(data))
    if (!is.null(ts_idx)) value_idx <- setdiff(value_idx, ts_idx)
  } else if (is.character(value_cols)) {
    value_idx <- match(value_cols, names(data))
  } else {
    value_idx <- as.integer(value_cols)
  }

  if (any(is.na(value_idx)) || length(value_idx) == 0L) {
    stop("value_cols must reference at least one valid column.", call. = FALSE)
  }

  timestamp <- if (is.null(ts_idx)) NULL else data[[ts_idx]]
  values <- data[, value_idx, drop = FALSE]

  obj <- har_source_simulated(values, timestamp = timestamp, name = name)
  obj$timestamp_col <- if (is.null(ts_idx)) NULL else names(data)[ts_idx]
  obj$value_cols <- names(values)
  class(obj) <- append("har_source_dataframe", class(obj))
  obj
}

#' @export
source_info.har_source_dataframe <- function(obj, ...) {
  list(
    name = obj$name,
    type = "dataframe",
    n = obj$n,
    cursor = obj$cursor,
    timestamp_col = obj$timestamp_col,
    value_cols = obj$value_cols
  )
}

#' @title Callback source
#' @description
#' Creates a pull-style source that retrieves observations by calling an R
#' function. The callback must return either `NULL` when no observation is
#' available or an observation compatible with the online observation contract.
#' In practice this means a scalar, a one-row `data.frame`, or a list
#' containing at least a `value` field and optionally `idx`, `timestamp`, and
#' `payload`.
#' @param poll_fn Function called to request the next observation.
#' @param name Source name.
#' @return A `har_source_callback` object.
#' @export
har_source_callback <- function(poll_fn, name = "callback") {
  if (!is.function(poll_fn)) stop("poll_fn must be a function.", call. = FALSE)

  obj <- har_source(name)
  obj$poll_fn <- poll_fn
  obj$cursor <- 0L
  class(obj) <- append("har_source_callback", class(obj))
  obj
}

#' @export
next_observation.har_source_callback <- function(obj, ...) {
  observation <- obj$poll_fn(...)
  if (is.null(observation)) {
    return(list(source = obj, observation = NULL, available = FALSE))
  }

  obj$cursor <- obj$cursor + 1L
  observation <- har_normalize_source_observation(observation, obj$cursor)
  list(source = obj, observation = observation, available = TRUE)
}

#' @export
source_info.har_source_callback <- function(obj, ...) {
  list(
    name = obj$name,
    type = "callback",
    cursor = obj$cursor
  )
}

#' @title Kafka source stub
#' @description
#' Creates a Kafka source placeholder that documents the expected collection
#' interface while keeping the actual broker integration outside the Harbinger
#' core. This object does not implement native Kafka consumption in R.
#'
#' A `python_collector`, typically created with `reticulate`, may be attached to
#' the source. Harbinger expects this collector to expose a `get_next()` method
#' returning one observation at a time according to the same observation
#' contract used by callback sources, and an optional `close()` method.
#' @param topic Kafka topic name.
#' @param bootstrap_servers Character vector with broker addresses.
#' @param group_id Consumer group identifier.
#' @param value_schema Optional schema description for the payload.
#' @param python_collector Optional Python collector object integrated through
#'   `reticulate`. It is expected to expose `get_next()` and optionally
#'   `close()`.
#' @param name Source name.
#' @return A `har_source_kafka` object.
#' @examples
#' source <- har_source_kafka(
#'   topic = "sensor-events",
#'   bootstrap_servers = c("broker1:9092"),
#'   group_id = "harbinger-consumer"
#' )
#' try(next_observation(source))
#' @export
har_source_kafka <- function(topic,
                             bootstrap_servers,
                             group_id,
                             value_schema = NULL,
                             python_collector = NULL,
                             name = "kafka") {
  if (missing(topic) || !nzchar(topic)) stop("topic must be provided.", call. = FALSE)
  if (missing(bootstrap_servers) || length(bootstrap_servers) == 0L) {
    stop("bootstrap_servers must be provided.", call. = FALSE)
  }
  if (missing(group_id) || !nzchar(group_id)) stop("group_id must be provided.", call. = FALSE)

  obj <- har_source(name)
  obj$topic <- topic
  obj$bootstrap_servers <- bootstrap_servers
  obj$group_id <- group_id
  obj$value_schema <- value_schema
  obj$python_collector <- python_collector
  obj$initialized <- !is.null(python_collector)
  obj$cursor <- 0L
  class(obj) <- append("har_source_kafka", class(obj))
  obj
}

#' @export
next_observation.har_source_kafka <- function(obj, ...) {
  if (is.null(obj$python_collector)) {
    stop(
      "Kafka source is configured only as a stub. Attach a Python collector via reticulate.",
      call. = FALSE
    )
  }

  if (is.null(obj$python_collector$get_next)) {
    stop("python_collector must expose a get_next() method.", call. = FALSE)
  }

  observation <- obj$python_collector$get_next()
  if (is.null(observation)) {
    return(list(source = obj, observation = NULL, available = FALSE))
  }

  obj$cursor <- obj$cursor + 1L
  observation <- har_normalize_source_observation(observation, obj$cursor)
  list(source = obj, observation = observation, available = TRUE)
}

#' @export
source_info.har_source_kafka <- function(obj, ...) {
  list(
    name = obj$name,
    type = "kafka_stub",
    topic = obj$topic,
    bootstrap_servers = obj$bootstrap_servers,
    group_id = obj$group_id,
    initialized = obj$initialized
  )
}

har_normalize_source_observation <- function(observation, fallback_idx) {
  if (is.atomic(observation) && length(observation) == 1L) {
    return(list(
      idx = fallback_idx,
      value = observation,
      timestamp = NA,
      payload = observation
    ))
  }

  if (is.data.frame(observation) && nrow(observation) == 1L) {
    return(list(
      idx = fallback_idx,
      value = observation,
      timestamp = NA,
      payload = observation
    ))
  }

  if (!is.list(observation)) {
    stop("Observation must be scalar, one-row data.frame, or list.", call. = FALSE)
  }

  if (is.null(observation$value)) {
    stop("Observation list must include a value field.", call. = FALSE)
  }

  if (is.null(observation$idx)) observation$idx <- fallback_idx
  if (is.null(observation$timestamp)) observation$timestamp <- NA
  if (is.null(observation$payload)) observation$payload <- observation$value
  observation
}
