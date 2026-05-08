#' @title Page-Hinkley change-point detector
#' @description
#' Online change-point detection for univariate time series using the classical
#' Page-Hinkley statistic. The detector accumulates deviations from the running
#' mean and raises a changepoint when the cumulative score crosses the
#' configured threshold.
#'
#' This implementation is restricted to univariate numeric series. It is meant
#' to capture virtual drift on the observed signal directly, without any
#' classifier or multivariate preprocessing.
#'
#' @param min_instances Minimum number of observations required before a change
#'   can be reported.
#' @param delta Slack term subtracted from the deviation score.
#' @param threshold Detection threshold for the cumulative statistic.
#' @param alpha Forgetting factor applied to the cumulative score.
#' @return An `hcp_page_hinkley` object.
#'
#' @references
#' - Page ES (1954). Continuous Inspection Schemes. Biometrika, 41(1/2), 100-115.
#' - Raab C, Heusinger M, Schleif FM (2020). Reactive Soft Prototype Computing for Concept Drift Streams. Neurocomputing.
#'
#' @export
hcp_page_hinkley <- function(min_instances = 30, delta = 0.005, threshold = 50, alpha = 1 - 1e-4) {
  obj <- harbinger()
  obj$min_instances <- min_instances
  obj$delta <- delta
  obj$threshold <- threshold
  obj$alpha <- alpha
  obj$x_mean <- 0
  obj$sum <- 0
  obj$sample_count <- 1

  class(obj) <- append("hcp_page_hinkley", class(obj))
  obj
}

#' @importFrom stats na.omit
#' @importFrom stats ecdf
#' @importFrom stats complete.cases
#' @exportS3Method fit hcp_page_hinkley
fit.hcp_page_hinkley <- function(obj, serie, ...) {
  if (is.null(serie)) stop("No data was provided", call. = FALSE)
  obj <- obj$har_store_refs(obj, serie)
  obj
}

#' @exportS3Method detect hcp_page_hinkley
detect.hcp_page_hinkley <- function(obj, serie, ...) {
  if (is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  if (is.data.frame(serie)) {
    if (ncol(serie) != 1) stop("hcp_page_hinkley only accepts univariate series.", call. = FALSE)
    serie <- serie[[1]]
  }
  if (!is.numeric(serie)) stop("serie must be numeric.", call. = FALSE)

  serie <- stats::na.omit(serie)
  n <- length(serie)
  if (n == 0) stop("No non-missing observations were provided.", call. = FALSE)

  update <- function(obj, x) {
    obj$x_mean <- obj$x_mean + (x - obj$x_mean) / obj$sample_count
    obj$sum <- max(0, obj$alpha * obj$sum + (x - obj$x_mean - obj$delta))
    obj$sample_count <- obj$sample_count + 1

    if (obj$sample_count < obj$min_instances) {
      return(list(obj = obj, pred = FALSE))
    }

    if (obj$sum > obj$threshold) {
      obj$x_mean <- 0
      obj$sum <- 0
      obj$sample_count <- 1
      return(list(obj = obj, pred = TRUE))
    }

    list(obj = obj, pred = FALSE)
  }

  ph_result <- rep(FALSE, n)
  output <- update(obj, serie[1])
  for (i in seq_len(n)) {
    output <- update(output$obj, serie[i])
    ph_result[i] <- output$pred
  }

  detection <- data.frame(
    idx = seq_len(n),
    event = FALSE,
    type = "",
    stringsAsFactors = FALSE
  )
  if (any(ph_result)) detection$event[ph_result] <- TRUE
  detection$type[ph_result] <- "changepoint"
  detection
}
