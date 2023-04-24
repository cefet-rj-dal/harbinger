# DAL Library
# version 2.1

# depends dal_transform.R
# depends cla_classification.R

# knn
# loadlibrary("class")

# cla_knn
#'@title K Nearest Neighbor Classification
#'@description Classification using KNN algorithm
#'@details
#'
#'@param attribute - name of the attribute used as target classification
#'@param slevels - possible values for the target classification
#'@param k - number od classes
#'@return classification object
#'@examples
#'@export
cla_knn <- function(attribute, slevels=NULL, k=1:30) {
  obj <- classification(attribute, slevels)
  obj$k <- k
  class(obj) <- append("cla_knn", class(obj))
  return(obj)
}

#'@import class RSNNS
#'@export
fit.cla_knn <- function(obj, data) {

  internal_fit.cla_knn <- function (x, y, k, ...) {
    model <- list(x=x, y=y, k=k)
    return (model)
  }

  internal_predict.cla_knn <- function(model, x) {
    prediction <- class::knn(train=model$x, test=x, cl=model$y, prob=TRUE)
    prediction <- RSNNS::decodeClassLabels(prediction)
    return(prediction)
  }

  data <- adjust_data.frame(data)
  data[,obj$attribute] <- adjust.factor(data[,obj$attribute], obj$ilevels, obj$slevels)
  obj <- fit.classification(obj, data)

  x <- data[,obj$x]
  y <- data[,obj$attribute]

  ranges <- list(k = obj$k, stub = 0)
  obj$model <- tune.classification(obj, x = x, y = y, ranges = ranges, fit.func = internal_fit.cla_knn, pred.fun = internal_predict.cla_knn)

  params <- attr(obj$model, "params")
  msg <- sprintf("k=%d", params$k)
  obj <- register_log(obj, msg)
  return(obj)
}

#'@import class RSNNS
#'@export
predict.cla_knn  <- function(obj, x) {
  x <- adjust_data.frame(x)
  x <- x[,obj$x]

  prediction <- class::knn(train=obj$model$x, test=x, cl=obj$model$y, prob=TRUE)
  prediction <- RSNNS::decodeClassLabels(prediction)

  return(prediction)
}
