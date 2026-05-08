#' @title KSWIN change-point detector
#' @description
#' Kolmogorov-Smirnov Windowing for univariate time series. The detector keeps a
#' sliding window, compares an early sample against the most recent observations,
#' and flags a changepoint when the two empirical distributions differ
#' significantly.
#'
#' This implementation is restricted to univariate numeric series and is intended
#' to capture virtual drift on the signal directly, without any classifier.
#'
#' @param window_size Size of the sliding window.
#' @param stat_size Size of the statistic subwindow used for the KS test.
#' @param alpha Significance level for the KS test.
#' @param data Optional initial window content.
#' @return An `hcp_kswin` object.
#'
#' @references
#' - Raab C, Heusinger M, Schleif FM (2020). Reactive Soft Prototype Computing for Concept Drift Streams. Neurocomputing.
#' - Bifet A, Gavaldà R (2007). Learning from time-changing data with adaptive windowing. SIAM International Conference on Data Mining.
#'
#' @export
hcp_kswin <- function(window_size = 100, stat_size = 30, alpha = 0.005, data = NULL) {
  obj <- harbinger()
  obj$window_size <- window_size
  obj$stat_size <- stat_size
  obj$alpha <- alpha
  obj$p_value <- 0
  obj$n <- 0

  if (obj$alpha < 0 || obj$alpha > 1) stop("alpha must be between 0 and 1.", call. = FALSE)
  if (obj$window_size <= 0) stop("window_size must be greater than 0.", call. = FALSE)
  if (obj$stat_size <= 0) stop("stat_size must be greater than 0.", call. = FALSE)
  if (obj$window_size <= 2 * obj$stat_size) stop("window_size must be greater than 2 * stat_size.", call. = FALSE)

  if (is.null(data)) {
    obj$window <- numeric()
  } else {
    obj$window <- as.numeric(stats::na.omit(data))
  }

  class(obj) <- append("hcp_kswin", class(obj))
  obj
}

#' @importFrom stats complete.cases
#' @importFrom stats ks.test
#' @importFrom stats na.omit
#' @exportS3Method fit hcp_kswin
fit.hcp_kswin <- function(obj, serie, ...) {
  if (is.null(serie)) stop("No data was provided", call. = FALSE)
  obj <- obj$har_store_refs(obj, serie)
  obj
}

#' @exportS3Method detect hcp_kswin
detect.hcp_kswin <- function(obj, serie, ...) {
  if (is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  if (is.data.frame(serie)) {
    if (ncol(serie) != 1) stop("hcp_kswin only accepts univariate series.", call. = FALSE)
    serie <- serie[[1]]
  }
  if (!is.numeric(serie)) stop("serie must be numeric.", call. = FALSE)

  serie <- stats::na.omit(serie)
  n <- length(serie)
  if (n == 0) stop("No non-missing observations were provided.", call. = FALSE)

  update <- function(obj, x) {
    obj$n <- obj$n + 1
    obj$window <- c(obj$window, x)

    if (length(obj$window) < obj$window_size) {
      return(list(obj = obj, pred = FALSE))
    }

    if (length(obj$window) > obj$window_size) {
      obj$window <- utils::tail(obj$window, obj$window_size)
    }

    early <- obj$window[seq_len(obj$window_size - obj$stat_size)]
    recent <- obj$window[(obj$window_size - obj$stat_size + 1):obj$window_size]
    ks_res <- stats::ks.test(sample(early, size = obj$stat_size), recent, exact = TRUE)

    obj$p_value <- ks_res$p.value
    pred <- is.finite(obj$p_value) && obj$p_value < obj$alpha && ks_res$statistic > 0.1
    list(obj = obj, pred = pred)
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
