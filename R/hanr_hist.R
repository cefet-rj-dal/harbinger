#'@title Anomaly detector using histogram
#'@description Anomaly detector using histogram
#'@param density_threshold It is the minimum frequency for a bin to not be considered an anomaly. Default value is 5%.
#'@return hanr_histogram object
#'histogram based method to detect anomalies in time series. Bins with smaller amount of observations are considered anomalies. Values below first bin or above last bin are also considered anomalies.>.
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(examples_anomalies)
#'
#'#Using simple example
#'dataset <- examples_anomalies$simple
#'head(dataset)
#'
#'# setting up time series regression model
#'model <- hanr_histogram()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
# making detection using hanr_ml
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'
#'@export
hanr_histogram <- function(density_threshold = 0.05) {
  obj <- harbinger()
  obj$density_threshold <- density_threshold

  class(obj) <- append("hanr_histogram", class(obj))
  return(obj)
}

#'@import daltoolbox
#'@importFrom stats na.omit
#'@importFrom graphics hist
#'@export
detect.hanr_histogram <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  hist_data <- graphics::hist(obj$serie, plot = FALSE)

  # Calculate bin edges and midpoints
  bin_edges <- hist_data$breaks

  # Detect anomalies based on the histogram
  anomalies <- rep(FALSE, length(obj$serie))
  for (i in 1:length(obj$serie)) {
    # Find the bin to which the data point belongs
    bin_index <- findInterval(obj$serie[i], bin_edges)

    # Calculate the expected range (bin boundaries)
    if (bin_index < 1)
      bin_index <- 1
    lower_bound <- bin_edges[bin_index]
    if (bin_index < length(bin_edges))
      upper_bound <- bin_edges[bin_index+1]
    else
      upper_bound <- bin_edges[bin_index]

    # Check if the data point is outside the expected range
    if (obj$serie[i] < lower_bound || obj$serie[i] > upper_bound || hist_data$density[bin_index] < obj$density_threshold) {
      anomalies[i] <- TRUE
    }
  }

  detection <- obj$har_restore_refs(obj, anomalies = anomalies)

  return(detection)
}
