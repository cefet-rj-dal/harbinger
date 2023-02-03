#===== Boxplot analysis of results ======
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

outliers.boxplot.index <- function(data, alpha = 1.5){
  cond <- outliers.boxplot(data, alpha)
  index.cp = which(cond)
  return (index.cp)
}
