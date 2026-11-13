#' @title Anomaly detector using histograms
#' @description
#' Flags observations that fall into low-density histogram bins or outside the
#' observed bin range.
#'
#' @param density_threshold Numeric between 0 and 1. Minimum bin density to avoid being
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
  # Validate input
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  # Estimate histogram structure (bins and densities)
  hist_data <- graphics::hist(obj$serie, plot = FALSE)

  # Calculate bin edges
  bin_edges <- hist_data$breaks
  n_bins <- length(hist_data$density)

  # Detect anomalies based on bin membership and density threshold
  anomalies <- rep(FALSE, length(obj$serie))
  for (i in seq_along(obj$serie)) {
    # Keep observations on the outer breaks inside the first/last density bin.
    # findInterval() otherwise maps the maximum break to length(bin_edges),
    # which is one position beyond hist_data$density.
    bin_index <- findInterval(obj$serie[i], bin_edges, all.inside = TRUE)
    bin_index <- min(max(bin_index, 1L), n_bins)

    lower_bound <- bin_edges[bin_index]
    upper_bound <- bin_edges[bin_index + 1L]

    # Outside any bin or underdensity => anomaly
    if (obj$serie[i] < lower_bound || obj$serie[i] > upper_bound || hist_data$density[bin_index] < obj$density_threshold) {
      anomalies[i] <- TRUE
    }
  }

  # Restore detections to original indexing
  detection <- obj$har_restore_refs(obj, anomalies = anomalies)

  return(detection)
}
