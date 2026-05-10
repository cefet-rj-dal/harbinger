har_candidate_selection_firstgroup <- function(outliers, values) {
  threshold <- attr(outliers, "threshold")
  values <- abs(values)
  if (is_matrix_or_df(values)) values <- rowSums(values)
  values <- as.numeric(values)
  size <- length(values)
  idx <- if (is.logical(outliers)) which(outliers) else as.integer(outliers)
  if (length(idx) == 0) {
    result <- rep(FALSE, size)
    attr(result, "threshold") <- threshold
    return(result)
  }
  groups <- split(idx, cumsum(c(1, diff(idx) != 1)))
  result <- rep(FALSE, size)
  for (g in groups) result[min(g)] <- TRUE
  attr(result, "threshold") <- threshold
  result
}

har_candidate_selection_highgroup <- function(outliers, values) {
  threshold <- attr(outliers, "threshold")
  values <- abs(values)
  if (is_matrix_or_df(values)) values <- rowSums(values)
  values <- as.numeric(values)
  size <- length(values)
  idx <- if (is.logical(outliers)) which(outliers) else as.integer(outliers)
  if (length(idx) == 0) {
    result <- rep(FALSE, size)
    attr(result, "threshold") <- threshold
    return(result)
  }
  groups <- split(idx, cumsum(c(1, diff(idx) != 1)))
  result <- rep(FALSE, size)
  for (g in groups) {
    max_val <- max(values[g])
    candidates <- g[values[g] == max_val]
    result[min(candidates)] <- TRUE
  }
  attr(result, "threshold") <- threshold
  result
}

har_candidate_selection_referencedistribution <- function(
    outliers,
    values,
    history_size = 30,
    distribution = c("gaussian"),
    sigma_level = 3
) {
  threshold <- attr(outliers, "threshold")
  distribution <- match.arg(distribution)
  values <- abs(values)
  if (is_matrix_or_df(values)) values <- rowSums(values)
  values <- as.numeric(values)
  size <- length(values)
  idx <- if (is.logical(outliers)) which(outliers) else as.integer(outliers)
  result <- rep(FALSE, size)

  if (length(idx) == 0) {
    attr(result, "threshold") <- threshold
    return(result)
  }

  groups <- split(idx, cumsum(c(1, diff(idx) != 1)))
  for (g in groups) {
    start_idx <- min(g)
    ref_start <- max(1, start_idx - history_size)
    ref_idx <- ref_start:(start_idx - 1)
    ref_idx <- ref_idx[ref_idx >= 1]
    ref_values <- values[ref_idx]
    ref_values <- ref_values[is.finite(ref_values)]

    if (length(ref_values) < history_size) {
      result[start_idx] <- TRUE
      next
    }

    mu <- mean(ref_values)
    sigma <- stats::sd(ref_values)

    for (candidate_idx in g) {
      candidate_value <- values[candidate_idx]
      if (!is.finite(candidate_value)) next

      # Future extensions can estimate alternative reference distributions here
      # while preserving the same candidate-selection interface.
      is_outlier <- switch(
        distribution,
        gaussian = {
          if (!is.finite(mu)) {
            FALSE
          } else if (!is.finite(sigma) || sigma <= 0) {
            candidate_value != mu
          } else {
            deviation <- abs(candidate_value - mu)
            deviation > sigma_level * sigma
          }
        }
      )

      if (isTRUE(is_outlier)) {
        result[candidate_idx] <- TRUE
      }
    }
  }

  attr(result, "threshold") <- threshold
  result
}

har_fuzzify_detections_triangle <- function(value, tolerance) {
  type <- attr(value, "type")
  value <- as.double(value)
  if (!tolerance || tolerance <= 1) {
    attr(value, "type") <- type
    return(value)
  }
  idx <- which(value >= 1)
  n <- length(value)
  ratio <- 1 / tolerance
  range <- tolerance - 1
  for (i in idx) {
    curtype <- ""
    if (!is.null(type)) curtype <- type[i]
    for (j in 1:range) {
      weight <- (tolerance - j) * ratio
      if (i + j <= n) {
        value[i + j] <- max(value[i + j], weight)
        type[i + j] <- curtype
      }
      if (i - j > 0) {
        value[i - j] <- max(value[i - j], weight)
        type[i - j] <- curtype
      }
    }
  }
  attr(value, "type") <- type
  value
}
