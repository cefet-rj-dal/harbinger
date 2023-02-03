# DAL Library
# version 2.1

# depends dal_transform.R
# depends ts_data.R
# depends ts_regression.R
# depends ts_preprocessing.R

# class ts_mlp
# loadlibrary("nnet")

#'@title
#'@description
#'@details
#'
#'@param preprocess
#'@param input_size
#'@param size
#'@param decay
#'@param maxit
#'@return
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
#'@export
do_fit.ts_mlp <- function(obj, x, y) {
  obj$model <- nnet::nnet(x = x, y = y, size = obj$size, decay=obj$decay, maxit = obj$maxit, linout=TRUE, trace = FALSE)
  return(obj)
}
