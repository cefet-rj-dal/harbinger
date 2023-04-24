# DAL Library
# version 2.1

# depends dal_transform.R
# depends dal_fit.R

### smoothing

# loadlibrary("dplyr")
#'@title
#'@description
#'@details
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
#'@title
#'@description
#'@details
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
#'@title
#'@description
#'@details
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
#'@title
#'@description
#'@details
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

#'@title
#'@description
#'@details
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
