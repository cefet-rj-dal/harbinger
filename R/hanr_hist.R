#' @title Anomaly detector using histograms
#' @description
#' Flags observations that fall into low-density histogram bins or outside the
#' observed bin range.
#'
#' @param density_threshold Numeric in [0,1]. Minimum bin density to avoid being
#'   considered an anomaly (default 0.05).
#' @return `hanr_histogram` object
#'
#' @examples
#' library(daltoolbox)
#'
#' # Load anomaly example data
#' data(examples_anomalies)
#'
#' # Use a simple example
#' dataset <- examples_anomalies$simple
#' head(dataset)
#'
#' # Configure histogram-based detector
#' model <- hanr_histogram()
#'
#' # Fit the model (no-op)
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected anomalies
#' print(detection[(detection$event),])
#'
#' @references
#' - Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. 1st ed.
#'   Cham: Springer Nature Switzerland, 2025. doi:10.1007/978-3-031-75941-3
#'
#'@export
hanr_histogram <- function(density_threshold = 0.05) {
  obj <- harbinger()
  obj$density_threshold <- density_threshold

  class(obj) <- append("hanr_histogram", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom graphics hist
#'@exportS3Method detect hanr_histogram
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
