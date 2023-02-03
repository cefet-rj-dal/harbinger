# DAL Library
# version 2.1

# depends dal_transform.R
# depends ts_data.R

# tsreg
#'@title
#'@description
#'@details
#'
#'@return
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
#'@export
predict.tsreg <- function(obj, x) {
  return(x[,ncol(x)])
}

# setup for sliding window
#'@title
#'@description
#'@details
#'
#'@param obj object: .
#'@param params
#'@return
#'@examples
#'@export
set_params <- function(obj, params) {
  UseMethod("set_params")
}

#'@export
set_params.default <- function(obj, params) {
  return(obj)
}

#'@title
#'@description
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

#'@title
#'@description
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
#'@title
#'@description
#'@details
#'
#'@param preprocess
#'@param input_size
#'@return
#'@examples
#'@export
tsreg_sw <- function(preprocess=NA, input_size=NA) {
  obj <- tsreg()

  obj$preprocess <- preprocess
  obj$input_size <- input_size

  class(obj) <- append("tsreg_sw", class(obj))
  return(obj)
}

#'@title
#'@description
#'@details
#'
#'@param data
#'@param input_size
#'@return
#'@examples
#'@export
ts_as_matrix <- function(data, input_size) {
  result <- data[,(ncol(data)-input_size+1):ncol(data)]
  return(result)
}

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

#'@export
do_predict.tsreg_sw <- function(obj, x) {
  prediction <- predict(obj$model, x)
  return(prediction)
}

# regression_evaluation

#'@export
MSE.tsreg <- function (actual, prediction) {
  if (length(actual) != length(prediction))
    stop("actual and prediction have different lengths")
  n <- length(actual)
  res <- mean((actual - prediction)^2)
  res
}

#'@export
sMAPE.tsreg <- function (actual, prediction) {
  if (length(actual) != length(prediction))
    stop("actual and prediction have different lengths")
  n <- length(actual)
  res <- (1/n) * sum(abs(actual - prediction)/((abs(actual) +
                                                  abs(prediction))/2))
  res
}

#'@export
evaluation.tsreg <- function(values, prediction) {
  obj <- list(values=values, prediction=prediction)

  obj$smape <- sMAPE.tsreg(values, prediction)
  obj$mse <- MSE.tsreg(values, prediction)

  obj$metrics <- data.frame(mse=obj$mse, smape=obj$smape)

  attr(obj, "class") <- "evaluation.tsreg"
  return(obj)
}

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
