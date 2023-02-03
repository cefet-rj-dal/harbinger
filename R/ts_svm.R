# DAL Library
# version 2.1

# depends dal_transform.R
# depends ts_data.R
# depends ts_regression.R
# depends ts_preprocessing.R

# class ts_svm
# loadlibrary("e1071")

#'@title
#'@description
#'@details
#'
#'@param preprocess
#'@param input_size
#'@param kernel
#'@param epsilon
#'@param cost
#'@return
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
#'@export
do_fit.ts_svm <- function(obj, x, y) {
  obj$model <- e1071::svm(x = as.data.frame(x), y = y, epsilon=obj$epsilon, cost=obj$cost, kernel=obj$kernel)
  return(obj)
}

#'@export
do_predict.ts_svm <- function(obj, x) {
  prediction <- predict(obj$model, as.data.frame(x))
  return(prediction)
}
