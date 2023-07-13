#'@title Anomaly detector using kmeans
#'@description Anomaly detector using kmeans
#'@param seq Sequence size
#'@param centers Number of centroids
#'@param alpha Threshold for outliers
#'@return hanr_kmeans object
#'@examples detector <- harbinger()
#'@export
hanr_kmeans <- function(seq = 1, centers=NA, alpha=1.5) {
  obj <- harbinger()
  obj$seq <- seq
  obj$centers <- centers
  obj$alpha <- alpha
  class(obj) <- append("hanr_kmeans", class(obj))
  return(obj)
}

#'@importFrom stats kmeans
#'@importFrom stats na.omit
#'@export
fit.hanr_kmeans <- function(obj, serie, ...) {
  if (is.na(obj$centers))
    obj$centers <- ceiling(log(length(serie), 10))

  data <- ts_data(stats::na.omit(serie), obj$seq)
  data <- as.data.frame(data)

  # Apply k-means
  obj$clusters <- stats::kmeans(data, centers=obj$centers, nstart=1)
  return(obj)
}

#'@importFrom stats na.omit
#'@export
detect.hanr_kmeans <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  n <- length(serie)
  non_na <- which(!is.na(serie))
  serie <- stats::na.omit(serie)

  sx <- ts_data(serie, obj$seq)
  data <- as.data.frame(sx)

  distances <- obj$har_residuals(apply(data, 1, function(x) sqrt(min((rowSums(t(obj$clusters$centers - x)^2))))))
  outliers <- obj$har_outliers_idx(distances, obj$alpha)
  outliers <- obj$har_outliers_group(outliers, length(serie))

  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  if (obj$seq == 1) {
    detection <- data.frame(idx=1:length(serie), event = i_outliers, type="")
    detection$type[i_outliers] <- "anomaly"
  }
  else {
    detection <- data.frame(idx=1:length(serie), event = i_outliers, type="", seq=NA, seqlen = NA)
    detection$type[i_outliers] <- "discord"
    detection$seq[i_outliers] <- obj$seq
    detection$seqlen[i_outliers] <- obj$seq
  }

  return(detection)
}
