# DAL Library
# version 2.1

# depends dal_transform.R
# depends ts_data.R
# depends ts_regression.R
# depends ts_preprocessing.R

# class ts_svm
# loadlibrary("e1071")

#'@title Time Series Support Vector Machine
#'@description Transform data into vectors of features. The algorithm then
#' identifies the support vectors that define the hyperplane that best separates
#' the data into different classes based on temporal proximity. The hyperplane
#' can then be used to make predictions about future values of the time series.
#'@details
#'
#'@param preprocess
#'@param input_size
#'@param kernel
#'@param epsilon
#'@param cost
#'@return a `ts_svm` object.
#'@examples
#'@export
ts_svm <- function(preprocess=NA, input_size=NA, kernel="radial", epsilon=0, cost=10) {
  obj <- tsreg_sw(preprocess, input_size)

  obj$kernel <- kernel #c("radial", "poly", "linear", "sigmoid")
  obj$epsilon <- epsilon #seq(0, 1, 0.1)
  obj$cost <- cost #=seq(10, 100, 10)

  class(obj) <- append("ts_svm", class(obj))
  return(obj)
}

#'@title Updates the parameters of an SVM model object for time series (ts_svm)
#'@description It takes as input the obj model object and a set of params parameters to update.
#'@details The function checks that each parameter specified in params is not null and, if not null, updates the corresponding parameter in the object obj
#'@param obj
#'@param params
#'@return The obj template object updated with the new parameters
#'@export
set_params.ts_svm <- function(obj, params) {
  if (!is.null(params$kernel))
    obj$kernel <- params$kernel
  if (!is.null(params$epsilon))
    obj$epsilon <- params$epsilon
  if (!is.null(params$cost))
    obj$ntree <- params$cost
  return(obj)
}

#'@import e1071
#'@title Fits an SVM model to time series
#'
#'@description It takes as input the model object obj, the input data x and the expected outputs y
#'
#'@details The function uses the e1071 library implementation to tune the SVM model, specifying the following parameters: x: a matrix or a data frame with the explanatory variables; y: a vector with the response variable; epsilon: The SVM smoothing parameter; cost: the SVM cost parameter; kernel: the kernel type to be used by the SVM model
#'
#'@param obj
#'@param x
#'@param y
#'
#'@return The obj model object with the adjusted model
#'@export
do_fit.ts_svm <- function(obj, x, y) {
  obj$model <- e1071::svm(x = as.data.frame(x), y = y, epsilon=obj$epsilon, cost=obj$cost, kernel=obj$kernel)
  return(obj)
}

#'@export
#'@title Uses an adjusted SVM model for time series to make predictions
#'@description It takes as input the model object obj and the input data x
#'@details The function uses the SVM model stored in the model attribute of the obj object to make predictions using the predict function from the e1071 library
#'@param obj
#'@param x
#'@return The prediction variable
do_predict.ts_svm <- function(obj, x) {
  prediction <- predict(obj$model, as.data.frame(x))
  return(prediction)
}
