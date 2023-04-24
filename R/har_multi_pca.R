#'@description Class for time series multivariate using PCA event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Multivariate PCA Detector object
#'@examples detector <- har_multi_pca()
#'@export
har_multi_pca <- function(alpha=1.5) {
  obj <- harbinger()
  obj$alpha <- alpha
  class(obj) <- append("har_multi_pca", class(obj))
  return(obj)
}

#depois tem que implementar o fit para coletar o pca e normalização


#'@export
detect.har_multi_pca <- function(obj, serie) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  n <- length(serie)
  non_na <- which(!is.na(serie))
  serie <- na.omit(serie)

  pca_res <- prcomp(serie, center=TRUE, scale.=TRUE)
  pca.transf <- as.matrix(pca_res$rotation[, 1])
  data_x <- as.data.frame(as.matrix(serie) %*% pca.transf)

  model <- har_arima()
  model <- fit(model, data_x$V1)
  detection <- detect(model, data_x$V1)

  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- detection$event

  detection <- data.frame(idx=1:length(serie), event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"
  return(detection)
}
