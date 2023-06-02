# DAL Library
# version 2.1

# depends dal_transform.R
# depends ts_data.R
# depends ts_regression.R
# depends ts_preprocessing.R

# class ts_mlp
# loadlibrary("nnet")

#'@title Time Series Multilayer Perceptron (MLP)
#'@description Type of artificial neural network used to make predictions and
#' forecasts based on time series data. Consists of multiple layers of
#' interconnected nodes or neurons, using a supervised learning algorithm, which
#' processes the input data and passes it on. The output of the final layer
#' provides the predicted values for the future.
#'@details
#'
#'@param preprocess
#'@param input_size
#'@param size
#'@param decay
#'@param maxit
#'@return a `ts_mlp` object.
#'@examples
#'@export
ts_mlp <- function(preprocess=NA, input_size=NA, size=NA, decay=0.01, maxit=1000) {
  obj <- tsreg_sw(preprocess, input_size)
  if (is.na(size))
    size <- ceiling(input_size/3)

  obj$size <- size
  obj$decay <- decay
  obj$maxit <- maxit

  class(obj) <- append("ts_mlp", class(obj))
  return(obj)
}


#'@title Update ts_mlp object parameters
#'
#'@description It takes two arguments: the ts_mlp object to be updated (obj) and a list object containing the new parameter values to be updated (params)
#'
#'@details The function checks whether each parameter is present in the params list using the is.null function. If the parameter is present, the corresponding value is assigned to the parameter in the ts_mlp object. Otherwise, the parameter is not changed
#'
#'@param obj
#'@param params
#'@return ts_mlp object updated with new parameter values
#'@export
set_params.ts_mlp <- function(obj, params) {
  if (!is.null(params$size))
    obj$size <- params$size
  if (!is.null(params$decay))
    obj$decay <- params$decay
  if (!is.null(params$maxit))
    obj$maxit <- params$maxit

  return(obj)
}

#'@import nnet
#'@title Train the ts_mlp model
#'
#'@description It takes three arguments: the ts_mlp object to be trained (obj), the input matrix (x) and the output vector (y)
#'
#'@details Inside the function, the nnet function is used to train the ts_mlp model
#'
#'@param obj
#'@param x
#'@param y
#'
#'@return The ts_mlp object updated with the trained model
#'@export
do_fit.ts_mlp <- function(obj, x, y) {
  obj$model <- nnet::nnet(x = x, y = y, size = obj$size, decay=obj$decay, maxit = obj$maxit, linout=TRUE, trace = FALSE)
  return(obj)
}
