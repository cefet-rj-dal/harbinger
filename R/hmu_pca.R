#'@title Multivariate anomaly detector using PCA
#'@description Multivariate anomaly detector using PCA <doi:10.1016/0098-3004(93)90090-R>
#'@return `hmu_pca` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(har_examples_multi)
#'
#'#Using the time series 9
#'dataset <- har_examples_multi$example1
#'head(dataset)
#'
#'# establishing hmu_pca method
#'model <- hmu_pca()
#'
#'# fitting the model using the two columns of the dataset
#'model <- fit(model, dataset[,1:2])
#'
#'# making detections using hmu_pca
#'detection <- detect(model, dataset[,1:2])
#'
#'# filtering detected events
#'print(detection |> dplyr::filter(event==TRUE))
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
