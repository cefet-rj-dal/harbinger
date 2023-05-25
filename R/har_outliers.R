#===== Boxplot analysis of results ======

#'@title Detect outliers in a dataset using the boxplot method
#'
#'@description The function receives a dataset "data" and an "alpha" parameter (default 1.5), which controls the upper limit of the boxplot
#'
#'@details The function calculates the quartiles of the dataset, and then calculates the upper and lower bounds of the boxplot using the alpha parameter
#'
#'@param data
#'@param alpha
#'
#'@return The function returns a boolean array with true values for values considered to be outliers
#'@examples
#'@export
outliers.boxplot <- function(data, alpha = 1.5){
  org = length(data)
  cond <- rep(FALSE, org)
  q = quantile(data, na.rm=TRUE)
  IQR = q[4] - q[2]
  lq1 = as.double(q[2] - alpha*IQR)
  hq3 = as.double(q[4] + alpha*IQR)
  #cond = data < lq1 | data > hq3
  cond = data > hq3
  return (cond)
}


#'@title Detect and return the indices of outliers in a dataset using the boxplot method
#'
#'@description The function receives a dataset "data" and an "alpha" parameter (default 1.5), which controls the upper limit of the boxplot
#'
#'@details The function calls the "outliers.boxplot" function internally to obtain a boolean vector "cond" with TRUE values for the values considered as outliers and FALSE for the others
#'
#'@param data
#'@param alpha
#'
#'@return A boolean vector indicating whether each value in the data set is an outlier or not and a vector of indices of the values considered to be outliers
#'@examples
#'@export
outliers.boxplot.index <- function(data, alpha = 1.5){
  cond <- outliers.boxplot(data, alpha)
  index.cp = which(cond)
  return (index.cp)
}
