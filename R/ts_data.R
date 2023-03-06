# DAL Library
# version 2.1

# depends dal_transform.R

# ts_data

#'@title Time Series Data
#'@description
#'@details
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

#'@title
#'@description
#'@details
#'
#'@param x
#'@param i
#'@param j
#'@return
#'@examples
#'@export
`[.ts_data` <- function(x, i, j, ...) {
  y <- unclass(x)[i, j, drop = FALSE, ...]
  class(y) <- c("ts_data",class(y))
  attr(y, "sw") <- ncol(y)
  return(y)
}

#head
#'@title
#'@description
#'@details
#'
#'@param x
#'@param n integer: size of test data.
#'@return
#'@examples
#'@export
tshead <- function(x, n = 6L, ...) {
  head(unclass(x), n)
}

#ts_sample
#'@title Time Series Sample
#'@description
#'@details
#'
#'@param ts time series data.
#'@param test_size integer: size of test data (default = 1).
#'@param offset integer: starting point (default = 0).
#'@return
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
#'@description
#'@details
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
#'@details
#'
#'@return a `ts_transform` object.
#'@examples
#'@export
ts_transform <- function() {
  obj <- dal_transform()
  class(obj) <- append("ts_transform", class(obj))
  return(obj)
}

#'@export
transform.ts_transform <- function(obj, data) {
  return(data)
}

#'@export
describe.ts_transform <- function(obj) {
  return("none")
}
