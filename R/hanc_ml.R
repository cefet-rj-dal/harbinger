#' @title Anomaly detector based on ML classification
#' @description
#' Supervised anomaly detection using a DALToolbox classifier trained with
#' labeled events. Predictions above a probability threshold are flagged.
#'
#' A set of preconfigured classification methods are listed at
#' <https://cefet-rj-dal.github.io/daltoolbox/> (e.g., `cla_majority`,
#' `cla_dtree`, `cla_knn`, `cla_mlp`, `cla_nb`, `cla_rf`, `cla_svm`).
#'
#' @param model A DALToolbox classification model.
#' @param threshold Numeric. Probability threshold for positive class.
#' @return `hanc_ml` object.
#'
#' @examples
#' library(daltoolbox)
#'
#' # Load labeled anomaly dataset
#' data(examples_anomalies)
#'
#' # Use train-test example
#' dataset <- examples_anomalies$tt
#' dataset$event <- factor(dataset$event, labels=c("FALSE", "TRUE"))
#' slevels <- levels(dataset$event)
#'
#' # Split into training and test
#' train <- dataset[1:80,]
#' test <- dataset[-(1:80),]
#'
#' # Normalize features
#' norm <- minmax()
#' norm <- fit(norm, train)
#' train_n <- daltoolbox::transform(norm, train)
#'
#' # Configure a decision tree classifier
#' model <- hanc_ml(cla_dtree("event", slevels))
#'
#' # Fit the classifier
#' model <- fit(model, train_n)
#'
#' # Evaluate detections on the test set
#' test_n <- daltoolbox::transform(norm, test)
#'
#' detection <- detect(model, test_n)
#' print(detection[(detection$event),])
#'
#' @references
#' - Bishop CM (2006). Pattern Recognition and Machine Learning. Springer.
#' - Hyndman RJ, Athanasopoulos G (2021). Forecasting: Principles and Practice. OTexts.
#' - Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. 1st ed.
#'   Cham: Springer Nature Switzerland, 2025. doi:10.1007/978-3-031-75941-3
#'
#'@export
hanc_ml <- function(model, threshold = 0.5) {
  obj <- harbinger()
  obj$model <- model
  obj$threshold <- threshold

  hutils <- harutils()

  class(obj) <- append("hanc_ml", class(obj))
  return(obj)
}

#'@importFrom daltoolbox fit
#'@exportS3Method fit hanc_ml
fit.hanc_ml <- function(obj, serie, ...) {
  # Ensure target is a two-level factor with explicit labels
  serie[,obj$model$attribute] <- factor(serie[,obj$model$attribute], labels=c("FALSE", "TRUE"))

  obj$model <- daltoolbox::fit(obj$model, serie)
  return(obj)
}


#'@importFrom stats na.omit
#'@importFrom stats predict
#'@importFrom daltoolbox adjust_data.frame
#'@exportS3Method detect hanc_ml
detect.hanc_ml <- function(obj, serie, ...) {
  har_outliers_classification <- function(data) {
    # Flag as event when positive class probability >= threshold
    index <- which(data >= obj$threshold) # non-event versus anomaly
    attr(index, "threshold") <- obj$threshold
    return (index)
  }

  # Ensure target factor if present
  if (!is.null(serie[,obj$model$attribute]))
    serie[,obj$model$attribute] <- factor(serie[,obj$model$attribute], labels=c("FALSE", "TRUE"))
  # Normalize indexing and sanitize data.frame columns
  obj <- obj$har_store_refs(obj, serie)
  obj$serie <- daltoolbox::adjust_data.frame(obj$serie)
  obj$serie <- obj$serie[,obj$model$x, drop = FALSE]

  # Predict probabilities and extract positive class
  adjust <- stats::predict(obj$model, obj$serie)
  res <- adjust[,2]
  anomalies <- har_outliers_classification(res)
  anomalies <- obj$har_outliers_check(anomalies, res)

  # Restore detections to original indexing
  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}
