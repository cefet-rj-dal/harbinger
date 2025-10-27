#'@title Anomaly detector using DTW
#'@description Anomaly detection using DTW
#'The DTW is applied to the time series.
#'When seq equals one, observations distant from the closest centroids are labeled as anomalies.
#'When seq is grater than one, sequences distant from the closest centroids are labeled as discords.
#'It wraps the tsclust presented in the dtwclust library.
#'@param seq sequence size
#'@param centers number of centroids
#'@return `hanct_dtw` object
#'@examples
#'library(daltoolbox)
#'
#' # Load anomaly example data
#' data(examples_anomalies)
#'
#' # Use a simple example
#' dataset <- examples_anomalies$simple
#' head(dataset)
#'
#' # Configure DTW-based detector
#' model <- hanct_dtw()
#'
#' # Fit the model
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected events
#' print(detection[(detection$event),])
#'
#' @references
#' - Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. 1st ed.
#'   Cham: Springer Nature Switzerland, 2025. doi:10.1007/978-3-031-75941-3
#'
#'@export
hanct_dtw <- function(seq = 1, centers=NA) {
  obj <- harbinger()
  obj$seq <- seq
  obj$centers <- centers

  class(obj) <- append("hanct_dtw", class(obj))
  return(obj)
}

#'@importFrom dtwclust tsclust
#'@importFrom stats na.omit
#'@exportS3Method fit hanct_dtw
fit.hanct_dtw <- function(obj, serie, ...) {
  if (is.na(obj$centers))
    obj$centers <- ceiling(log(length(serie), 10))

  # Build sliding windows for sequence clustering
  data <- tspredit::ts_data(stats::na.omit(serie), obj$seq)
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
#'@exportS3Method detect hanct_dtw
detect.hanct_dtw <- function(obj, serie, ...) {
  # Validate input
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  # Compute distance from nearest DTW centroid per window
  sx <- tspredit::ts_data(obj$serie, obj$seq)
  data <- as.data.frame(sx)

  res <- apply(data, 1, function(x) sqrt(min((rowSums(t(obj$centroids - x)^2)))))
  res <- obj$har_distance(res)
  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)
  threshold <- attr(anomalies, "threshold")

  res <- c(rep(0, obj$seq - 1), res)
  anomalies <- c(rep(FALSE, obj$seq - 1), anomalies)
  attr(anomalies, "threshold") <- threshold
  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  if (obj$seq != 1) {
    i <- detection$type=="anomaly"
    detection$type[i] <- "discord"
    detection$seq[i] <- obj$seq
    detection$seqlen[i] <- obj$seq
  }

  return(detection)
}
