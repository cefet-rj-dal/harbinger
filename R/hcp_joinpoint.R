#' @title Joinpoint Regression++ change-point detector
#' @description
#' Piecewise linear change-point detection based on Joinpoint Regression++.
#'
#' The detector searches for a globally optimal set of joinpoints with dynamic
#' programming, fits linear segments between candidate breaks, and compares
#' models with `0` to `k_max` joinpoints using BIC, BIC3, and a weighted BIC
#' (WBIC) criterion.
#'
#' This implementation is intended for univariate numeric series and follows the
#' same family of ideas used by the National Cancer Institute Joinpoint
#' Regression Program, but it is documented here as a Joinpoint Regression++
#' variant because it replaces brute-force breakpoint enumeration with dynamic
#' programming and weighted model selection while keeping a lightweight
#' Harbinger-compatible API.
#'
#' @param min_between Minimum number of observations between consecutive
#'   joinpoints.
#' @param min_end Minimum number of observations required in the first and last
#'   segments.
#' @param k_max Maximum number of joinpoints considered during model selection.
#' @param log_transform Logical indicating whether the series should be log
#'   transformed before fitting. This is useful for multiplicative trends and
#'   growth-rate interpretation.
#' @return An `hcp_joinpoint` object.
#'
#' @references
#' - Kim HJ, Fay MP, Feuer EJ, Midthune DN (2000). Permutation Tests for
#'   Joinpoint Regression with Applications to Cancer Rates. Statistics in
#'   Medicine, 19(3), 335-351.
#'   <doi:10.1002/(SICI)1097-0258(20000215)19:3<335::AID-SIM336>3.0.CO;2-Z>
#' - Kim HJ, Chen HS, Midthune D, Wheeler B, Buckman DW, Green D, Byrne J, Luo
#'   J, Feuer EJ (2023). Data-driven choice of a model selection method in
#'   joinpoint regression. Journal of Applied Statistics, 50(9), 1992-2013.
#'   <doi:10.1080/02664763.2022.2063265>
#' - National Cancer Institute. Joinpoint Trend Analysis Software.
#'   https://surveillance.cancer.gov/joinpoint/
#'
#' @export
hcp_joinpoint <- function(
    min_between = 2,
    min_end = 2,
    k_max = 5,
    log_transform = FALSE
) {
  if (!is.numeric(min_between) || length(min_between) != 1 || is.na(min_between) || min_between < 1) {
    stop("min_between must be a positive number.", call. = FALSE)
  }
  if (!is.numeric(min_end) || length(min_end) != 1 || is.na(min_end) || min_end < 1) {
    stop("min_end must be a positive number.", call. = FALSE)
  }
  if (!is.numeric(k_max) || length(k_max) != 1 || is.na(k_max) || k_max < 0) {
    stop("k_max must be a non-negative number.", call. = FALSE)
  }
  if (!is.logical(log_transform) || length(log_transform) != 1 || is.na(log_transform)) {
    stop("log_transform must be TRUE or FALSE.", call. = FALSE)
  }

  obj <- harbinger()
  obj$min_between <- as.integer(min_between)
  obj$min_end <- as.integer(min_end)
  obj$k_max <- as.integer(k_max)
  obj$log_transform <- log_transform
  obj$model <- NULL

  class(obj) <- append("hcp_joinpoint", class(obj))
  obj
}

.get_max_jp <- function(n, k_max, min_between, min_end) {
  if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < (2 * min_end)) {
    stop("The series is too short for the requested segment constraints.", call. = FALSE)
  }

  max_possible <- floor((n - 2 * min_end) / min_between)
  max_possible <- max(0, max_possible)

  min(as.integer(k_max), max_possible)
}

.segment_rss <- function(y, x) {
  if (length(y) < 2) return(Inf)
  fit <- stats::lm(y ~ x)
  sum(stats::residuals(fit)^2)
}

.bic <- function(rss, n, k) {
  if (!is.finite(rss) || rss <= 0) return(Inf)
  p <- 2 * k + 2
  log(rss / n) + (p / n) * log(n)
}

.bic3 <- function(rss, n, k) {
  if (!is.finite(rss) || rss <= 0) return(Inf)
  p <- 3 * k + 2
  log(rss / n) + (p / n) * log(n)
}

.weight <- function(y, cps) {
  if (length(cps) == 0) return(0)

  diffs <- numeric()
  for (tau in sort(cps)) {
    idx_left <- seq_len(tau - 1)
    idx_right <- tau:length(y)

    if (length(idx_left) < 3 || length(idx_right) < 3) next

    r1 <- stats::cor(y[idx_left], idx_left)^2
    r2 <- stats::cor(y[idx_right], idx_right)^2
    diffs <- c(diffs, abs(r2 - r1))
  }

  if (length(diffs) == 0) return(0)

  w <- mean(diffs, na.rm = TRUE)
  if (!is.finite(w)) return(0)

  min(max(w, 0), 1)
}

.dp_joinpoints <- function(y, x, max_jp, min_between, min_end) {
  n <- length(y)

  dp_rss <- vector("list", max_jp + 1)
  dp_cps <- vector("list", max_jp + 1)

  for (k in 0:max_jp) {
    dp_rss[[k + 1]] <- rep(Inf, n)
    dp_cps[[k + 1]] <- vector("list", n)
  }

  for (j in seq_len(n)) {
    if (j >= min_end) {
      dp_rss[[1]][j] <- .segment_rss(y[1:j], x[1:j])
      dp_cps[[1]][[j]] <- integer(0)
    }
  }

  for (k in 1:max_jp) {
    min_j <- max(min_end + min_between, 2 * min_end)

    for (j in min_j:n) {
      best_rss <- Inf
      best_cps <- integer(0)

      i_min <- min_end + 1
      i_max <- j - min_end + 1 - 1
      if (i_min > i_max) next

      for (i in i_min:i_max) {
        segment_length <- j - i + 1
        if (segment_length < min_end) next

        prev_cps <- dp_cps[[k]][[i - 1]]
        prev_rss <- dp_rss[[k]][i - 1]
        if (!is.finite(prev_rss)) next
        if (length(prev_cps) > 0 && (i - utils::tail(prev_cps, 1)) < min_between) next

        seg_rss <- .segment_rss(y[i:j], x[i:j])
        total_rss <- prev_rss + seg_rss

        if (total_rss < best_rss) {
          best_rss <- total_rss
          best_cps <- c(prev_cps, i)
        }
      }

      dp_rss[[k + 1]][j] <- best_rss
      dp_cps[[k + 1]][[j]] <- best_cps
    }
  }

  list(rss = dp_rss, cps = dp_cps)
}

#' @importFrom stats cor
#' @importFrom stats lm
#' @importFrom stats residuals
#' @exportS3Method fit hcp_joinpoint
fit.hcp_joinpoint <- function(obj, serie, ...) {
  if (is.null(serie)) stop("No data was provided.", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)
  y <- obj$serie
  x <- seq_along(y)

  if (!is.numeric(y)) stop("serie must be numeric.", call. = FALSE)
  if (anyNA(y)) stop("hcp_joinpoint does not accept missing values.", call. = FALSE)
  if (length(y) < (2 * obj$min_end)) {
    stop("The series is too short for the requested min_end value.", call. = FALSE)
  }
  if (isTRUE(obj$log_transform)) {
    if (any(y <= 0)) {
      stop("log_transform = TRUE requires strictly positive values.", call. = FALSE)
    }
    y <- log(y)
  }

  max_jp <- .get_max_jp(length(y), obj$k_max, obj$min_between, obj$min_end)
  dp <- .dp_joinpoints(
    y = y,
    x = x,
    max_jp = max_jp,
    min_between = obj$min_between,
    min_end = obj$min_end
  )

  comparison <- data.frame(
    k = 0:max_jp,
    RSS = NA_real_,
    BIC = NA_real_,
    BIC3 = NA_real_,
    Weight = NA_real_,
    WBIC = NA_real_
  )
  best_models <- vector("list", max_jp + 1)

  for (k in 0:max_jp) {
    cps <- dp$cps[[k + 1]][[length(y)]]
    rss <- dp$rss[[k + 1]][length(y)]

    bic <- .bic(rss, length(y), k)
    bic3 <- .bic3(rss, length(y), k)
    w <- .weight(y, cps)
    wbic <- (1 - w) * bic + w * bic3

    comparison$RSS[k + 1] <- rss
    comparison$BIC[k + 1] <- bic
    comparison$BIC3[k + 1] <- bic3
    comparison$Weight[k + 1] <- w
    comparison$WBIC[k + 1] <- wbic
    best_models[[k + 1]] <- cps
  }

  valid <- which(is.finite(comparison$WBIC))
  if (length(valid) == 0) {
    stop("No valid joinpoint model could be fitted with the current constraints.", call. = FALSE)
  }

  best_k <- valid[which.min(comparison$WBIC[valid])] - 1

  obj$model <- list(
    cps = best_models[[best_k + 1]],
    k = best_k,
    comparison = comparison
  )

  obj
}

#' @exportS3Method detect hcp_joinpoint
detect.hcp_joinpoint <- function(obj, serie, ...) {
  if (is.null(serie)) stop("No data was provided.", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)
  obj <- fit(obj, obj$serie)

  n <- length(obj$serie)
  cp <- rep(FALSE, n)
  cps <- obj$model$cps

  if (length(cps) > 0) {
    cps <- unique(as.integer(round(cps)))
    cps <- cps[cps >= 1 & cps <= n]
    cp[cps] <- TRUE
  }

  obj$har_restore_refs(obj, change_points = cp)
}
