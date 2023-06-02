# DAL Library
# version 2.1

# depends dal_transform.R
# depends ts_data.R
# depends ts_regression.R
# depends ts_preprocessing.R

# class ts_rf
# loadlibrary("randomForest")

#'@title Time Series Random Forest
#'@description The function receives as arguments the variables preprocess, input_size, nodesize and ntree
#'
#'@details Create an object that contains information about the preprocessing (if applicable), the input window size (input_size), the node size (nodesize), and the number of trees (ntree) for the model
#'
#'@param preprocess
#'@param input_size
#'@param nodesize
#'@param ntree
#'@return a `ts_rf` object.
#'@examples
#'@export
ts_rf <- function(preprocess=NA, input_size=NA, nodesize = 5, ntree = 20) {
  obj <- tsreg_sw(preprocess, input_size)

  obj$nodesize <- nodesize
  obj$ntree <- ntree

  class(obj) <- append("ts_rf", class(obj))
  return(obj)
}


#'@title Allows parameters of a ts_rf object to be updated with new values

#'@description It receives as input a ts_rf object (obj) and a set of parameters (params)
#'
#'@details If the parameter set contains an entry for nodesize, the corresponding value is assigned to the ts_rf object. Likewise, if the parameter set contains an entry for ntree, the corresponding value is assigned to the ts_rf object
#'
#'@param obj
#'@param params
#'
#'@return The ts_rf object updated with the new parameter values
#'@export
set_params.ts_rf <- function(obj, params) {
  if (!is.null(params$nodesize))
    obj$nodesize <- params$nodesize
  if (!is.null(params$ntree))
    obj$ntree <- params$ntree

  return(obj)
}

#'@import randomForest
#'
#'@title Fits a random forest model to time series
#'
#'@description It receives as input a ts_rf object (obj), an input dataset (x) and an output dataset (y)
#'
#'@details The function fits the random forest model using the randomForest::randomForest() function, which is part of the randomForest package
#'
#'@param obj
#'@param x
#'@param y
#'
#'@return The updated ts_rf object
#'@export
do_fit.ts_rf <- function(obj, x, y) {
  obj$model <- randomForest::randomForest(x = as.data.frame(x), y = as.vector(y), mtry=ceiling(obj$input_size/3), nodesize = obj$nodesize, ntree=obj$ntree)
  return(obj)
}

#'@title Make predictions on a new dataset (x) using the fitted random forest model
#'
#'@description It takes as input a ts_rf object (obj) and an input dataset (x)
#'
#'@details To make the predictions, the predict() function is used, which is part of the randomForest package
#'
#'@param obj
#'@param x
#'
#'@return The prediction vector
#'@export
do_predict.ts_rf <- function(obj, x) {
  prediction <- predict(obj$model, as.data.frame(x))
  return(prediction)
}
