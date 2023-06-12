# DAL Library
# version 2.1

# depends dal_transform.R
# depends cla_classification.R

# loadlibrary("RSNNS")
# loadlibrary("Matrix")

# majority
#'@title Majority Classification
#'@description This function creates a classification object that uses the majority vote strategy to predict the target attribute. Given a target attribute, the function counts the number of occurrences of each value in the dataset and selects the one that appears most often.
#'@details The function takes two arguments: the name of the attribute used as target classification and the possible values for the target classification. The second argument is optional and should be provided only if the dataset does not contain all possible values for the target attribute.
#'@param attribute Name of the attribute used as target classification.
#'@param slevels Possible values for the target classification.
#'@return Returns a classification object.
#'@examples
#'@export
cla_majority <- function(attribute, slevels=NULL) {
  obj <- classification(attribute, slevels)

  class(obj) <- append("cla_majority", class(obj))
  return(obj)
}

#'@import RSNNS
#'@export
fit.cla_majority <- function(obj, data) {
  data <- adjust_data.frame(data)
  data[,obj$attribute] <- adjust.factor(data[,obj$attribute], obj$ilevels, obj$slevels)
  obj <- fit.classification(obj, data)

  y <- RSNNS::decodeClassLabels(data[,obj$attribute])
  cols <- apply(y, 2, sum)
  col <- match(max(cols),cols)
  obj$model <- list(cols=cols, col=col)

  obj <- register_log(obj)
  return(obj)
}

#'@import Matrix
#'@export
predict.cla_majority <- function(obj, x) {
  rows <- nrow(x)
  cols <- length(obj$model$cols)
  prediction <- Matrix::Matrix(rep.int(0, rows*cols), nrow=rows, ncol=cols)
  prediction[,obj$model$col] <- 1
  colnames(prediction) <- names(obj$model$cols)
  prediction <- as.matrix(prediction)
  return(prediction)
}


