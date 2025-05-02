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

har_outliers_boxplot <- function(data){
  org = length(data)
  cond <- rep(FALSE, org)
  q = stats::quantile(data, na.rm=TRUE)
  IQR = q[4] - q[2]
  lq1 = as.double(q[2] - 1.5*IQR)
  hq3 = as.double(q[4] + 1.5*IQR)
  index <- which(data < lq1 | data > hq3)
  return (index)
}

har_outliers_gaussian <- function(data){
  index <- which(data > mean(data) + 3*sd(data) | data < mean(data) - 3*sd(data))
  return (index)
}

har_outliers_ratio <- function(data){
  ratio <- 1 - data / max(data)
  z <- (ratio - mean(ratio)) / sd(ratio)
  index <- which(abs(z) > 3)
  return(index)
}


har_outliers_classification <- function(data) {
  index <- which(data >= 0.5) # non-event versus anomaly
  return (index)
}

har_outliers_checks_firstgroup <- function(outliers, values) {
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
  return(outliers)
}

har_outliers_checks_highgroup <- function(outliers, values) {
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

#'@title Harbinger Utils
#'@description Utility class that contains major distance measures,
#'threshold limits, and outliers grouping functions
#'@return Harbinger Utils
#'@examples
#'# See ?hanc_ml for an example of anomaly detection using machine learning classification
#'@import daltoolbox
#'@importFrom stats quantile
#'@export
harutils <- function() {
  obj <- dal_base()
  class(obj) <- append("harutils", class(obj))
  obj$har_distance_l1 <- har_distance_l1
  obj$har_distance_l2 <- har_distance_l2

  obj$har_outliers_boxplot <- har_outliers_boxplot
  obj$har_outliers_gaussian <- har_outliers_gaussian
  obj$har_outliers_ratio <- har_outliers_ratio
  obj$har_outliers_classification <- har_outliers_classification

  obj$har_outliers_checks_firstgroup <- har_outliers_checks_firstgroup
  obj$har_outliers_checks_highgroup <- har_outliers_checks_highgroup

  obj$har_fuzzify_detections_triangle <- har_fuzzify_detections_triangle

  return(obj)
}