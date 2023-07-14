#'@title Anomaly detector using DTW
#'@description Anomaly detection using DTW
#'The DTW is applied to the time series.
#'When seq equals one, observations distant from the closest centroids are labeled as anomalies.
#'When seq is grater than one, sequences distant from the closest centroids are labeled as discords.
#'It wraps the tsclust presented in the dtwclust library.
#'@param seq sequence size
#'@param centers number of centroids
#'@return `hanr_dtw` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(har_examples)
#'
#'#Using example 1
#'dataset <- har_examples$example1
#'head(dataset)
#'
#'# setting up time series regression model
#'model <- hanr_dtw()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
# making detection using hanr_ml
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection |> dplyr::filter(event==TRUE))
#'
#'@export
hanr_dtw <- function(seq = 1, centers=NA) {
  obj <- harbinger()
  obj$seq <- seq
  obj$centers <- centers

  class(obj) <- append("hanr_dtw", class(obj))
  return(obj)
}

#'@importFrom dtwclust tsclust
#'@importFrom stats na.omit
#'@export
fit.hanr_dtw <- function(obj, serie, ...) {
  if (is.na(obj$centers))
    obj$centers <- ceiling(log(length(serie), 10))

  data <- ts_data(stats::na.omit(serie), obj$seq)
  data <- as.data.frame(data)

  # Apply k-means
  clusters <- dtwclust::tsclust(series = data, type = "partitional", k = obj$centers, distance = "dtw_basic")
  centroids <- NULL
  for (i in 1:length(clusters@centroids))
    centroids <- rbind(centroids, clusters@centroids[[i]])
  obj$centroids <- centroids
  return(obj)
}

#'@importFrom stats na.omit
#'@export
detect.hanr_dtw <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  n <- length(serie)
  non_na <- which(!is.na(serie))
  serie <- stats::na.omit(serie)

  sx <- ts_data(serie, obj$seq)
  data <- as.data.frame(sx)

  distances <- obj$har_residuals(apply(data, 1, function(x) sqrt(min((rowSums(t(obj$centroids - x)^2))))))
  outliers <- obj$har_outliers_idx(distances)
  outliers <- obj$har_outliers_group(as.integer(outliers + obj$seq/2), length(serie))

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
