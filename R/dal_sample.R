# DAL Library
# version 2.1

# depends dal_transform.R

# data_sample
#'@title Data Sample
#'@description The data_sample function in R is used to randomly sample data from a given data frame. It can be used to obtain a subset of data for further analysis or modeling.
#'@details The function takes the following arguments:
#'data: a data frame or a matrix containing the data to be sampled
#'size: the number of samples to be drawn from the data. If NULL, the function will return a data frame with the same number of rows as the input data
#'replace: a logical value indicating whether the samples should be drawn with or without replacement. The default is FALSE (sampling without replacement)
#'prob: a vector of probabilities for each row of the data. The length of this vector should be equal to the number of rows in the data. If NULL, all rows will have equal probability of being selected;
#'seed: an optional integer value that can be used to set the random number generator seed for reproducibility.
#'
#'@return
#'@examples
#'@export
data_sample <- function() {
  obj <- dal_transform()
  class(obj) <- append("data_sample", class(obj))
  return(obj)
}

#'@title
#'@description
#'@details
#'
#'@param obj object: .
#'@param data
#'@param ... optional arguments./ further arguments passed to or from other methods.
#'@return
#'@examples
#'@export
train_test <- function(obj, data, ...) {
  UseMethod("train_test")
}

#'@export
train_test.default <- function(obj, data) {
  return(list())
}

#'@title
#'@description
#'@details
#'
#'@param obj object: .
#'@param data
#'@param k
#'@return
#'@examples
#'@export
k_fold <- function(obj, data, k) {
  UseMethod("k_fold")
}

#'@export
k_fold.default <- function(obj, data, k) {
  return(list())
}


# sample_random
#'@title Sample Random
#'@description The sample_random function in R is used to generate a random sample of specified size from a given data set.
#'@details The function takes the following arguments:
#'data: a vector or data frame from which to take a random sample.
#'size: the number of observations to include in the sample.
#'replace: logical, "should sampling be with replacement?".
#'
#'@return
#'@examples
#'@export
sample_random <- function() {
  obj <- data_sample()
  class(obj) <- append("sample_random", class(obj))
  return(obj)
}

#'@export
train_test.sample_random <- function(obj, data, perc=0.8) {
  idx <- base::sample(1:nrow(data),as.integer(perc*nrow(data)))
  train <- data[idx,]
  test <- data[-idx,]
  return (list(train=train, test=test))
}

#'@export
k_fold.sample_random <- function(obj, data, k) {
  folds <- list()
  samp <- list()
  p <- 1.0 / k
  while (k > 1) {
    samp <- train_test.sample_random(obj, data, p)
    data <- samp$test
    folds <- append(folds, list(samp$train))
    k = k - 1
    p = 1.0 / k
  }
  folds <- append(folds, list(samp$test))
  return (folds)
}

#'@title
#'@description
#'@details
#'
#'@param folds
#'@param k
#'@return
#'@examples
#'@export
train_test_from_folds <- function(folds, k) {
  test <- folds[[k]]
  train <- NULL
  for (i in 1:length(folds)) {
    if (i != k)
      train <- rbind(train, folds[[i]])
  }
  return (list(train=train, test=test))
}
