# DAL Library
# version 2.1

# depends dal_transform.R

# cla_svm
# loadlibrary("e1071")

#'@title Support Vector Machine Classification
#'@description
#'@details
#'
#'@param attribute - name of the attribute used as target classification
#'@param slevels - possible values for the target classification
#'@param epsilon
#'@param cost
#'@param kernel
#'@return
#'@examples
#'@export
cla_svm <- function(attribute, slevels=NULL, epsilon=seq(0,1,0.2), cost=seq(20,100,20), kernel="radial") {
  #kernel: linear, radial, polynomial, sigmoid
  #studio: https://rpubs.com/Kushan/296706
  obj <- classification(attribute, slevels)
  obj$kernel <- kernel
  obj$epsilon <- epsilon
  obj$cost <- cost

  class(obj) <- append("cla_svm", class(obj))
  return(obj)
}

#'@import e1071
#'@export
fit.cla_svm <- function(obj, data) {
  internal_fit.cla_svm <- function (x, y, epsilon, cost, kernel) {
    model <- e1071::svm(x, y, probability=TRUE, epsilon=epsilon, cost=cost, kernel=kernel)
    attr(model, "slevels")  <- levels(y)
    return (model)
  }

  internal_predict.cla_svm <- function(model, x) {
    prediction <- predict(model, x, probability = TRUE)
    prediction <- attr(prediction, "probabilities")
    slevels <- attr(model, "slevels")
    prediction <- prediction[,slevels]
    return(prediction)
  }

  data <- adjust_data.frame(data)
  data[,obj$attribute] <- adjust.factor(data[,obj$attribute], obj$ilevels, obj$slevels)
  obj <- fit.classification(obj, data)

  x <- data[,obj$x]
  y <- data[,obj$attribute]

  ranges <- list(epsilon=obj$epsilon, cost=obj$cost, kernel=obj$kernel)
  obj$model <- tune.classification(obj, x = x, y = y, ranges = ranges, fit.func = internal_fit.cla_svm, pred.fun = internal_predict.cla_svm)

  params <- attr(obj$model, "params")
  msg <- sprintf("epsilon=%.1f,cost=%.3f", params$epsilon, params$cost)
  obj <- register_log(obj, msg)
  return(obj)
}

#'@export
predict.cla_svm  <- function(obj, x) {
  x <- adjust_data.frame(x)
  x <- x[,obj$x]

  prediction <- predict(obj$model, x, probability = TRUE)
  prediction <- attr(prediction, "probabilities")
  slevels <- attr(obj$model, "slevels")
  prediction <- prediction[,slevels]

  return(prediction)
}
