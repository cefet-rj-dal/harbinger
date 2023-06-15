#'@title Multivariate anomaly detector using PCA
#'@description Multivariate anomaly detector using PCA
#'@param alpha Threshold for outliers
#'@return hmu_pca object
#'@examples detector <- hmu_pca()
#'@export
hmu_pca <- function(alpha=1.5) {
  obj <- harbinger()
  obj$alpha <- alpha
  class(obj) <- append("hmu_pca", class(obj))
  return(obj)
}

#'@title Multivariate anomaly detector using PCA
#'@description Multivariate anomaly detector using PCA
#'@param obj detector
#'@param serie time series
#'@param ... optional arguments.
#'@return A dataframe with information about the detected anomalous points
#'@examples detector <- harbinger()
#'@importFrom stats na.omit
#'@importFrom stats prcomp
#'@export
detect.hmu_pca <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  n <- nrow(serie)
  non_na <- which(!is.na(apply(serie, 1, max)))
  serie <- stats::na.omit(serie)

  pca_res <- stats::prcomp(serie, center=TRUE, scale.=TRUE)
  pca.transf <- as.matrix(pca_res$rotation[, 1])
  data_x <- as.data.frame(as.matrix(serie) %*% pca.transf)

  model <- hanr_arima()
  model <- fit(model, data_x$V1)
  detection <- detect(model, data_x$V1)

  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- detection$event

  detection <- data.frame(idx=1:nrow(serie), event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"
  attr(detection, "serie") <- data_x$V1

  return(detection)
}
