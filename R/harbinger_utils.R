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
  cond = data > hq3
  index = which(cond)
  return (index)
}

har_outliers_gaussian <- function(data){
  index <- which(data > mean(data) + 3*sd(data))
  return (index)
}

har_outliers_ratio <- function(data){
  ratio <- 1 - data / max(data)
  index <- which(ratio < 3*sd(ratio))
  return (index)
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
  return(obj)
}



