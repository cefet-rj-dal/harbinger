#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
har_kmeans <- function(seq = 1, centers=NA, alpha=1.5) {
  obj <- harbinger()
  obj$seq <- seq
  obj$centers <- centers
  obj$alpha <- alpha
  class(obj) <- append("har_kmeans", class(obj))
  return(obj)
}

#'@export
fit.har_kmeans <- function(obj, serie) {
  if (is.na(obj$centers))
    obj$centers <- ceiling(log(length(serie), 10))

  data <- ts_data(na.omit(serie), obj$seq)
  data <- as.data.frame(data)

  # Apply k-means
  obj$clusters <- kmeans(data, centers=obj$centers, nstart=1)
  return(obj)
}

#'@export
detect.har_kmeans <- function(obj, serie) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  n <- length(serie)
  non_na <- which(!is.na(serie))
  serie <- na.omit(serie)

  sx <- ts_data(serie, obj$seq)
  data <- as.data.frame(sx)

  distances <- apply(data, 1, function(x) min((rowSums(t(obj$clusters$centers - x)^2))))
  outliers <- outliers.boxplot.index(distances, obj$alpha)

  group_outliers <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
  outliers <- rep(FALSE, length(serie))
  for (g in group_outliers) {
    if (length(g) > 0) {
      i <- min(g)
      outliers[i] <- TRUE
    }
  }

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
