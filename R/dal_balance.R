# DAL Library
# version 2.1

# depends dal_transform.R

# class balance_dataset
# loadlibrary("smotefamily")

#'@title Class Balance Dataset
#'@description The R class BalanceDataset represents a dataset that has been balanced in terms of class distribution. It can be used as a wrapper around a standard dataset to ensure that the classes are equally represented in the data used for modeling or analysis.
#'@details The BalanceDataset class has the following properties:
#'data: the balanced data frame; method: the balancing method used (oversampling, undersampling, or both);
#'seed: the random seed used for reproducibility;
#'And the BalanceDataset class has the following methods:
#'summary(): provides a summary of the balanced dataset, including the class distribution before and after balancing;
#'plot(): produces a plot of the class distribution before and after balancing
#'
#'@param attribute The attribute to be balanced in the dataset.
#'@return An instance of the BalanceDataset class.
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
#'@description The R class BalanceOversampling represents a method to balance the class distribution of a dataset by oversampling the minority class. It can be used to increase the representation of the minority class in the data used for modeling or analysis.
#'@details The BalanceOversampling class has the following properties:
#'data: the oversampled data frame;
#'seed: the random seed used for reproducibility.
#'The BalanceOversampling class has the following methods:
#'summary(): provides a summary of the oversampled dataset, including the class distribution before and after oversampling;
#'plot(): produces a plot of the class distribution before and after oversampling.
#'
#'@param attribute The attribute to be balanced through oversampling.
#'@return An instance of the BalanceOversampling class.
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
#'@description The R class BalanceSubsampling represents a method to balance the class distribution of a dataset by subsampling the majority class. It can be used to reduce the representation of the majority class in the data used for modeling or analysis.
#'@details The BalanceSubsampling class has the following properties:
#'data: the subsampled data frame;
#'seed: the random seed used for reproducibility.
#'The BalanceSubsampling class has the following methods:
#'summary(): provides a summary of the subsampled dataset, including the class distribution before and after subsampling;
#'plot(): produces a plot of the class distribution before and after subsampling.
#'
#'@param attribute The attribute to be balanced through subsampling.
#'@return An instance of the BalanceSubsampling class.
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
