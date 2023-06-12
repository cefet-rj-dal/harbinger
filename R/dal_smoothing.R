# DAL Library
# version 2.1

# depends dal_transform.R
# depends dal_fit.R

### smoothing

# loadlibrary("dplyr")
#'@title Smoothing
#'@description Smoothing is a statistical technique that is used to reduce the noise in a signal or a dataset by removing the high-frequency components. It involves applying a smoothing function or algorithm to the dataset that results in a smoother curve that is easier to analyze. The smoothing technique can be applied to any type of data, including time-series data, images, and sound signals.
#'@details The process of smoothing involves replacing each data point with an average or weighted average of neighboring points. There are several smoothing algorithms that can be used, depending on the characteristics of the data. Some of the common smoothing techniques include moving average smoothing, Gaussian smoothing, Savitzky-Golay smoothing, and exponential smoothing.
#'The syntax for the smoothing function is as follows:
#'x: A numeric vector or time series data that needs to be smoothed.
#'window_size: An integer value representing the size of the window.
#'
#'@param n
#'@return
#'@examples
#'@export
smoothing <- function(n) {
  obj <- dal_transform()
  obj$n <- n
  class(obj) <- append("smoothing", class(obj))
  return(obj)
}

#'@export
optimize.smoothing <- function(obj, data, do_plot=FALSE) {
  n <- obj$n
  opt <- data.frame()
  interval <- list()
  for (i in 1:n)
  {
    obj$n <- i
    obj <- fit(obj, data)
    vm <- transform(obj, data)
    mse <- mean((data - vm)^2, na.rm = TRUE)
    row <- c(mse , i)
    opt <- rbind(opt, row)
  }
  colnames(opt)<-c("mean","num")
  curv <- fit_curvature_max()
  res <- transform(curv, opt$mean)
  obj$n <- res$x
  if (do_plot)
    plot(curv, y=opt$mean, res)
  return(obj)
}

#'@export
fit.smoothing <- function(obj, data) {
  v <- data
  interval <- obj$interval
  names(interval) <- NULL
  interval[1] <- min(v)
  interval[length(interval)] <- max(v)
  interval.adj <- interval
  interval.adj[1] <- -.Machine$double.xmax
  interval.adj[length(interval)] <- .Machine$double.xmax
  obj$interval <- interval
  obj$interval.adj <- interval.adj
  return(obj)
}

#'@export
transform.smoothing <- function(obj, data) {
  v <- data
  interval.adj <- obj$interval.adj
  vp <- cut(v, unique(interval.adj), FALSE, include.lowest=TRUE)
  m <- tapply(v, vp, mean)
  vm <- m[vp]
  return(vm)
}

# smoothing by interval
#'@title Smoothing by interval
#'@description The "smoothing by interval" function is used to apply a smoothing technique to a vector or time series data using a moving window approach.
#'@details  The function takes in three arguments:
#'data: a numeric vector or time series data to be smoothed.
#'window_size: an integer value specifying the size of the moving window. It should be an odd number to ensure a centered window.
#'method: a character string specifying the smoothing method to be used. It can be one of "simple", "linear", "exponential", "spline", "kernel", or "loess".
#'
#'@param n
#'@return
#'@examples
#'@export
smoothing_inter <- function(n) {
  obj <- smoothing(n)
  class(obj) <- append("smoothing_inter", class(obj))
  return(obj)
}

#'@export
fit.smoothing_inter <- function(obj, data) {
  v <- data
  n <- obj$n
  bp <- boxplot(v, range=1.5, plot = FALSE)
  bimax <- bp$stats[5]
  bimin <- bp$stats[1]
  if (bimin == bimax) {
    bimax = max(v)
    bimin = min(v)
  }
  obj$interval <- seq(from = bimin, to = bimax, by = (bimax-bimin)/n)
  obj <- fit.smoothing(obj, data)
  return(obj)
}

# smoothing by freq
#'@title Smoothing by Freq
#'@description The 'smoothing_freq' function is used to smooth a given time series data by aggregating observations within a fixed frequency.
#'@details The function takes in three arguments:
#'ts_data: a time series object to be smoothed.
#'frequency: the frequency at which to aggregate the observations (e.g., "day", "week", "month").
#'method: the method used to calculate the smoothed values (e.g., "mean", "median", "max", "min").
#'
#'@param n
#'@return
#'@examples
#'@export
smoothing_freq <- function(n) {
  obj <- smoothing(n)
  class(obj) <- append("smoothing_freq", class(obj))
  return(obj)
}

#'@export
fit.smoothing_freq <- function(obj, data) {
  v <- data
  n <- obj$n
  p <- seq(from = 0, to = 1, by = 1/n)
  obj$interval <- quantile(v, p)
  obj <- fit.smoothing(obj, data)
  return(obj)
}

# smoothing by cluster
#'@title Smoothing by cluster
#'@description The function smoothing_cluster() is used to perform smoothing of data by cluster. This function takes as input a numeric vector, which is divided into clusters using the k-means algorithm. The mean of each cluster is then calculated and used as the smoothed value for all observations within that cluster.
#'@details The arguments of function:
#'x: a numeric vector of values to be smoothed;
#'k: the number of clusters to use in the k-means algorithm.
#'
#'@param n
#'@return
#'@examples
#'@export
smoothing_cluster <- function(n) {
  obj <- smoothing(n)
  class(obj) <- append("smoothing_cluster", class(obj))
  return(obj)
}

#'@import stats
#'@export
fit.smoothing_cluster <- function(obj, data) {
  v <- data
  n <- obj$n
  km <- kmeans(x = v, centers = n)
  s <- sort(km$centers)
  s <- stats::filter(s,rep(1/2,2), sides=2)[1:(n-1)]
  obj$interval <- c(min(v), s, max(v))
  obj <- fit.smoothing(obj, data)
  return(obj)
}

#'@title Smoothing by evaluation
#'@description The smoothing_evaluation() function performs a smoothing evaluation using cross-validation. It calculates the mean squared error (MSE) for each smoothing parameter and returns a data frame with the results. The function uses the smoothing technique specified by the user to smooth the data.
#'@details  The arguments of function:
#'data: a data frame containing the dataset to be smoothed;
#'target: a string indicating the target variable;
#'method: a string indicating the smoothing method to be used ("smoothing by interval", "smoothing by freq", "smoothing by cluster");
#'parameters: a vector containing the parameters to be used for the smoothing method. The number of parameters will depend on the chosen method;
#'k: an integer indicating the number of folds to be used for cross-validation.
#'
#'@param data
#'@param attribute
#'@return
#'@examples
#'@import dplyr
#'@export
smoothing_evaluation <- function(data, attribute) {
  obj <- list(data=as.factor(data), attribute=as.factor(attribute))
  attr(obj, "class") <- "cluster_evaluation"

  compute_entropy <- function(obj) {
    value <- getOption("dplyr.summarise.inform")
    options(dplyr.summarise.inform = FALSE)

    dataset <- data.frame(x = obj$data, y = obj$attribute)
    tbl <- dataset %>% dplyr::group_by(x, y) %>% summarise(qtd=n())
    tbs <- dataset %>% dplyr::group_by(x) %>% summarise(t=n())
    tbl <- base::merge(x=tbl, y=tbs, by.x="x", by.y="x")
    tbl$e <- -(tbl$qtd/tbl$t)*log(tbl$qtd/tbl$t,2)
    tbl <- tbl %>% dplyr::group_by(x) %>% dplyr::summarise(ce=sum(e), qtd=sum(qtd))
    tbl$ceg <- tbl$ce*tbl$qtd/length(obj$data)
    obj$entropy_clusters <- tbl
    obj$entropy <- sum(obj$entropy$ceg)

    options(dplyr.summarise.inform = value)
    return(obj)
  }
  obj <- compute_entropy(obj)
  return(obj)
}
