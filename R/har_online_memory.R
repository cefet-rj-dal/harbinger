#' @title Online memory policies
#' @description
#' Memory policies define how much recent context an online Harbinger session
#' keeps in memory before each detection cycle.
#'
#' The online layer treats memory as an execution policy rather than as a
#' property of the detector itself.
#' @name har_online_memory
NULL

#' @title Full memory policy
#' @description Keeps all observations seen by the online session.
#' @return A `har_memory_full` object.
#' @examples
#' memory <- har_memory_full()
#' memory$mode
#' @export
har_memory_full <- function() {
  obj <- list(mode = "full")
  class(obj) <- "har_memory_full"
  obj
}

#' @title Sliding batch memory policy
#' @description
#' Keeps only the most recent `batches` completed batches in memory.
#' @param batches Number of completed batches to retain.
#' @return A `har_memory_sliding` object.
#' @examples
#' memory <- har_memory_sliding(3)
#' memory$batches
#' @export
har_memory_sliding <- function(batches) {
  batches <- as.integer(batches)
  if (is.na(batches) || batches < 1L) {
    stop("batches must be a positive integer.", call. = FALSE)
  }

  obj <- list(mode = "sliding_batches", batches = batches)
  class(obj) <- "har_memory_sliding"
  obj
}

#' @title Last-observation memory policy
#' @description Keeps only the most recent `n` observations in memory.
#' @param n Number of observations to retain.
#' @return A `har_memory_last_observations` object.
#' @examples
#' memory <- har_memory_last_observations(100)
#' memory$n
#' @export
har_memory_last_observations <- function(n) {
  n <- as.integer(n)
  if (is.na(n) || n < 1L) {
    stop("n must be a positive integer.", call. = FALSE)
  }

  obj <- list(mode = "last_observations", n = n)
  class(obj) <- "har_memory_last_observations"
  obj
}

har_memory_label <- function(memory) {
  if (inherits(memory, "har_memory_full")) return("full")
  if (inherits(memory, "har_memory_sliding")) return(paste0("sliding_batches_", memory$batches))
  if (inherits(memory, "har_memory_last_observations")) return(paste0("last_observations_", memory$n))
  "custom"
}
