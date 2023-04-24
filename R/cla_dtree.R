# DAL Library
# version 2.1

# depends dal_transform.R
# depends cla_classification.R

# decision_tree
# loadlibrary("tree")

#'@title Decision Tree Classification
#'@description Classification using Decision Tree algorithm
#'@details
#'
#'@param attribute - name of the attribute used as target classification
#'@param slevels - possible values for the target classification
#'@return classification object
#'@examples
#'@export
cla_dtree <- function(attribute, slevels=NULL) {
  obj <- classification(attribute, slevels)

  class(obj) <- append("cla_dtree", class(obj))
  return(obj)
}

#'@import tree
#'@export
fit.cla_dtree <- function(obj, data) {
  data <- adjust_data.frame(data)
  data[,obj$attribute] <- adjust.factor(data[,obj$attribute], obj$ilevels, obj$slevels)
  obj <- fit.classification(obj, data)

  regression <- formula(paste(obj$attribute, "  ~ ."))
  obj$model <- tree::tree(regression, data)

  obj <- register_log(obj)
  return(obj)
}

#'@export
predict.cla_dtree <- function(obj, x) {
  x <- adjust_data.frame(x)
  x <- x[,obj$x]

  prediction <- predict(obj$model, x, type="vector")

  return(prediction)
}
