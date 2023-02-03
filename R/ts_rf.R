# DAL Library
# version 2.1

# depends dal_transform.R
# depends ts_data.R
# depends ts_regression.R
# depends ts_preprocessing.R

# class ts_rf
# loadlibrary("randomForest")

#'@title
#'@description
#'@details
#'
#'@param preprocess
#'@param input_size
#'@param nodesize
#'@param ntree
#'@return
#'@examples
#'@export
ts_rf <- function(preprocess=NA, input_size=NA, nodesize = 5, ntree = 20) {
  obj <- tsreg_sw(preprocess, input_size)

  obj$nodesize <- nodesize
  obj$ntree <- ntree

  class(obj) <- append("ts_rf", class(obj))
  return(obj)
}

#'@export
set_params.ts_rf <- function(obj, params) {
  if (!is.null(params$nodesize))
    obj$nodesize <- params$nodesize
  if (!is.null(params$ntree))
    obj$ntree <- params$ntree

  return(obj)
}

#'@import randomForest
#'@export
do_fit.ts_rf <- function(obj, x, y) {
  obj$model <- randomForest::randomForest(x = as.data.frame(x), y = as.vector(y), mtry=ceiling(obj$input_size/3), nodesize = obj$nodesize, ntree=obj$ntree)
  return(obj)
}

#'@export
do_predict.ts_rf <- function(obj, x) {
  prediction <- predict(obj$model, as.data.frame(x))
  return(prediction)
}
