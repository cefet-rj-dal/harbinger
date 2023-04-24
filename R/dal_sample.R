# DAL Library
# version 2.1

# depends dal_transform.R

# data_sample
#'@title
#'@description
#'@details
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
#'@title
#'@description
#'@details
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
