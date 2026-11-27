# Native Empirical Mode Decomposition for harbinger.
#
# Self-contained port of the deterministic EMD used across the DAL stack
# (tspredit::emd_decompose), so harbinger no longer depends on `hht`. The
# deterministic engine makes the EMD-based detectors reproducible and keeps
# R<->Python (pyharbinger) parity exact (pytspredit.emd.emd mirrors this code).
#
# `.har_ceemd()` returns a list with the same fields the detectors used from
# hht::CEEMD (imf as a time x IMF matrix, residue, nimf, original.signal).

# Interior local maxima/minima positions (1-based).
.har_emd_extrema <- function(x) {
  d <- diff(x)
  right <- c(d, 0)
  left <- c(0, d)
  list(maxima = which(right < 0 & left > 0),
       minima = which(right > 0 & left < 0))
}

# Cubic-spline envelope through the given extrema (1-based positions), with
# Rilling-style boundary mirroring of the first/last two extrema.
.har_emd_envelope <- function(idx, x, n) {
  i0 <- idx - 1
  v <- x[idx]
  m <- length(i0)
  k <- min(2L, m)
  left_i <- -rev(i0[seq_len(k)])
  left_v <- rev(v[seq_len(k)])
  right_i <- 2 * (n - 1) - rev(i0[(m - k + 1):m])
  right_v <- rev(v[(m - k + 1):m])
  ei <- c(left_i, i0, right_i)
  ev <- c(left_v, v, right_v)
  f <- stats::splinefun(ei, ev, method = "fmm")
  f(0:(n - 1))
}

# EMD: returns a matrix (n_imf x n); rows sum to x (last row is the residual).
.har_emd_decompose <- function(x, max_imf = 12L, sift_max = 100L, sd_tol = 0.2) {
  x <- as.numeric(x)
  n <- length(x)
  imfs <- list()
  residual <- x
  for (mi in seq_len(max_imf)) {
    h <- residual
    for (si in seq_len(sift_max)) {
      ex <- .har_emd_extrema(h)
      if (length(ex$maxima) < 2 || length(ex$minima) < 2) break
      mean_env <- 0.5 * (.har_emd_envelope(ex$maxima, h, n) + .har_emd_envelope(ex$minima, h, n))
      h_next <- h - mean_env
      sd_val <- sum((h - h_next)^2) / (sum(h^2) + 1e-12)
      h <- h_next
      if (sd_val < sd_tol) break
    }
    imfs[[length(imfs) + 1]] <- h
    residual <- residual - h
    ex <- .har_emd_extrema(residual)
    if (length(ex$maxima) + length(ex$minima) < 2) break
  }
  imfs[[length(imfs) + 1]] <- residual
  do.call(rbind, imfs)
}

# CEEMD-compatible wrapper over the deterministic EMD (hht::CEEMD replacement).
.har_ceemd <- function(x) {
  m <- .har_emd_decompose(x)
  k <- nrow(m)
  nimf <- k - 1L
  imf <- t(m[seq_len(nimf), , drop = FALSE])  # time x IMF, matching hht$imf
  list(
    imf = imf,
    residue = m[k, ],
    nimf = nimf,
    original.signal = as.numeric(x)
  )
}
