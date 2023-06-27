#'@title Detect outliers in a dataset using the boxplot method
#'@description The function receives a dataset "data" and an "alpha" parameter (default 1.5), which controls the upper limit of the boxplot
#'@param data dataset
#'@param alpha Threshold for outliers
#'@return The function returns a boolean array with true values for values considered to be outliers
#'@examples detector <- harbinger()
#'@importFrom stats quantile
#'@export
har_outliers <- function(data, alpha = 1.5){
  org = length(data)
  cond <- rep(FALSE, org)
  q = stats::quantile(data, na.rm=TRUE)
  IQR = q[4] - q[2]
  lq1 = as.double(q[2] - alpha*IQR)
  hq3 = as.double(q[4] + alpha*IQR)
  cond = data > hq3
  return (cond)
}


#'@title Detect and return the indices of outliers in a dataset using the boxplot method
#'@description The function receives a dataset "data" and an "alpha" parameter (default 1.5), which controls the upper limit of the boxplot
#'@param data dataset
#'@param alpha Threshold for outliers
#'@return A boolean vector indicating whether each value in the data set is an outlier or not and a vector of indices of the values considered to be outliers
#'@examples detector <- harbinger()
#'@export
har_outliers_idx <- function(data, alpha = 1.5){
  cond <- har_outliers(data, alpha)
  index.cp = which(cond)
  return (index.cp)
}
