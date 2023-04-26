# DAL Library
# version 2.1

# depends dal_transform.R

# class balance_dataset
# loadlibrary("smotefamily")

#'@title Class Balance Dataset
#'@description
#'@details
#'
#'@param attribute
#'@return
#'@examples
#'@export
balance_dataset <- function(attribute) {
  obj <- dal_transform()
  obj$attribute <- attribute
  class(obj) <- append("balance_dataset", class(obj))
  return(obj)
}

#balance_oversampling

#'@title Class Balance Oversampling
#'@description
#'@details
#'
#'@param attribute
#'@return
#'@examples
#'@export
balance_oversampling <- function(attribute) {
  obj <- balance_dataset(attribute)
  class(obj) <- append("balance_oversampling", class(obj))
  return(obj)
}

#'@export
transform.balance_oversampling <- function(obj, data) {
  j <- match(obj$attribute, colnames(data))
  x <- sort((table(data[,obj$attribute])))
  result <- data[data[obj$attribute]==names(x)[length(x)],]

  for (i in 1:(length(x)-1)) {
    small <- data[,obj$attribute]==names(x)[i]
    large <- data[,obj$attribute]==names(x)[length(x)]
    data_smote <- data[small | large,]
    syn_data <- SMOTE(data_smote[,-j], as.integer(data_smote[,j]))$syn_data
    syn_data$class <- NULL
    syn_data[obj$attribute] <- data[small, j][1]
    result <- rbind(result, data[small,])
    result <- rbind(result, syn_data)
  }
  return(result)
}

# balance_subsampling
#'@title Class Balance Subsampling
#'@description
#'@details
#'
#'@param attribute
#'@return
#'@examples
#'@export
balance_subsampling <- function(attribute) {
  obj <- balance_dataset(attribute)
  class(obj) <- append("balance_subsampling", class(obj))
  return(obj)
}

#'@export
transform.balance_subsampling <- function(obj, data) {
  data <- data
  attribute <- obj$attribute
  x <- sort((table(data[,attribute])))
  qminor = as.integer(x[1])
  newdata = NULL
  for (i in 1:length(x)) {
    curdata = data[data[,attribute]==(names(x)[i]),]
    idx = sample(1:nrow(curdata),qminor)
    curdata = curdata[idx,]
    newdata = rbind(newdata, curdata)
  }
  data <- newdata
  return(data)
}
