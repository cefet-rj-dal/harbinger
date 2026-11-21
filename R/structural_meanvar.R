#' Mean+variance structural-change helpers (native, no strucchange dependency)
#'
#' Internal helpers shared by \code{hcp_chow} and \code{hcp_gft}. They implement
#' the "++" re-engineering of the \code{strucchange} structural-break backend:
#' the original least-squares (mean-only) criterion is generalised to a Gaussian
#' \emph{mean + variance} segmentation cost, so breaks in scale/variance regimes
#' (not only in the mean/trend) are detected. See \code{hcp_gft} / \code{hcp_chow}
#' for the references.
#'
#' These functions mirror, line for line, the canonical Python implementation in
#' the \code{pyharbinger} package (\code{changepoint.py}: \code{_mv_prefix},
#' \code{_meanvar_breakpoints}, \code{_meanvar_single_break}), so the two packages
#' produce identical detections.
#'
#' @keywords internal
#' @noRd
NULL

# Prefix sums for O(1) OLS (y ~ t) RSS of a 1-based segment i..j, scalar + vector.
.har_mv_prefix <- function(y) {
  n <- length(y)
  x <- seq_len(n)
  sx <- c(0, cumsum(x))
  sy <- c(0, cumsum(y))
  sxx <- c(0, cumsum(x * x))
  syy <- c(0, cumsum(y * y))
  sxy <- c(0, cumsum(x * y))

  # Residual sum of squares of the trend fit on segment i..j (scalar i, j).
  rss <- function(i, j) {
    m <- j - i + 1
    if (m <= 0) return(0)
    a <- sx[j + 1] - sx[i]
    b <- sy[j + 1] - sy[i]
    sxxc <- (sxx[j + 1] - sxx[i]) - a * a / m
    syyc <- (syy[j + 1] - syy[i]) - b * b / m
    sxyc <- (sxy[j + 1] - sxy[i]) - a * b / m
    r <- if (sxxc <= 0) syyc else syyc - sxyc * sxyc / sxxc
    max(r, 0)
  }

  # Vectorised over a vector of left endpoints i at a fixed right endpoint j.
  rss_vec <- function(i, j) {
    m <- j - i + 1
    a <- sx[j + 1] - sx[i]
    b <- sy[j + 1] - sy[i]
    sxxc <- (sxx[j + 1] - sxx[i]) - a * a / m
    syyc <- (syy[j + 1] - syy[i]) - b * b / m
    sxyc <- (sxy[j + 1] - sxy[i]) - a * b / m
    denom <- ifelse(sxxc <= 0, 1, sxxc)
    r <- ifelse(sxxc <= 0, syyc, syyc - sxyc * sxyc / denom)
    pmax(r, 0)
  }

  # Vectorised over a vector of right endpoints j at a fixed left endpoint i.
  rss_vec_right <- function(i, j) {
    m <- j - i + 1
    a <- sx[j + 1] - sx[i]
    b <- sy[j + 1] - sy[i]
    sxxc <- (sxx[j + 1] - sxx[i]) - a * a / m
    syyc <- (syy[j + 1] - syy[i]) - b * b / m
    sxyc <- (sxy[j + 1] - sxy[i]) - a * b / m
    denom <- ifelse(sxxc <= 0, 1, sxxc)
    r <- ifelse(sxxc <= 0, syyc, syyc - sxyc * sxyc / denom)
    pmax(r, 0)
  }

  list(rss = rss, rss_vec = rss_vec, rss_vec_right = rss_vec_right, n = n)
}

# Gaussian mean+variance ML deviance of a segment: m * log(RSS / m).
.har_mv_seg_cost <- function(r, m) {
  m * log(pmax(r, 1e-12) / m)
}

# Model-selection penalty for m breaks ((m+1) segments; k trend + 1 variance each).
# "lwz" = conservative Liu-Wu-Zidek criterion; "bic" = log(n) * p.
.har_break_penalty <- function(n, m, kind = "lwz", k = 2) {
  p <- (m + 1) * (k + 1) + m
  if (kind == "lwz") {
    return(0.299 * (log(n)^2.1) * p)
  }
  log(n) * p
}

# Bai-Perron breakpoints under the mean+variance cost (1-based), LWZ/BIC selected.
.har_meanvar_breakpoints <- function(y, h_frac = 0.15, penalty = "lwz") {
  pf <- .har_mv_prefix(y)
  n <- pf$n
  h <- floor(n * h_frac)
  if (h < 1) return(integer(0))
  max_m <- n %/% h - 1
  if (max_m < 1) return(integer(0))

  # opt[m+1, j+1] = min total deviance of j points with m breaks; prev = argmin b.
  opt <- matrix(Inf, nrow = max_m + 1, ncol = n + 1)
  prev <- matrix(-1L, nrow = max_m + 1, ncol = n + 1)
  for (j in h:n) {
    opt[1, j + 1] <- .har_mv_seg_cost(pf$rss(1, j), j)
  }
  for (m in 1:max_m) {
    for (j in ((m + 1) * h):n) {
      b <- (m * h):(j - h)
      prev_cost <- opt[m, b + 1]
      finite <- is.finite(prev_cost)
      if (!any(finite)) next
      seg <- .har_mv_seg_cost(pf$rss_vec(b + 1, j), j - b)
      total <- ifelse(finite, prev_cost + seg, Inf)
      k <- which.min(total)
      opt[m + 1, j + 1] <- total[k]
      prev[m + 1, j + 1] <- b[k]
    }
  }

  best_m <- 0
  best_crit <- opt[1, n + 1] + .har_break_penalty(n, 0, penalty)
  for (m in 1:max_m) {
    if (!is.finite(opt[m + 1, n + 1])) next
    crit <- opt[m + 1, n + 1] + .har_break_penalty(n, m, penalty)
    if (crit < best_crit) {
      best_crit <- crit
      best_m <- m
    }
  }

  cps <- integer(0)
  j <- n
  m <- best_m
  while (m > 0) {
    b <- prev[m + 1, j + 1]
    cps <- c(cps, b)
    j <- b
    m <- m - 1
  }
  sort(cps)
}

# Single break maximising the Gaussian mean+variance log-likelihood ratio (1-based).
.har_meanvar_single_break <- function(y, h_frac = 0.15) {
  pf <- .har_mv_prefix(y)
  n <- pf$n
  h <- floor(n * h_frac)
  if (h < 1 || h > n - h) return(NULL)
  full <- .har_mv_seg_cost(pf$rss(1, n), n)
  i <- h:(n - h)
  if (length(i) == 0) return(NULL)
  left <- .har_mv_seg_cost(pf$rss_vec_right(1, i), i)
  right <- .har_mv_seg_cost(pf$rss_vec(i + 1, n), n - i)
  lr <- full - (left + right)
  i[which.max(lr)]
}
