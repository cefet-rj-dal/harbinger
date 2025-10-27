#' @title Multivariate anomaly detector using PCA
#' @description
#' Projects multivariate observations onto principal components and flags
#' large reconstruction errors as anomalies. Based on classical PCA.
#'
#' @details
#' The series is standardized, PCA is computed, and data are reconstructed from
#' principal components. The reconstruction error is summarized and thresholded.
#'
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
hmu_pca <- function() {
  obj <- harbinger()
  class(obj) <- append("hmu_pca", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom stats princomp
#'@exportS3Method detect hmu_pca
detect.hmu_pca <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  # Standardize the data (mean-centered and scaled to unit variance)
  scaled_data <- base::scale(obj$serie)

  # Perform PCA
  pca_result <- stats::princomp(scaled_data)

  # Get the principal components and their loadings
  pcs <- pca_result$scores
  loadings <- pca_result$loadings

  # Calculate the residuals
  reconstructed_data <- pcs %*% t(loadings)

  res <- obj$har_distance(scaled_data - reconstructed_data)
  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}


