har_filter_none <- function(res) {
  index <- integer(0)
  attr(index, "threshold") <- c(-Inf, Inf)
  index
}

har_filter_boxplot <- function(res) {
  q <- stats::quantile(res, na.rm = TRUE)
  iqr <- q[4] - q[2]
  thresholdInf <- as.double(q[2] - 1.5 * iqr)
  thresholdSup <- as.double(q[4] + 1.5 * iqr)
  index <- which(res > thresholdSup | res < thresholdInf)
  attr(index, "threshold") <- c(thresholdInf, thresholdSup)
  index
}

har_filter_gaussian <- function(res) {
  thresholdSup <- mean(res) + 3 * stats::sd(res)
  thresholdInf <- mean(res) - 3 * stats::sd(res)
  index <- which(res > thresholdSup | res < thresholdInf)
  attr(index, "threshold") <- c(thresholdInf, thresholdSup)
  index
}

har_filter_grubbs <- function(res, alpha = 0.05, two.sided = TRUE) {
  values <- as.numeric(res)
  valid <- which(is.finite(values))
  selected <- integer(0)
  threshold <- c(NA_real_, NA_real_)
  scores <- rep(NA_real_, length(values))

  if (length(valid) < 3) {
    index <- integer(0)
    attr(index, "threshold") <- threshold
    attr(index, "score") <- scores
    return(index)
  }

  remaining <- valid
  repeat {
    current <- values[remaining]
    n <- length(current)
    if (n < 3) break

    mu <- mean(current)
    sigma <- stats::sd(current)
    if (!is.finite(sigma) || sigma <= 0) break

    deviation <- abs(current - mu)
    pos <- which.max(deviation)
    g_stat <- deviation[pos] / sigma

    alpha_adj <- if (two.sided) alpha / (2 * n) else alpha / n
    t_crit <- stats::qt(1 - alpha_adj, df = n - 2)
    g_crit <- ((n - 1) / sqrt(n)) * sqrt(t_crit^2 / (n - 2 + t_crit^2))

    if (!is.finite(g_stat) || !is.finite(g_crit) || g_stat <= g_crit) break

    idx <- remaining[pos]
    scores[idx] <- g_stat
    selected <- c(selected, idx)

    candidate <- values[idx]
    # Store an empirical, plot-friendly cutoff: the least extreme detected
    # value on each side is kept as the final threshold summary.
    if (candidate >= mu) {
      threshold[2] <- if (is.na(threshold[2])) candidate else min(threshold[2], candidate)
    } else {
      threshold[1] <- if (is.na(threshold[1])) candidate else max(threshold[1], candidate)
    }

    remaining <- remaining[-pos]
  }

  selected <- sort(selected)
  attr(selected, "threshold") <- threshold
  attr(selected, "score") <- scores
  selected
}

har_filter_ratio <- function(res) {
  if (length(res) == 0) {
    index <- integer(0)
    attr(index, "threshold") <- c(NA_real_, NA_real_)
    return(index)
  }

  max_res <- max(res, na.rm = TRUE)
  if (!is.finite(max_res) || max_res <= 0) {
    index <- integer(0)
    attr(index, "threshold") <- c(NA_real_, NA_real_)
    return(index)
  }

  ratio <- 1 - res / max_res
  thresholdSup <- mean(ratio) + 3 * stats::sd(ratio)
  thresholdSup <- (thresholdSup - 1) * max_res
  thresholdInf <- mean(ratio) - 3 * stats::sd(ratio)
  thresholdInf <- (thresholdInf - 1) * max_res
  index <- which(res > thresholdSup | res < thresholdInf)
  attr(index, "threshold") <- c(thresholdInf, thresholdSup)
  index
}
