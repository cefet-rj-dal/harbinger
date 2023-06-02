# DAL Library
# version 2.1

# depends dal_transform.R

### outliers
#'@title Identify outliers in a data base
#'
#'@description A function that takes a floating point variable as parameter
#'
#'@details Create an object that stores the alpha value that is used as a bound to identify outliers
#'
#'@param alpha
#'
#'@return An outlier object
#'
#'@examples
#'@export
outliers <- function(alpha = 1.5) {
  obj <- dal_transform()
  obj$alpha <- alpha
  class(obj) <- append("outliers", class(obj))
  return(obj)
}

#'@title Calculates upper and lower bounds based on alpha value
#'
#'@description A function that takes two parameters, an object and a collection of data
#'
#'@details The function checks whether the input data object is an array or a data frame. It then checks whether each column is numeric using the is.numeric function and, if so, calculates the first and third quartiles (Q1 and Q3) using the quantile function. Then the function calculates the interquartile range (IQR) as the difference between Q3 and Q1
#'
#'@param obj
#'@param data
#'
#'@return An updated 'outliers' object, containing the lower and upper bounds for each numerical variable
#'
#'@examples
#'@export
fit.outliers <- function(obj, data) {
  lq1 <- NA
  hq3 <- NA
  if(is.matrix(data) || is.data.frame(data)) {
    lq1 <- rep(NA, ncol(data))
    hq3 <- rep(NA, ncol(data))
    if (nrow(data) >= 30) {
      for (i in 1:ncol(data)) {
        if (is.numeric(data[,i])) {
          q <- quantile(data[,i])
          IQR <- q[4] - q[2]
          lq1[i] <- q[2] - obj$alpha*IQR
          hq3[i] <- q[4] + obj$alpha*IQR
        }
      }
    }
  }
  else {
    if ((length(data) >= 30) && is.numeric(data)) {
      q <- quantile(data)
      IQR <- q[4] - q[2]
      lq1 <- q[2] - obj$alpha*IQR
      hq3 <- q[4] + obj$alpha*IQR
    }
  }
  obj$lq1 <- lq1
  obj$hq3 <- hq3
  return(obj)
}

#'@title Remove outliers from data
#'
#'@description The function takes two arguments, the first is an outliers object returned by the outliers() function, which contains the necessary parameters to perform the transformation, including the cutoff limits calculated in the fit.outliers function. The second argument is the set of input data you want to transform
#'
#'@details Removes lines that contain values that are considered outliers according to the limits calculated in the fit.outliers function
#'
#'@param obj
#'@param data
#'
#'@return returns the output dataset after applying the transformation and adds an "idx" attribute that contains a boolean vector indicating which rows were removed from the original dataset
#'
#'@examples
#'@export
transform.outliers <- function(obj, data) {
  idx <- FALSE
  lq1 <- obj$lq1
  hq3 <- obj$hq3
  if (is.matrix(data) || is.data.frame(data)) {
    idx = rep(FALSE, nrow(data))
    for (i in 1:ncol(data))
      if (!is.na(lq1[i]) && !is.na(hq3[i]))
        idx = idx | (!is.na(data[,i]) & (data[,i] < lq1[i] | data[,i] > hq3[i]))
  }
  if(is.matrix(data))
    data <- adjust_matrix(data[!idx,])
  else if (is.data.frame(data))
    data <- adjust_data.frame(data[!idx,])
  else {
    if (!is.na(lq1) && !is.na(hq3)) {
      idx <- data < lq1 | data > hq3
      data <- data[!idx]
    }
    else
      idx <- rep(FALSE, length(data))
  }
  attr(data, "idx") <- idx
  return(data)
}

