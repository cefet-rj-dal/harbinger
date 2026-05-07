#' @title Bayesian Online Change Point Detection
#' @description
#' Online Bayesian change-point detection using the `ocp` package.
#'
#' This implementation follows the Adams & MacKay formulation and uses the
#' `ocp` backend to infer changepoint evidence over the full series.
#'
#' @param hazard Positive scalar controlling the constant hazard function.
#' @param dist Probability model used by `ocp`; one of `"gaussian"` or `"poisson"`.
#' @param threshold Numeric threshold for changepoint evidence.
#' @param min_distance Minimum distance between selected changepoints.
#' @param burn_in Number of initial observations to ignore.
#' @return An `hcp_bocpd` object.
#'
#' @references
#' - Adams RP, MacKay DJC (2007). Bayesian Online Changepoint Detection. arXiv:0710.3742
#' - Pagotto A (2019). ocp: Bayesian Online Changepoint Detection. R package.
#'
#' @export
hcp_bocpd <- function(
    hazard = 100,
    dist = c("gaussian", "poisson"),
    threshold = NULL,
    min_distance = 5,
    burn_in = 5
) {
  dist <- match.arg(dist)
  obj <- harbinger()
  obj$hazard <- hazard
  obj$dist <- dist
  obj$threshold <- threshold
  obj$min_distance <- min_distance
  obj$burn_in <- burn_in
  obj$posterior <- NULL
  class(obj) <- append("hcp_bocpd", class(obj))
  obj
}

#' @importFrom stats na.omit
#' @exportS3Method fit hcp_bocpd
fit.hcp_bocpd <- function(obj, serie, ...) {
  if (is.null(serie)) stop("No data was provided", call. = FALSE)
  obj <- obj$har_store_refs(obj, serie)
  if (!requireNamespace("ocp", quietly = TRUE)) {
    stop("The 'ocp' package is required for hcp_bocpd(). Install it with install.packages('ocp').", call. = FALSE)
  }
  obj$posterior <- ocp::onlineCPD(
    datapts = matrix(obj$serie, ncol = 1),
    hazard_func = function(r) ocp::const_hazard(r, obj$hazard),
    probModel = list(obj$dist)
  )
  if (is.null(obj$threshold)) obj$threshold <- 0.5
  obj
}

#' @exportS3Method detect hcp_bocpd
detect.hcp_bocpd <- function(obj, serie, threshold = NULL, ...) {
  if (is.null(serie)) stop("No data provided", call. = FALSE)
  if (is.null(obj$posterior)) obj <- fit(obj, serie)
  obj <- obj$har_store_refs(obj, serie)
  res <- obj$posterior
  n <- length(obj$serie)
  cp_prob <- rep(0, n)
  cp_list <- res$changepoint_lists
  for (t in seq_along(cp_list)) {
    cps <- cp_list[[t]]
    while (is.list(cps)) cps <- unlist(cps, recursive = TRUE)
    cps <- as.integer(cps)
    cps <- cps[!is.na(cps)]
    cps <- cps[cps > 1 & cps <= n]
    if (length(cps) > 0) cp_prob[cps] <- cp_prob[cps] + 1
  }
  if (max(cp_prob) > 0) cp_prob <- cp_prob / max(cp_prob)
  burn <- obj$burn_in
  if (!is.null(burn) && burn > 0) cp_prob[1:min(burn, n)] <- 0
  if (is.null(threshold)) threshold <- obj$threshold
  event <- cp_prob >= threshold
  if (sum(event) > 1 && obj$min_distance > 0) {
    idx <- which(event)
    keep <- rep(FALSE, length(idx))
    last_kept <- -Inf
    for (i in seq_along(idx)) {
      j <- idx[i]
      if ((j - last_kept) >= obj$min_distance) {
        keep[i] <- TRUE
        last_kept <- j
      }
    }
    event[idx] <- keep
  }
  detection <- obj$har_restore_refs(obj, change_points = event, res = cp_prob)
  detection$event <- event
  attr(detection, "score") <- cp_prob
  attr(detection, "type") <- ifelse(event, "changepoint", "")
  detection
}
