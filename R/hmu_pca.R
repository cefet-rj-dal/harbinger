#' @title Multivariate anomaly detector using PCA
#' @description
#' Projects multivariate observations onto principal components and flags
#' large reconstruction errors as anomalies. Based on classical PCA.
#'
#' @details
#' The series is standardized, PCA is computed, and the data are reconstructed
#' from a **reduced** set of principal components. The reconstruction error
#' (the part of the signal not captured by the retained components) is summarized
#' and thresholded as the anomaly score.
#'
#' Keeping *all* components would reconstruct the data exactly, leaving only
#' floating-point round-off as the residual (a degenerate detector). By default
#' `hmu_pca` therefore keeps the leading components that explain `variance` of the
#' total variance, capped at `ncol - 1` so at least one component is always
#' dropped. Pass `num_components` to fix the number of retained components
#' explicitly.
#'
#' @param num_components Integer or `NULL`. Number of principal components to
#'   retain for reconstruction. When `NULL` (default) the number is chosen
#'   automatically from `variance`.
#' @param variance Numeric in (0, 1]. Target cumulative proportion of variance
#'   used to pick `num_components` automatically when it is `NULL`.
#' @return `hmu_pca` object.
#'
#' @examples
#' library(daltoolbox)
#'
#' # Load multivariate example data
#' data(examples_harbinger)
#'
#' # Use a multidimensional time series
#' dataset <- examples_harbinger$multidimensional
#' head(dataset)
#'
#' # Configure PCA-based anomaly detector
#' model <- hmu_pca()
#'
#' # Fit the model (example uses first two columns)
#' model <- fit(model, dataset[,1:2])
#'
#' # Run detection
#' detection <- detect(model, dataset[,1:2])
#'
#' # Show detected anomalies
#' print(detection[(detection$event),])
#'
#' # Evaluate detections
#' evaluation <- evaluate(model, detection$event, dataset$event)
#' print(evaluation$confMatrix)
#'
#' @references
#' - Jolliffe IT (2002). Principal Component Analysis. Springer.
#'
#'@export
hmu_pca <- function(num_components = NULL, variance = 0.9) {
  obj <- harbinger()
  obj$num_components <- num_components
  obj$variance <- variance
  class(obj) <- append("hmu_pca", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom stats princomp
#'@exportS3Method detect hmu_pca
detect.hmu_pca <- function(obj, serie, ...) {
  # Validate input
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  # Standardize the data (mean-centered and scaled to unit variance)
  scaled_data <- base::scale(obj$serie)

  # Perform PCA
  pca_result <- stats::princomp(scaled_data)

  # Choose how many leading components to retain for reconstruction.
  p <- ncol(scaled_data)
  k <- obj$num_components
  if (is.null(k)) {
    var_explained <- pca_result$sdev^2 / sum(pca_result$sdev^2)
    k <- which(cumsum(var_explained) >= obj$variance)[1]
    if (is.na(k)) k <- p
  }
  # Always drop at least one component so the residual is meaningful
  # (keeping all components reconstructs the data exactly -> degenerate).
  k <- max(1, min(k, p - 1))

  # Reconstruct from the retained components only; the discarded components
  # form the reconstruction error used as the anomaly score.
  pcs <- pca_result$scores[, 1:k, drop = FALSE]
  loadings <- pca_result$loadings[, 1:k, drop = FALSE]
  reconstructed_data <- pcs %*% t(loadings)

  # Distance and outlier detection on reconstruction error
  res <- obj$har_distance(scaled_data - reconstructed_data)
  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res, obj$serie)

  # Restore detections to original indexing
  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}


