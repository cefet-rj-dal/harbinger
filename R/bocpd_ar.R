#' BOCPD "++" helpers (native autoregressive UPM, no ocp dependency)
#'
#' Internal helpers for \code{hcp_bocpd}. They implement the "++" re-engineering
#' of Bayesian Online Change Point Detection (Adams & MacKay 2007): the
#' run-length posterior recursion with a conjugate Bayesian autoregressive UPM
#' (a linear regression of x_t on its lags, Normal-Inverse-Gamma -> Student-t),
#' carried in log-space with eps-pruning, and change points read from the
#' Bayesian predictive surprise via a causal robust local z-score.
#'
#' These functions mirror, line for line, the canonical Python implementation in
#' the \code{pyharbinger} package (\code{changepoint.py}: \code{_bocpd_ar_surprise},
#' \code{_bocpd_local_z}, \code{_bocpd_peaks}), so the two packages produce
#' identical detections.
#'
#' @keywords internal
#' @noRd
NULL

# log(sum(exp(v))) computed stably.
.har_logsumexp <- function(v) {
  m <- max(v)
  if (!is.finite(m)) return(m)
  m + log(sum(exp(v - m)))
}

# Run-length posterior recursion with a Bayesian AR(order)+intercept UPM.
# Returns the per-step Bayesian surprise -log p(x_t | x_{1:t-1}).
.har_bocpd_ar_surprise <- function(serie, order, hazard, lam0, a0, b0, prune_eps) {
  x <- as.numeric(serie)
  n <- length(x)
  d <- order + 1L
  log_h <- log(1 / hazard)
  log_1mh <- log1p(-1 / hazard)
  lam_prior <- lam0 * diag(d)

  # Run-length state: log-posterior + per-run-length regression statistics.
  log_r <- 0                       # r=0 is certain before any data
  lam <- list(lam_prior)           # list of (d,d) posterior precision matrices
  eta <- matrix(0, 1L, d)          # Lambda0 mu0 + sum(phi*y), mu0 = 0
  ssy <- 0                         # sum(y^2)
  cnt <- 0                         # points in the segment
  surprise <- numeric(n)

  for (t in seq_len(n)) {
    xt <- x[t]
    phi <- rep(1, d)
    if (order >= 1L) {
      for (j in seq_len(order)) {
        phi[j + 1L] <- if (t - j >= 1L) x[t - j] else 0
      }
    }

    R <- length(lam)
    log_pred <- numeric(R)
    for (r in seq_len(R)) {
      laminv <- solve(lam[[r]])
      mu_n <- as.numeric(laminv %*% eta[r, ])
      a_n <- a0 + cnt[r] / 2
      b_n <- max(b0 + 0.5 * (ssy[r] - sum(mu_n * eta[r, ])), 1e-12)
      mean_p <- sum(mu_n * phi)
      var_p <- (b_n / a_n) * (1 + as.numeric(phi %*% laminv %*% phi))
      nu <- 2 * a_n
      log_pred[r] <- lgamma(nu / 2 + 0.5) - lgamma(nu / 2) -
        0.5 * log(nu * pi * var_p) -
        (nu + 1) / 2 * log1p((xt - mean_p)^2 / (nu * var_p))
    }

    log_evidence <- .har_logsumexp(log_r + log_pred)
    surprise[t] <- -log_evidence
    new_log_r <- c(log_h + log_evidence, log_r + log_pred + log_1mh)
    new_log_r <- new_log_r - .har_logsumexp(new_log_r)

    # Grow the sufficient statistics (prior prepended = the reset hypothesis).
    pp <- outer(phi, phi)
    lam <- c(list(lam_prior), lapply(lam, function(m) m + pp))
    eta <- rbind(rep(0, d), eta + matrix(phi * xt, R, d, byrow = TRUE))
    ssy <- c(0, ssy + xt * xt)
    cnt <- c(0, cnt + 1)

    # eps-pruning: keep run lengths within prune_eps of the peak mass.
    keep <- which(new_log_r >= max(new_log_r) + log(prune_eps))
    log_r <- new_log_r[keep]
    log_r <- log_r - .har_logsumexp(log_r)
    lam <- lam[keep]
    eta <- eta[keep, , drop = FALSE]
    ssy <- ssy[keep]
    cnt <- cnt[keep]
  }

  surprise
}

# Causal robust local z-score (trailing median/MAD window).
.har_bocpd_local_z <- function(score, window) {
  n <- length(score)
  z <- numeric(n)
  for (t in seq_len(n)) {
    seg <- score[max(1L, t - window):t]
    med <- median(seg)
    madv <- median(abs(seg - med)) + 1e-9
    z[t] <- (score[t] - med) / (1.4826 * madv)
  }
  z
}

# Local-maximum peaks above threshold, thinned by min_distance (strongest first).
.har_bocpd_peaks <- function(score, threshold, min_distance, burn_in) {
  n <- length(score)
  s <- as.numeric(score)
  if (burn_in > 0) s[seq_len(min(burn_in, n))] <- -Inf
  cand <- integer(0)
  for (t in seq_len(n)) {
    lo <- max(1L, t - 1L)
    hi <- min(n, t + 1L)
    if (s[t] >= threshold && s[t] >= max(s[lo:hi])) cand <- c(cand, t)
  }
  cand <- cand[order(-s[cand])]
  kept <- integer(0)
  for (t in cand) {
    if (all(abs(t - kept) >= min_distance)) kept <- c(kept, t)
  }
  event <- rep(FALSE, n)
  event[kept] <- TRUE
  event
}
