#'@title Anomaly detector based on machine learning classification
#'@description Anomaly detection using daltoolbox classification.
#'A training and test set should be used. The training set must contain labeled events.
#'A set of preconfigured of classification methods are described in <https://cefet-rj-dal.github.io/daltoolbox/>.
#'They include: cla_majority, cla_dtree, cla_knn, cla_mlp, cla_nb, cla_rf, cla_svm
#'@param model DALToolbox classification model
#'@return `hanc_ml` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(examples_anomalies)
#'
#'#Using example tt
#'dataset <- examples_anomalies$tt
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
#'print(detection[(detection$event),])
#'
#'@export
hanc_ml <- function(model) {
  obj <- harbinger()
  obj$model <- model

  hutils <- harutils()
  obj$har_outliers <- hutils$har_outliers_classification

  class(obj) <- append("hanc_ml", class(obj))
  return(obj)
}

#'@import daltoolbox
#'@exportS3Method fit hanc_ml
fit.hanc_ml <- function(obj, serie, ...) {
  obj$model <- daltoolbox::fit(obj$model, serie)
  return(obj)
}


#'@importFrom stats na.omit
#'@importFrom stats predict
#'@exportS3Method detect hanc_ml
detect.hanc_ml <- function(obj, serie, ...) {
  obj <- obj$har_store_refs(obj, serie)
  obj$serie <- adjust_data.frame(obj$serie)
  obj$serie <- obj$serie[,obj$model$x, drop = FALSE]

  adjust <- stats::predict(obj$model, obj$serie)
  res <- adjust[,2]
  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}
