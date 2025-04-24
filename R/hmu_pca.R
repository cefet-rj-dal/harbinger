#'@title Multivariate anomaly detector using PCA
#'@description Multivariate anomaly detector using PCA <doi:10.1016/0098-3004(93)90090-R>
#'@return `hmu_pca` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(examples_harbinger)
#'
#'#Using the time series 9
#'dataset <- examples_harbinger$multidimensional
#'head(dataset)
#'
#'# establishing hmu_pca method
#'model <- hmu_pca()
#'
#'# fitting the model using the two columns of the dataset
#'model <- fit(model, dataset[,1:2])
#'
#'# making detections
#'detection <- detect(model, dataset[,1:2])
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'
#'# evaluating the detections
#'evaluation <- evaluate(model, detection$event, dataset$event)
#'print(evaluation$confMatrix)
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


