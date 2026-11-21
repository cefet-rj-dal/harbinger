#' Robust ChangeFinder helpers (native, no forecast dependency)
#'
#' Internal helpers shared by \code{hcp_cf_arima} and \code{hcp_cf_ets}. They
#' implement the "++" re-engineering of the ChangeFinder detectors: the canonical
#' two-stage online SDAR ChangeFinder (Takeuchi & Yamanishi 2006) UNIONed with the
#' Gaussian mean+variance structural break (\code{.har_meanvar_single_break},
#' shared with \code{hcp_chow}/\code{hcp_gft}). See \code{hcp_cf_arima} /
#' \code{hcp_cf_ets} for the references.
#'
#' These functions mirror, line for line, the canonical Python implementation in
#' the \code{pyharbinger} package (\code{changepoint.py}: \code{_causal_ma},
#' \code{_sdar_ar_scores}, \code{_sdar_holt_scores},
#' \code{_HcpRobustChangeFinder}), so the two packages produce identical detections.
#'
#' @keywords internal
#' @noRd
NULL

# Trailing (causal) moving average of window w, same length as x.
.har_causal_ma <- function(x, w) {
  if (w <= 1) return(x)
  n <- length(x)
  cs <- c(0, cumsum(x))
  out <- rep(0, n)
  for (t in seq_len(n)) {
    lo <- max(1, t - w + 1)
    out[t] <- (cs[t + 1] - cs[lo]) / (t - lo + 1)
  }
  out
}

# Online SDAR autoregressive log-loss scores (Takeuchi & Yamanishi 2006).
.har_sdar_ar_scores <- function(x, r, order) {
  n <- length(x)
  mu <- 0
  sigma <- 1
  c <- rep(0, order + 1)   # c[1] = variance (lag 0); c[i+1] = lag i
  scores <- rep(0, n)
  for (t in seq_len(n)) {
    xt <- x[t]
    mu <- (1 - r) * mu + r * xt
    if (t <= order) next
    for (i in 1:order) {
      c[i + 1] <- (1 - r) * c[i + 1] + r * (xt - mu) * (x[t - i] - mu)
    }
    c[1] <- (1 - r) * c[1] + r * (xt - mu)^2
    if (c[1] <= 1e-12) {
      a <- rep(0, order)
    } else if (order == 1) {
      a <- c[2] / c[1]
    } else {
      idx <- abs(outer(seq_len(order), seq_len(order), "-"))
      toeplitz <- matrix(c[idx + 1], order, order)
      a <- solve(toeplitz + 1e-8 * diag(order), c[2:(order + 1)])
    }
    hist <- x[(t - order):(t - 1)]
    xhat <- mu + sum(a * (rev(hist) - mu))
    sigma <- (1 - r) * sigma + r * (xt - xhat)^2
    sigma <- max(sigma, 1e-12)
    scores[t] <- 0.5 * log(2 * pi * sigma) + (xt - xhat)^2 / (2 * sigma)
  }
  scores
}

# Online discounted Holt (level+trend) log-loss scores.
.har_sdar_holt_scores <- function(x, alpha, beta, r) {
  n <- length(x)
  if (n == 0) return(numeric(0))
  level <- x[1]
  trend <- if (n > 1) x[2] - x[1] else 0
  sigma <- 1
  scores <- rep(0, n)
  for (t in seq_len(n)) {
    xt <- x[t]
    if (t <= 2) {
      level <- xt
      next
    }
    xhat <- level + trend
    e <- xt - xhat
    sigma <- (1 - r) * sigma + r * e * e
    sigma <- max(sigma, 1e-12)
    scores[t] <- 0.5 * log(2 * pi * sigma) + e * e / (2 * sigma)
    prev_level <- level
    level <- alpha * xt + (1 - alpha) * (level + trend)
    trend <- beta * (level - prev_level) + (1 - beta) * trend
  }
  scores
}

# Two-stage robust ChangeFinder: SDAR surprise UNION mean+variance break.
# score_fn(x) returns the one-step predictive log-loss of the online model.
.har_robust_changefinder <- function(obj, x, smooth, h, score_fn) {
  n <- length(x)
  smooth <- max(1, as.integer(smooth))

  s1 <- score_fn(x)
  sm1 <- .har_causal_ma(s1, smooth)

  a_out <- obj$har_outliers(sm1)
  anomalies <- obj$har_outliers_check(a_out, sm1, x)
  anomalies[1:smooth] <- FALSE

  s2 <- score_fn(sm1)
  cp_score <- .har_causal_ma(s2, max(1, round(smooth / 2)))

  cp_out <- obj$har_outliers(cp_score)
  cp <- obj$har_outliers_check(cp_out, cp_score, cp_score)
  cp[1:smooth] <- FALSE

  bp <- .har_meanvar_single_break(x, h)
  if (!is.null(bp) && bp >= 1 && bp <= n) cp[bp] <- TRUE
  if (n > 0) cp[1] <- FALSE

  list(anomalies = anomalies, cp = cp, cp_score = cp_score)
}
