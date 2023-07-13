#'@title Anomaly detector based on machine learning classification
#'@description Anomaly detection using daltoolbox classification.
#'A training and test set should be used. The training set must contain labeled events.
#'A set of preconfigured of classification methods are described in <https://cefet-rj-dal.github.io/daltoolbox>.
#'@param model DALToolbox classification model
#'@return hanc_ml object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(har_examples)
#'
#'#Using example 17
#'dataset <- har_examples$example17
#'dataset$event <- factor(dataset$event, labels=c("FALSE", "TRUE"))
#'slevels <- levels(dataset$event)
#'
#'# separating into training and test
#'train <- dataset[1:80,]
#'test <- dataset[-(1:80),]
#'
#'# normalizing the data
#'norm <- minmax()
#'norm <- fit(norm, train)
#'train_n <- transform(norm, train)
#'
#'# establishing decision tree method
#'model <- hanc_ml(cla_dtree("event", slevels))
#'
#'# fitting the model
#'model <- fit(model, train_n)
#'
#'# evaluating the detections during testing
#'test_n <- transform(norm, test)
#'
#'detection <- detect(model, test_n)
#'print(detection |> dplyr::filter(event==TRUE))
#'
#'@export
hanc_ml <- function(model) {
  obj <- harbinger()
  obj$model <- model

  class(obj) <- append("hanc_ml", class(obj))
  return(obj)
}

#'@import daltoolbox
#'@export
fit.hanc_ml <- function(obj, serie, ...) {
  obj$model <- daltoolbox::fit(obj$model, serie)
  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom stats predict
#'@export
detect.hanc_ml <- function(obj, serie, ...) {
  n <- nrow(serie)
  non_na <- which(!is.na(apply(serie, 1, max)))
  serie <- stats::na.omit(serie)

  adjust <- stats::predict(obj$model, serie)
  outliers <- which(adjust[,1] < adjust[,2])

  outliers <- obj$har_outliers_group(outliers, nrow(serie))

  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"

  return(detection)
}
