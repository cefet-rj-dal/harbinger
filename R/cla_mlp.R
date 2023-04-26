# DAL Library
# version 2.1

# depends dal_transform.R

# mlp_nnet
#loadlibrary("nnet")

#'@title Classification using Artificial Neural Network (ANN)
#'@description
#'@details
#'
#'@param attribute - name of the attribute used as target classification
#'@param slevels - possible values for the target classification
#'@param size - number of nodes that will be used in the hidden layer
#'@param decay - how quickly it decreases in gradient descent
#'@param maxit - maximun interations
#'@return
#'@examples
#'@export
cla_mlp <- function(attribute, slevels=NULL, size=NULL, decay=seq(0, 1, 0.0335), maxit=1000) {
  obj <- classification(attribute, slevels)
  obj$maxit <- maxit
  obj$size <- size
  obj$decay <- decay

  class(obj) <- append("cla_mlp", class(obj))
  return(obj)
}

#'@import nnet RSNNS
#'@export
fit.cla_mlp <- function(obj, data) {
  internal_fit.cla_mlp <- function (x, y, size, decay, maxit) {
    return (nnet::nnet(x, RSNNS::decodeClassLabels(y),size=size,decay=decay,maxit=maxit,trace=FALSE))
  }

  internal_predict.cla_mlp <- function(model, x) {
    prediction <- predict(model, x, type="raw")
    return(prediction)
  }

  data <- adjust_data.frame(data)
  data[,obj$attribute] <- adjust.factor(data[,obj$attribute], obj$ilevels, obj$slevels)
  obj <- fit.classification(obj, data)

  if (is.null(obj$size))
    obj$size <- ceiling(sqrt(ncol(data)))

  x <- data[,obj$x, drop = FALSE]
  y <- data[,obj$attribute]

  ranges <- list(maxit=obj$maxit, decay = obj$decay, size=obj$size)
  obj$model <- tune.classification(obj, x = x, y = y, ranges = ranges, fit.func = internal_fit.cla_mlp, pred.fun = internal_predict.cla_mlp)

  params <- attr(obj$model, "params")
  msg <- sprintf("size=%d,decay=%.2f", params$size, params$decay)
  obj <- register_log(obj, msg)
  return(obj)
}

#'@export
predict.cla_mlp  <- function(obj, x) {
  x <- adjust_data.frame(x)
  x <- x[,obj$x, drop = FALSE]

  prediction <- predict(obj$model, x, type="raw")

  return(prediction)
}
