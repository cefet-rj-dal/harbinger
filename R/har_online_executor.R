#' @title Online execution strategies
#' @description
#' Execution strategies tell a Harbinger online session how the underlying
#' detector should be invoked when a new batch is ready.
#'
#' This makes the adaptation from offline detectors to streaming operation
#' explicit instead of implicit.
#'
#' For detector authors, the incremental strategy assumes an optional
#' `online_update(obj, serie, ...)` function stored in the detector object. When
#' present, it must return the updated detector after incorporating the current
#' in-memory series. If absent, the incremental strategy behaves like
#' detect-only execution.
#' @name har_online_executor
NULL

#' @title Full refit execution strategy
#' @description Re-fits the detector on the current in-memory series before each batch detection.
#' @param fit_on_warmup Whether the detector should be fitted once after warm-up.
#' @return A `har_online_refit_full` object.
#' @examples
#' exec <- har_online_refit_full()
#' exec$mode
#' @export
har_online_refit_full <- function(fit_on_warmup = TRUE) {
  obj <- list(
    mode = "refit_full",
    fit_on_warmup = isTRUE(fit_on_warmup),
    fit_each_run = TRUE
  )
  class(obj) <- "har_online_refit_full"
  obj
}

#' @title Detect-only execution strategy
#' @description
#' Uses the detector as already fitted and only calls `detect()` during the
#' online loop. This is useful when the model is pre-trained or when warm-up
#' fitting should happen only once.
#' @param fit_on_warmup Whether the detector should be fitted once after warm-up.
#' @return A `har_online_detect_only` object.
#' @examples
#' exec <- har_online_detect_only()
#' exec$fit_each_run
#' @export
har_online_detect_only <- function(fit_on_warmup = FALSE) {
  obj <- list(
    mode = "detect_only",
    fit_on_warmup = isTRUE(fit_on_warmup),
    fit_each_run = FALSE
  )
  class(obj) <- "har_online_detect_only"
  obj
}

#' @title Incremental execution strategy
#' @description
#' Placeholder strategy for detectors with native stateful updates. When a
#' detector exposes an `online_update()` function in the detector object, the
#' session will call it before detection. Otherwise the strategy falls back to
#' detect-only behavior.
#' @param fit_on_warmup Whether the detector should be fitted once after warm-up.
#' @return A `har_online_incremental` object.
#' @examples
#' exec <- har_online_incremental()
#' exec$mode
#' @export
har_online_incremental <- function(fit_on_warmup = TRUE) {
  obj <- list(
    mode = "incremental",
    fit_on_warmup = isTRUE(fit_on_warmup),
    fit_each_run = FALSE
  )
  class(obj) <- "har_online_incremental"
  obj
}
