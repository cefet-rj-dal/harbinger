# DAL Library
# version 2.1

# depends dal_transform.R

# naive_bayes

# loadlibrary("e1071")

#'@title Naive Bayes Classifier
#'@description
#'@details
#'
#'@param attribute - name of the attribute used as target classification
#'@param slevels - possible values for the target classification
#'@return
#'@examples
#'@export
cla_nb <- function(attribute, slevels=NULL) {
  obj <- classification(attribute, slevels)

  class(obj) <- append("cla_nb", class(obj))
  return(obj)
}

#'@import e1071
#'@export
fit.cla_nb <- function(obj, data) {
  data <- adjust_data.frame(data)
  data[,obj$attribute] <- adjust.factor(data[,obj$attribute], obj$ilevels, obj$slevels)
  obj <- fit.classification(obj, data)

  regression <- formula(paste(obj$attribute, "  ~ ."))
  obj$model <- e1071::naiveBayes(regression, data, laplace=0)

  obj <- register_log(obj)
  return(obj)
}

#'@export
predict.cla_nb  <- function(obj, x) {
  x <- adjust_data.frame(x)
  x <- x[,obj$x, drop=FALSE]

  prediction <- predict(obj$model, x, type="raw")

  return(prediction)
}
