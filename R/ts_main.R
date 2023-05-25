# DAL Library
# version 2.1

# depends dal_transform.R
# depends ts_data.R

# tsreg
#'@title Create an object of class "tsreg" which is a subclass of object "dal_transform
#'@description The function sets some object attributes, such as log, debug and reproduce, to TRUE or FALSE. Then it adds the "tsreg" class to the object and returns the created object
#'@details
#'
#'@return An object of the class "tsreg"
#'@examples
#'@export
tsreg <- function() {
  obj <- dal_transform()
  obj$log <- TRUE
  obj$debug <- FALSE
  obj$reproduce <- TRUE

  class(obj) <- append("tsreg", class(obj))
  return(obj)
}

#predict
#'@title Returns the last observed value
#'@description Takes two arguments: the object obj and an array x
#'@details This function does not do any forecasting or statistical modeling of the time series, it simply returns the last observed value
#'
#'@param obj
#'@param x
#'
#'@return The last column of the matrix x, that is, the value corresponding to the last time period in the time series
#'@examples
#'@export
predict.tsreg <- function(obj, x) {
  return(x[,ncol(x)])
}

# setup for sliding window
#'@title Update an object's parameters
#'@description The function receives the obj and params variables as parameters
#'@details This function serves as a "skeleton" for implementing different set_params methods for different object classes
#'
#'@param obj object: .
#'@param params
#'@examples
#'@export
set_params <- function(obj, params) {
  UseMethod("set_params")
}

#'@title Defines a default method for the set_params function
#'@descritption This function receives the obj and params variables as parameters.
#'@param obj
#'@param params
#'
#'@return The obj object
#'@export
set_params.default <- function(obj, params) {
  return(obj)
}

#'@title Delegate the task of adjusting the model to the specific methods of each class that implements it.
#'@description This function receives the obj, x and y variables as parameters
#'@details
#'
#'@param obj object: .
#'@param x
#'@param y
#'@return
#'@examples
#'@export
do_fit <- function(obj, x, y = NULL) {
  UseMethod("do_fit")
}

#'@title Define a generic method and delegate the implementation
#'@description This function defines the "do_predict" method for a generic object "obj" and a dataset "x"
#'@details
#'
#'@param obj object: .
#'@param x
#'@return
#'@examples
#'@export
do_predict <- function(obj, x) {
  UseMethod("do_predict")
}

#class tsreg_sw
#'@title Create an object of class "tsreg_sw", which is an extension of class "tsreg"
#'@description Preprocessing parameters and input size are user specified
#'@details
#'
#'@param preprocess
#'@param input_size
#'@return A tsreg object
#'@examples
#'@export
tsreg_sw <- function(preprocess=NA, input_size=NA) {
  obj <- tsreg()

  obj$preprocess <- preprocess
  obj$input_size <- input_size

  class(obj) <- append("tsreg_sw", class(obj))
  return(obj)
}

#'@title Prepare the data to feed a machine learning model
#'@description Takes a time series dataset data and an input size input_size
#'@details
#'
#'@param data
#'@param input_size
#'@return An array of the latest input_size observations of each time series at date
#'@examples
#'@export
ts_as_matrix <- function(data, input_size) {
  result <- data[,(ncol(data)-input_size+1):ncol(data)]
  return(result)
}

#'@title Performs the adjustment (training) of a regression model in time series
#'
#'@description It takes as input an obj object of the tsreg_sw class, which contains the model settings as well as the x and y data to fit the model
#'
#'@details The function first calls the start_log function to start logging the model's training log. Then, if the reproduce parameter is set to true, the function sets the random seed to 1 to ensure reproducible results
#'
#'@param obj
#'@param x
#'@param y
#'
#'@return The updated obj object
#'@examples
#'@export
fit.tsreg_sw <- function(obj, x, y) {
  obj <- start_log(obj)
  if (obj$reproduce)
    set.seed(1)

  obj$preprocess <- fit(obj$preprocess, x)

  x <- transform(obj$preprocess, x)

  y <- transform(obj$preprocess, x, y)

  obj <- do_fit(obj, ts_as_matrix(x, obj$input_size), y)

  if (obj$log)
    obj <- register_log(obj)
  return(obj)
}

#'@title Performs prediction of values for a time series
#'
#'@description The function receives three variables as a parameter, which are obj, x and steps_ahead
#'
#'@details If the steps_ahead parameter is equal to 1, the function takes a set of data x and returns a forecast y for the next time period. If steps_ahead is greater than 1, the function iterates over the number of time periods to be predicted and performs the same process for each one
#'
#'@param obj
#'@param x
#'@param steps_ahead
#'
#'@return A vector with forecasts for each time period
#'@examples
#'@export
predict.tsreg_sw <- function(obj, x, steps_ahead=1) {
  if (steps_ahead == 1) {
    x <- transform(obj$preprocess, x)
    data <- ts_as_matrix(x, obj$input_size)
    y <- do_predict(obj, data)
    y <- inverse_transform(obj$preprocess, x, y)
    return(as.vector(y))
  }
  else {
    if (nrow(x) > 1)
      stop("In steps ahead, x should have a single row")
    prediction <- NULL
    cnames <- colnames(x)
    x <- x[1,]
    for (i in 1:steps_ahead) {
      colnames(x) <- cnames
      x <- transform(obj$preprocess, x)
      y <- do_predict(obj, ts_as_matrix(x, obj$input_size))
      x <- adjust.ts_data(inverse_transform(obj$preprocess, x))
      y <- inverse_transform(obj$preprocess, x, y)
      for (j in 1:(ncol(x)-1)) {
        x[1, j] <- x[1, j+1]
      }
      x[1, ncol(x)] <- y
      prediction <- c(prediction, y)
    }
    return(as.vector(prediction))
  }
  return(prediction)
}

#'@title Performs the prediction step of the temporal regression model
#'@description It receives as input the obj object that contains the trained model and the input matrix x
#'@details The function uses the predict() method to make predictions based on the model fitted by the do_fit() method
#'@param obj
#'@param x
#'@return The forecast matrix
#'@export
do_predict.tsreg_sw <- function(obj, x) {
  prediction <- predict(obj$model, x)
  return(prediction)
}

# regression_evaluation

#'@title Calculate the mean squared error (MSE) between actual values and forecasts of a time series
#'@description The function receives two variables as a parameter, which are actual and prediction
#'
#'@details MSE is a common measure of performance for time series forecasting models, which represents the mean of the squared differences between the actual values and the forecasts
#'
#'@param actual
#'@param prediction
#'
#'@return A number, which is the calculated MSE
#'@export
MSE.tsreg <- function (actual, prediction) {
  if (length(actual) != length(prediction))
    stop("actual and prediction have different lengths")
  n <- length(actual)
  res <- mean((actual - prediction)^2)
  res
}

#'@title Calculate the symmetric mean absolute percent error (sMAPE)
#'
#'@description The function receives two variables as a parameter, which are actual and prediction
#'
#'
#'@details It is an error measure that is useful for assessing the accuracy of forecasts in time series, where observations can have different scales
#'
#'@param actual
#'@param prediction
#'
#'@return The sMAPE between the actual and prediction vectors
#'@export
sMAPE.tsreg <- function (actual, prediction) {
  if (length(actual) != length(prediction))
    stop("actual and prediction have different lengths")
  n <- length(actual)
  res <- (1/n) * sum(abs(actual - prediction)/((abs(actual) +
                                                  abs(prediction))/2))
  res
}

#'@title Calculate the Mean Squared Error (MSE) error metric and the Symmetric Mean Absolute Percentage Error (sMAPE) error metric
#'
#'@description The function receives two variables as a parameter, which are values and prediction
#'
#'@details The returned object is also assigned to the "evaluation.tsreg" class
#'
#'@param values
#'@param prediction
#'
#'@return An object that contains these metrics and their values, stored in a data frame
#'@export
evaluation.tsreg <- function(values, prediction) {
  obj <- list(values=values, prediction=prediction)

  obj$smape <- sMAPE.tsreg(values, prediction)
  obj$mse <- MSE.tsreg(values, prediction)

  obj$metrics <- data.frame(mse=obj$mse, smape=obj$smape)

  attr(obj, "class") <- "evaluation.tsreg"
  return(obj)
}

#'@title Plot a time series chart
#'
#'@description The function receives six variables as a parameter, which are obj and y, yadj, main and xlabels. The graph is plotted with 3 lines: the original series (in black), the adjusted series (in blue) and the predicted series (in green)
#'
#'@details It displays the value of the sMAPE metric for the training and test sets. The obj argument is a tsreg object that contains the information of the model used, y is the original series, yadj is the adjusted series and ypre is the predicted series
#'
#'@param obj
#'@param y
#'@param yadj
#'@param ypre
#'@param main
#'@param xlabels
#'
#'
#'@export
tsplot <- function(obj, y, yadj, ypre, main=NULL, xlabels=NULL) {
  if (is.null(main)) {
    prepname <- ""
    if (!is.null(obj$preprocess))
      prepname <- sprintf("-%s", describe(obj$preprocess))
    main <- sprintf("%s%s", describe(obj), prepname)
  }
  y <- as.vector(y)
  yadj <- as.vector(yadj)
  ypre <- as.vector(ypre)
  ntrain <- length(yadj)
  smape_train <- sMAPE.tsreg(y[1:ntrain], yadj)*100
  smape_test <- sMAPE.tsreg(y[(ntrain+1):(ntrain+length(ypre))], ypre)*100
  par(xpd=TRUE)
  if(is.null(xlabels))
    xlabels <- 1:length(y)
  plot(xlabels, y, main = main, xlab = sprintf("time [smape train=%.2f%%], [smape test=%.2f%%]", smape_train, smape_test), ylab="value")
  lines(xlabels[1:ntrain], yadj, col="blue")
  lines(xlabels[ntrain:(ntrain+length(ypre))], c(yadj[length(yadj)],ypre), col="green")
  par(xpd=FALSE)
}
