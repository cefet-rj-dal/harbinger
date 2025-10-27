is_matrix_or_df <- function(obj) {
  is.matrix(obj) || is.data.frame(obj)
}

har_distance_l1 <- function(values) {
  values <- abs(values)
  if (is_matrix_or_df(values))
    values <-rowSums(values)
  return(values)
}

har_distance_l2 <- function(values) {
  values <- values^2
  if (is_matrix_or_df(values))
    values <-rowSums(values)
  return(values)
}

har_outliers_boxplot <- function(res){
  org = length(res)
  cond <- rep(FALSE, org)
  q <- stats::quantile(res, na.rm=TRUE)
  IQR <- q[4] - q[2]
  thresholdInf <- as.double(q[2] - 1.5*IQR)
  thresholdSup <- as.double(q[4] + 1.5*IQR)
  index = which(res > thresholdSup | res < thresholdInf)

  attr(index, "threshold") <- c(thresholdInf, thresholdSup)
  return (index)
}

har_outliers_gaussian <- function(res){
  thresholdSup <- mean(res) + 3*sd(res)
  thresholdInf <- mean(res) - 3*sd(res)
  index <- which(res > thresholdSup | res < thresholdInf)

  attr(index, "threshold") <- c(thresholdInf, thresholdSup)
  return (index)
}

har_outliers_ratio <- function(res){
  ratio <- 1 - res / max(res)
  thresholdSup <- mean(ratio) + 3*sd(ratio)
  thresholdSup <- (thresholdSup - 1) * max(res)
  thresholdInf <- mean(ratio) - 3*sd(ratio)
  thresholdInf <- (thresholdInf - 1) * max(res)
  index <- which(res > thresholdSup | res < thresholdInf)

  attr(index, "threshold") <- c(thresholdInf, thresholdSup)
  return (index)
}

har_outliers_checks_firstgroup <- function(outliers, values) {
  threshold <- attr(outliers, "threshold")
  values <- abs(values)
  if (is_matrix_or_df(values))
    values <-rowSums(values)
  size <- length(values)
  group <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
  outliers <- rep(FALSE, size)
  for (g in group) {
    if (length(g) > 0) {
      i <- min(g)
      outliers[i] <- TRUE
    }
  }
  attr(outliers, "threshold") <- threshold
  return(outliers)
}

har_outliers_checks_highgroup <- function(outliers, values) {
  threshold <- attr(outliers, "threshold")
  values <- abs(values)
  if (is_matrix_or_df(values))
    values <-rowSums(values)
  size <- length(values)
  group <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
  outliers <- rep(FALSE, size)
  for (g in group) {
    if (length(g) > 0) {
      i <- which.max(values[g])
      i <- g[i]
      outliers[i] <- TRUE
    }
  }
  attr(outliers, "threshold") <- threshold
  return(outliers)
}


har_fuzzify_detections_triangle <- function(value, tolerance) {
  type <- attr(value, "type")
  value <- as.double(value)
  if (!tolerance) {
    attr(value, "type") <- type
    return(value)
  }
  idx <- which(value >= 1)
  n <- length(value)
  ratio <- 1/tolerance
  range <- tolerance-1
  for (i in idx) {
    curtype <- ""
    if (!is.null(type))
      curtype <- type[i]
    for (j in 1:range) {
      if (i + j < n) {
        value[i+j] <- value[i+j] + (tolerance - j)*ratio
        type[i+j] <- curtype
      }
      if (i - j > 0) {
        value[i-j] <- value[i-j] + (tolerance - j)*ratio
        type[i-j] <- curtype
      }
    }
  }
  attr(value, "type") <- type
  return(value)
}

#' @title Harbinger Utilities
#' @description
#' Utility object that groups common distance measures, threshold heuristics,
#' and outlier grouping rules used by Harbinger detectors.
#'
#' @details
#' Provided helpers include:
#' - L1 and L2 distance aggregations over vectors or rows of matrices/data frames.
#' - Thresholding heuristics: boxplot-based (IQR), Gaussian 3-sigma, and a ratio-based rule.
#' - Grouping strategies for contiguous outliers: keep first index or keep highest-magnitude index.
#' - Optional fuzzification over detections to propagate influence within a tolerance window.
#'
#' These utilities centralize common tasks and ensure consistent behavior across detectors.
#'
#' @return A `harutils` object exposing the helper functions.
#'
#' @examples
#' # See also ?hanc_ml and ?hanr_ml for end-to-end detector usage where
#' # these utilities are applied internally to compute distances and thresholds.
#'
#' @references
#' - Tukey JW (1977). Exploratory Data Analysis. Addison-Wesley. [boxplot/IQR]
#' - Shewhart WA (1931). Economic Control of Quality of Manufactured Product. D. Van Nostrand. [3-sigma]
#' - Silva, E. P., Balbi, H., Pacitti, E., Porto, F., Santos, J., Ogasawara, E. Cutoff
#'   Frequency Adjustment for FFT-Based Anomaly Detectors. In: Simpósio Brasileiro de
#'   Banco de Dados (SBBD). SBC, 14 Oct. 2024. doi:10.5753/sbbd.2024.243319
#'
#' @importFrom daltoolbox dal_base
#' @importFrom stats quantile
#' @export
harutils <- function() {
  obj <- dal_base()
  class(obj) <- append("harutils", class(obj))
  obj$har_distance_l1 <- har_distance_l1
  obj$har_distance_l2 <- har_distance_l2

  obj$har_outliers_boxplot <- har_outliers_boxplot
  obj$har_outliers_gaussian <- har_outliers_gaussian
  obj$har_outliers_ratio <- har_outliers_ratio

  obj$har_outliers_checks_firstgroup <- har_outliers_checks_firstgroup
  obj$har_outliers_checks_highgroup <- har_outliers_checks_highgroup

  obj$har_fuzzify_detections_triangle <- har_fuzzify_detections_triangle

  return(obj)
}
