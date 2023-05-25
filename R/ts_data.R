# DAL Library
# version 2.1

# depends dal_transform.R

# ts_data

#'@title Time Series Data
#'@description receives a vector or matrix y containing the data of a time series and an integer sw indicating the size of the sliding window
#'@details Prepare data for time series analysis
#'
#'@param y
#'@param sw integer: sliding window size.
#'@return a `ts_data` object.
#'@examples
#'@export
ts_data <- function(y, sw=1) {
  #https://stackoverflow.com/questions/7532845/matrix-losing-class-attribute-in-r
  ts_sw <- function(x, sw) {
    ts_lag <- function(x, k)
    {
      c(rep(NA, k), x)[1 : length(x)]
    }
    n <- length(x)-sw+1
    window <- NULL
    for(c in (sw-1):0){
      t  <- ts_lag(x,c)
      t <- t[sw:length(t)]
      window <- cbind(window,t,deparse.level = 0)
    }
    col <- paste("t",c((sw-1):0), sep="")
    colnames(window) <- col
    return(window)
  }

  if (sw > 1)
    y <- ts_sw(as.matrix(y), sw)
  else {
    y <- as.matrix(y)
    sw <- 1
  }

  col <- paste("t",(ncol(y)-1):0, sep="")
  colnames(y) <- col

  class(y) <- append("ts_data", class(y))
  attr(y, "sw") <- sw
  return(y)
}

#'@title Extract a subset of a time series stored in an object
#'@description Receives as parameters the variables x, i, j ...
#'@details The i and j arguments specify the rows and columns to be selected, respectively. The argument ... lets you pass other arguments to the unclass function
#'
#'@param x
#'@param i
#'@param j
#'@return A new ts_data object
#'@examples
#'@export
`[.ts_data` <- function(x, i, j, ...) {
  y <- unclass(x)[i, j, drop = FALSE, ...]
  class(y) <- c("ts_data",class(y))
  attr(y, "sw") <- ncol(y)
  return(y)
}

#head
#'@title Extract the first observations from a time series
#'@description The function takes as arguments the variables x, n (default = 6L), ...
#'@details The function uses the head function to extract the first n observations of the x-time series, after turning it into a non-class object via the unclass function
#'
#'@param x
#'@param n integer: size of test data.
#'@return The first n observations of a time series x
#'@examples
#'@export
tshead <- function(x, n = 6L, ...) {
  head(unclass(x), n)
}

#ts_sample
#'@title Time Series Sample
#'@description Has three arguments: ts: the time series to split; test_size: the size of the test sample, in number of observations; offset: the number of observations to be ignored at the end of the time series.
#'@details The function calculates the offset offset index and creates the training sample, which includes all time series observations up to the offset offset index
#'
#'@param ts time series data.
#'@param test_size integer: size of test data (default = 1).
#'@param offset integer: starting point (default = 0).
#'@return A list with the two samples
#'@examples
#'@export
ts_sample <- function(ts, test_size=1, offset=0) {
  offset <- nrow(ts) - test_size - offset
  train <- ts[1:offset, ]
  test <- ts[(offset+1):(offset+test_size),]
  colnames(test) <- colnames(train)
  samp <- list(train = train, test = test)
  attr(samp, "class") <- "ts_sample"
  return(samp)
}


#adjust.ts_data
#'@title Transform the date object
#'@description The first check that is done is to see if data is a matrix using the is.matrix() function. If data is not a matrix, the function converts data to a matrix using the as.matrix() function
#'@details Takes a data object as an argument
#'@param data
#'@return The date object changed
#'@export
adjust.ts_data <- function(data) {
  if (!is.matrix(data))
    data <- as.matrix(data)
  colnames(data) <- paste("t",c((ncol(data)-1):0), sep="")
  class(data) <- append("ts_data", class(data))
  attr(data, "sw") <- ncol(data)
  return(data)
}

#ts_projection
#'@title Time Series Projection
#'@description It takes a time series as input (an object of type matrix or data.frame)
#'@details If the time series has more than one column, the function assumes that the last column is the output variable (or response variable), and all other columns are input variables (or independent variables)
#'
#'@param ts matrix or data.frame containing the time series.
#'@return a `ts_projection` object.
#'@examples
#'@export
ts_projection <- function(ts) {
  input <- ts
  output <- ts

  if (is.matrix(ts) || is.data.frame(ts)) {
    if (nrow(ts) > 1) {
      input <- ts[,1:(ncol(ts)-1)]
      colnames(input) <- colnames(ts)[1:(ncol(ts)-1)]
      output <- ts[,ncol(ts)]
      colnames(output) <- colnames(ts)[ncol(ts)]
    }
    else {
      input <- ts_data(ts[,1:(ncol(ts)-1)], ncol(ts)-1)
      colnames(input) <- colnames(ts)[1:(ncol(ts)-1)]
      output <- ts_data(ts[,ncol(ts)], 1)
      colnames(output) <- colnames(ts)[ncol(ts)]
    }
  }

  proj <- list(input = input, output = output)
  attr(proj, "class") <- "ts_projection"
  return(proj)
}

#'@title Time Series Transformation
#'@description Manipulate and reshapa a time series to better understand and
#' analyze the underlying patterns, trends, and relationships.
#'@details Creates an object of class dal_transform and adds class ts_transform to it.
#'
#'@return a `ts_transform` object.
#'@examples
#'@export
ts_transform <- function() {
  obj <- dal_transform()
  class(obj) <- append("ts_transform", class(obj))
  return(obj)
}

#'@title Transform data to objects of class st_transform
#'@description The function receives as arguments the variables obj and data
#'@param obj
#'@param data
#'@return The data given as an argument
#'@examples
#'@export
transform.ts_transform <- function(obj, data) {
  return(data)
}


#'@title Describe the ts_transform function
#'
#'@description The function receives as argument the variable obj
#'
#'@details This function can be useful for debugging purposes or to inform the user that there is no information available about the created transform object
#'
#'@param obj
#'@return The string "none"
#'@examples
#'@export
describe.ts_transform <- function(obj) {
  return("none")
}
