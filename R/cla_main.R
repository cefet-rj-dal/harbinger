# DAL Library
# version 2.1

# depends dal_transform.R

# classification
#loadlibrary("ROCR")
#loadlibrary("RSNNS")
#loadlibrary("nnet")
#loadlibrary("MLmetrics")

#'@title classification class
#'@description Ancestor class for classification problems
#'@details basic wrapper for classification problems
#'
#'@param attribute - name of the attribute used as target classification
#'@param slevels - possible values for the target classification
#'@return classification object
#'@examples
#'data(iris)
#'template_model <- classification("Species", levels(iris$Species))
#'print(template_model)
#'@export
classification <- function(attribute, slevels=NULL) {
  obj <- dal_transform()
  class(obj) <- append("classification", class(obj))
  obj$attribute <- attribute
  obj$slevels <- slevels
  obj$ilevels <- 1:length(slevels)
  return(obj)
}

#'@export
adjust.factor <- function(value, ilevels, slevels) {
  if (!is.factor(value)) {
    if (is.numeric(value))
      value <- factor(value, levels=ilevels)
    levels(value) <- slevels
  }
  return(value)
}

#'@export
fit.classification <- function(obj, data) {
  obj <- start_log(obj)
  if (obj$reproduce)
    set.seed(1)
  obj$x <- setdiff(colnames(data), obj$attribute)
  return(obj)
}
 
#'@import RSNNS
#'@export
tune.classification <- function (obj, x, y, ranges, folds=3, fit.func, pred.fun = predict) {
  ranges <- expand.grid(ranges)
  n <- nrow(ranges)
  accuracies <- rep(0,n)

  data <- data.frame(i = 1:nrow(x), idx = 1:nrow(x))
  folds <- k_fold(sample_random(), data, folds)

  i <- 1
  if (n > 1) {
    for (i in 1:n) {
      for (j in 1:length(folds)) {
        if (obj$reproduce)
          set.seed(1)
        tt <- train_test_from_folds(folds, j)

        params <- append(list(x = x[tt$train$i,], y = y[tt$train$i]), as.list(ranges[i,]))
        model <- do.call(fit.func, params)
        prediction <- pred.fun(model, x[tt$test$i,])
        accuracies[i] <- accuracies[i] + evaluation.classification(RSNNS::decodeClassLabels(y[tt$test$i]), prediction)$accuracy
      }
    }
    i <- which.max(accuracies)
  }
  if (obj$reproduce)
    set.seed(1)
  params <- append(list(x = x, y = y), as.list(ranges[i,]))
  model <- do.call(fit.func, params)
  attr(model, "params") <- as.list(ranges[i,])
  return(model)
}

#evaluation.classification
#'@import RSNNS MLmetrics nnet
#'@export
evaluation.classification <- function(data, prediction) {
  obj <- list(data=data, prediction=prediction)

  adjust_predictions <- function(predictions) {
    predictions_i <- matrix(rep.int(0, nrow(predictions)*ncol(predictions)), nrow=nrow(predictions), ncol=ncol(predictions))
    y <- apply(predictions, 1, nnet::which.is.max)
    for(i in unique(y)) {
      predictions_i[y==i,i] <- 1
    }
    return(predictions_i)
  }
  predictions <- adjust_predictions(obj$prediction)
  obj$conf_mat <- RSNNS::confusionMatrix(data, predictions)
  obj$accuracy <- MLmetrics::Accuracy(y_pred = predictions, y_true = data)
  obj$f1 <- MLmetrics::F1_Score(y_pred = predictions, y_true = data, positive = 1)
  obj$sensitivity <- MLmetrics::Sensitivity(y_pred = predictions, y_true = data, positive = 1)
  obj$specificity <- MLmetrics::Specificity(y_pred = predictions, y_true = data, positive = 1)
  obj$precision <- MLmetrics::Precision(y_pred = predictions, y_true = data, positive = 1)
  obj$recall <- MLmetrics::Recall(y_pred = predictions, y_true = data, positive = 1)
  obj$metrics <- data.frame(accuracy=obj$accuracy, f1=obj$f1, sensitivity=obj$sensitivity, specificity=obj$specificity, precision=obj$precision, recall=obj$recall)

  return(obj)
}

#roc_curve
#'@import ROCR
#'@export
roc_curve <- function(data, prediction) {
  pred <- ROCR::prediction(prediction, data)
  rocr <- ROCR::performance(pred, "tpr", "fpr")
  return (rocr)
}




