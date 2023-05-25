# DAL Library
# version 2.1

# depends dal_transform.R
# depends dal_outliers.R
# depends ts_data.R

# ts_normalize

#'@title Time Series Normalize
#'@description Transform data to a common scale, facilitating comparisons and
#' analysis.
#'@details
#'
#'@param remove_outliers logical: if TRUE (default) outliers will be removed.
#'@return a `ts_normalize` object.
#'@examples
#'@export
ts_normalize <- function(remove_outliers = TRUE) {
  obj <- dal_transform()
  obj$remove_outliers <- remove_outliers
  class(obj) <- append("ts_normalize", class(obj))
  return(obj)
}

# ts_gminmax
#'@title Time Series Global Min-Max
#'@description Rescales data, so the minimum value is mapped to 0 and the
#' maximum value is mapped to 1.
#'@details
#'
#'@param remove_outliers logical: if TRUE (default) outliers will be removed.
#'@return a `ts_gminmax` object.
#'@examples
#'@export
ts_gminmax <- function(remove_outliers = TRUE) {
  obj <- ts_normalize(remove_outliers)
  class(obj) <- append("ts_gminmax", class(obj))
  return(obj)
}

#'@title Sets the parameters of an object
#'
#'@description It takes 2 parameters: obj and data. This function adjusts the parameters of the obj object to the input data data using the global minimum and maximum transform (gminmax)
#'
#'@details If remove_outliers is true, outliers are removed from the series before adjusting parameters. Then, the minimum and maximum values of the series after removing the outliers are stored in obj$gmin and obj$gmax, respectively
#'
#'@param obj
#'@param data
#'
#'@return The updated obj object
#'@examples
#'@export
fit.ts_gminmax <- function(obj, data) {
  if (obj$remove_outliers) {
    out <- outliers()
    out <- fit(out, data)
    data <- transform(out, data)
  }

  obj$gmin <- min(data)
  obj$gmax <- max(data)

  return(obj)
}

#'@title Normalize time series data
#'
#'@description It takes as parameters the variables obj, data and x
#'
#'@details Normalization is done using the "min-max scaling" technique, which involves subtracting the minimum value of the time series (obj$gmin) and dividing by the interval between the minimum and maximum value (obj$gmax-obj$gmin)
#'
#'@param obj
#'@param data
#'@param x

#'@return The function returns the vector x if the argument x is given, or it returns the data matrix with the values transformed by the object obj
#'
#'@examples
#'@export
transform.ts_gminmax <- function(obj, data, x=NULL) {
  if (!is.null(x)) {
    x <- (x-obj$gmin)/(obj$gmax-obj$gmin)
    return(x)
  }
  else {
    data <- (data-obj$gmin)/(obj$gmax-obj$gmin)
    return(data)
  }
}

#'@title Inverse of function "transform.ts_gminmax
#'@description It receives as input an "obj" object that contains the minimum value (gmin) and the maximum value (gmax) of the input data that were normalized with the "transform.ts_gminmax" function
#'@details It applies the inverse operation to return the original (non-normalized) values of the input data, i.e. if the input is a vector of normalized data
#'
#'@param obj
#'@param data
#'@param x
#'
#'@return The function returns the corresponding array of original values; if the input is a single normalized value, the function returns the corresponding non-normalized value
#'
#'@examples
#'@export
inverse_transform.ts_gminmax <- function(obj, data, x=NULL) {
  if (!is.null(x)) {
    x <- x * (obj$gmax-obj$gmin) + obj$gmin
    return(x)
  }
  else {
    data <- data * (obj$gmax-obj$gmin) + obj$gmin
    return (data)
  }
}

#ts_diff
#'@title Time Series Diff
#'
#'@description It receives as parameter the variable remove_outliters. This function calculates the difference between the values of a time series
#'
#'@details It calls the "ts_normalize" function which normalizes the time series so that it has zero mean and unit standard deviation. If the "remove_outliers" argument is set to TRUE, the "ts_normalize" function also removes the outliers from the time series
#'
#'@param remove_outliers logical: if TRUE (default) outliers will be removed.
#'@return a `ts_diff` object.
#'@examples
#'@export
ts_diff <- function(remove_outliers = TRUE) {
  obj <- ts_normalize(remove_outliers)
  class(obj) <- append("ts_diff", class(obj))
  return(obj)
}

#'@title Fit the object created by the ts_diff function to the training data
#'
#'@description It takes two arguments: obj and data
#'
#'@details The fit.ts_diff function performs the transformation on the data data matrix that represents the difference between each pair of consecutive observations of each variable. The function then calls the fit.ts_gminmax function to normalize the transformed data matrix using the Min-Max normalization technique
#'
#'@param obj
#'@param data
#'@return The updated obj object
#'@examples
#'@export
fit.ts_diff <- function(obj, data) {
  data <- data[,2:ncol(data)]-data[,1:(ncol(data)-1)]
  obj <- fit.ts_gminmax(obj, data)
  return(obj)
}

#'@title Transform the data

#'@description It takes as parameters the variables obj, data and x
#'
#'@details If x is provided, the function calculates the corresponding transformation on the time series x using the reference value (ref) and scale (sw) stored in the data attributes. If x is not provided, the function calculates the corresponding transformation on all data from the data time series, which must be a matrix with the calculated differences between the column values of the original time series
#'
#'@param obj
#'@param data
#'@param x

#'@return Transformed full data matrix
#'@examples
#'@export
transform.ts_diff <- function(obj, data, x=NULL) {
  if (!is.null(x)) {
    ref <- attr(data, "ref")
    sw <- attr(data, "sw")
    x <- x-ref
    x <- (x-obj$gmin)/(obj$gmax-obj$gmin)
    return(x)
  }
  else {
    ref <- as.vector(data[,ncol(data)])
    cnames <- colnames(data)
    for (i in (ncol(data)-1):1)
      data[,i+1] <- data[, i+1] - data[,i]
    data <- data[,2:ncol(data)]
    data <- (data-obj$gmin)/(obj$gmax-obj$gmin)
    attr(data, "ref") <- ref
    attr(data, "sw") <- ncol(data)
    attr(data, "cnames") <- cnames
    return(data)
  }
}

#'@title Revert the transform applied in the transform.ts_diff function
#'
#'@description It takes as parameters the variables obj, data and x
#'
#'@details If the argument x is given, the function will just apply the inverse transform to that single value. Otherwise, it will apply the inverse transform to all data in data
#'
#'@param obj
#'@param data
#'@para x
#'
#'@return If the argument "x" is provided, the function returns the value corresponding to "x" in the original scale. Otherwise, the function returns the complete "data" time series at the original scale
#'
#'@examples
#'@export
inverse_transform.ts_diff <- function(obj, data, x=NULL) {
  cnames <- attr(data, "cnames")
  ref <- attr(data, "ref")
  sw <- attr(data, "sw")
  if (!is.null(x)) {
    x <- x * (obj$gmax-obj$gmin) + obj$gmin
    x <- x + ref
    return(x)
  }
  else {
    data <- data * (obj$gmax-obj$gmin) + obj$gmin
    data <- cbind(data, ref)
    for (i in (ncol(data)-1):1)
      data[,i] <- data[, i+1] - data[,i]
    colnames(data) <- cnames
    attr(data, "ref") <- ref
    attr(data, "sw") <- ncol(data)
    attr(data, "cnames") <- cnames
    return(data)
  }
}

#ts_swminmax
#'@title Time Series Sliding Window Min-Max
#'
#'@description It takes as parameter the variable remove_outliers. The ts_swminmax function creates an object for normalizing a time series based on the "sliding window min-max scaling" method
#'
#'@details The function uses the ts_normalize function to normalize the data and then adds the "ts_swminmax" class to the resulting object.
#'
#'@param remove_outliers logical: if TRUE (default) outliers will be removed.
#'@return a `ts_swminmax` object.
#'@examples
#'@export
ts_swminmax <- function(remove_outliers = TRUE) {
  obj <- ts_normalize(remove_outliers)
  class(obj) <- append("ts_swminmax", class(obj))
  return(obj)
}

#'@title adjust the obj object parameters for the "sw-min-max" normalization method
#'
#'@description It takes as parameters obj object and the data
#'
#'@details The function checks if the option to remove outliers was selected (obj$remove_outliers) and, if it is true, adjusts the outliers through the outliers() function and then applies the transformation to data through the transform() function
#'
#'@param obj
#'@param data
#'
#'@return The updated obj object
#'@examples
#'@export
fit.ts_swminmax <- function(obj, data) {
  if (obj$remove_outliers) {
    out <- outliers()
    out <- fit(out, data)
    data <- transform(out, data)
  }
  return(obj)
}

#'@title Normalizes each line of the input data to the range [0,1]
#'
#'@description It takes as parameters the variables obj, data, x
#'
#'@details Applies the SWMinMax transformation on the input data using the normalization parameters contained in the obj object
#'
#'@param obj
#'@param data
#'@param x

#'@return If the parameter x is given, the function returns the transformation applied to x. Otherwise, the function returns the data transformed input data
#'
#'@examples
#'@export
transform.ts_swminmax <- function(obj, data, x=NULL) {
  if (!is.null(x)) {
    i_min <- attr(data, "i_min")
    i_max <- attr(data, "i_max")
    x <- (x-i_min)/(i_max-i_min)
    return(x)
  }
  else {
    i_min <- apply(data, 1, min)
    i_max <- apply(data, 1, max)
    data <- (data-i_min)/(i_max-i_min)
    attr(data, "i_min") <- i_min
    attr(data, "i_max") <- i_max
    return(data)
  }
}

#'@title Do the inverse transformation of normalized data
#'
#'@description It takes as parameters the variables obj, data, x
#'
#'@details The function uses the technique of "min-max scaling" per line (or sliding window)
#'
#'@param obj
#'@param data
#'@param x

#'@return If the parameter x is provided, the function returns the denormalized value of x. Otherwise, the function assumes that data is an array of normalized data and returns the corresponding denormalized array
#'
#'@examples
#'@export
inverse_transform.ts_swminmax <- function(obj, data, x=NULL) {
  i_min <- attr(data, "i_min")
  i_max <- attr(data, "i_max")
  if (!is.null(x)) {
    x <- x * (i_max - i_min) + i_min
    return(x)
  }
  else {
    data <- data * (i_max - i_min) + i_min
    attr(data, "i_min") <- i_min
    attr(data, "i_max") <- i_max
    return(data)
  }
}

#ts_an
#'@title Time Series Adaptive Normalization
#'@description Transform data to a common scale while taking into account the
#' changes in the statistical properties of the data over time.
#'@details
#'
#'@param remove_outliers logical: if TRUE (default) outliers will be removed.
#'@param nw integer: .
#'@return a `ts_an` object.
#'@examples
#'@export
ts_an <- function(remove_outliers = TRUE, nw = 0) {
  obj <- ts_normalize(remove_outliers)
  obj$an_mean <- mean
  obj$nw <- nw
  class(obj) <- append("ts_an", class(obj))
  return(obj)
}

#'@title Removes the first few columns from a data array
#'
#'@description It takes as parameters the variables obj, data, func
#'
#'@details The function func is applied to the data matrix along the rows (axis 1) using the function apply(), with the option na.rm = TRUE to remove missing values
#'
#'@param obj
#'@param data
#'@param func
#'
#'@return
#'@examples
#'@export
ma.ts_an <- function(obj, data, func) {
  if (obj$nw != 0) {
    cols <- ncol(data) - ((obj$nw-1):0)
    data <- data[,cols]

  }
  an <- apply(data, 1, func, na.rm=TRUE)
}

#'@title Fits the "ts_an" normalization model to a training dataset
#'
#'@description It takes two arguments: obj and data. It computes the moving average of the input data using the "ma.ts_an" function, subtracts the moving average from the input data, and scales the data so that the values are in the range between 0 and 1
#'
#'@details If the "remove_outliers" option is enabled, the function also removes outliers from the data using the "outliers" function and adjusts the data transformation using the "transform" function
#'
#'@param obj
#'@param data
#'
#'@return The adjusted "ts_an" object
#'@examples
#'@export
fit.ts_an <- function(obj, data) {
  input <- data[,1:(ncol(data)-1)]
  an <- ma.ts_an(obj, input, obj$an_mean)
  data <- data - an #

  if (obj$remove_outliers) {
    out <- outliers()
    out <- fit(out, data)
    data <- transform(out, data)
  }

  obj$gmin <- min(data)
  obj$gmax <- max(data)

  return(obj)
}

#'@title Normalize the input data
#'
#'@description It takes 3 arguments: obj, data and x
#'
#'@details The function subtracts the value of the annual moving average (calculated by the ma.ts_an function) from each sample and then applying min-max normalization, transforming the data into a scale between 0 and 1
#'
#'@param obj
#'@param data
#'@param x
#'
#'@return Normalized data along with annual moving average value
#'@examples
#'@export
transform.ts_an <- function(obj, data, x=NULL) {
  if (!is.null(x)) {
    an <- attr(data, "an")
    x <- x - an #
    x <- (x - obj$gmin) / (obj$gmax-obj$gmin)
    return(x)
  }
  else {
    an <- ma.ts_an(obj, data, obj$an_mean)
    data <- data - an #
    data <- (data - obj$gmin) / (obj$gmax-obj$gmin)
    attr(data, "an") <- an
    return (data)
  }
}

#'@title Perform the inversion of the transformation performed by the transform.t_an function
#'
#'@description It takes 3 arguments: obj, data and x
#'
#'@details If a vector x is given as input, the function performs the inverse transformation on that vector. Otherwise, if a data matrix is given as input, the function performs the inverse transformation on each column of that matrix
#'
#'@param obj
#'@param data
#'@param x
#'
#'@return The final result of the inverse transformation
#'@examples
#'@export
inverse_transform.ts_an <- function(obj, data, x=NULL) {
  an <- attr(data, "an")
  if (!is.null(x)) {
    x <- x * (obj$gmax-obj$gmin) + obj$gmin
    x <- x + an #
    return(x)
  }
  else {
    data <- data * (obj$gmax-obj$gmin) + obj$gmin
    data <- data + an #
    attr(data, "an") <- an
    return (data)
  }
}

#'@title Time Series Adaptive Normalization (Exponential Moving Average - EMA)
#'
#'@description It takes 2 parameters: remove_outliers and nw
#'
#'@details The function uses the "emean" function to calculate the exponentially weighted average. The time series can be pre-processed to remove outliers (remove_outliers) and can also have a specified window size for smoothing (nw)
#'
#'@param remove_outliers logical: if TRUE (default) outliers will be removed.
#'@param nw
#'@return a `ts_ean` object.
#'@examples
#'@export
ts_ean <- function(remove_outliers = TRUE, nw = 0) {
  emean <- function(data, na.rm = FALSE) {
    n <- length(data)

    y <- rep(0, n)
    alfa <- 1 - 2.0 / (n + 1);
    for (i in 0:(n-1)) {
      y[n-i] <- alfa^i
    }

    m <- sum(y * data, na.rm = na.rm)/sum(y, na.rm = na.rm)
    return(m)
  }
  obj <- ts_an(remove_outliers, nw = nw)
  obj$an_mean <- emean
  class(obj) <- append("ts_ean", class(obj))
  return(obj)
}

