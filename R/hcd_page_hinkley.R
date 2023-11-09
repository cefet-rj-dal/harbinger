#'@title Adapted Page Hinkley method
#'@description Change-point detection method works by computing the observed values and their mean up to the current moment <doi:10.2307/2333009>.
#'@param min_instances The minimum number of instances before detecting change
#'@param delta The delta factor for the Page Hinkley test
#'@param threshold The change detection threshold (lambda)
#'@param alpha The forgetting factor, used to weight the observed value and the mean
#Page Hinkley detection: E. S. Page. (1954) Continuous Inspection Schemes, Biometrika 41(1/2), 100–115.
#Page Hinkley detection implementation: Scikit-Multiflow, https://github.com/scikit-multiflow/scikit-multiflow/blob/a7e316d/src/skmultiflow/drift_detection/page_hinkley.py#L4
#'@return `hcp_page_hinkley` object
#'@examples
#'library("daltoolbox")
#'
#'n <- 100  # size of each segment
#'serie1 <- c(sin((1:n)/pi), 2*sin((1:n)/pi), 10 + sin((1:n)/pi),
#'            10-10/n*(1:n)+sin((1:n)/pi)/2, sin((1:n)/pi)/2)
#'serie2 <- 2*c(sin((1:n)/pi), 2*sin((1:n)/pi), 10 + sin((1:n)/pi),
#'            10-10/n*(1:n)+sin((1:n)/pi)/2, sin((1:n)/pi)/2)
#'data <- data.frame(serie1, serie2)#'
#'event <- rep(FALSE, nrow(data))
#'
#'model <- fit(hcd_page_hinkley(threshold=3), data)
#'detection <- detect(model, data)
#'print(detection[(detection$event),])
#'
#'@export
hcd_page_hinkley <- function(min_instances=30, delta=0.005, threshold=50, alpha=1-0.0001) {
  obj <- harbinger()
  obj$min_instances <- min_instances
  obj$delta <- delta
  obj$threshold <- threshold
  obj$alpha = alpha
  obj$x_mean <- 0
  obj$sum <- 0
  obj$sample_count <- 1
  class(obj) <- append("hcd_page_hinkley", class(obj))
  return(obj)
}

#'@importFrom stats ecdf
#'@importFrom stats complete.cases
#'@export
detect.hcd_page_hinkley <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)
  if(!is.data.frame(serie)) stop("serie is not a data frame", call. = FALSE)

  update <- function(obj, x){
    obj$x_mean <- obj$x_mean + (x - obj$x_mean)/obj$sample_count
    obj$sum <- max(0, obj$alpha * obj$sum + (x - obj$x_mean - obj$delta))
    obj$sample_count <- obj$sample_count + 1

    if(obj$sample_count < obj$min_instances){
      return(list(obj=obj, pred=FALSE))
    }
    else if(obj$sum > obj$threshold){
      obj$x_mean <- 0
      obj$sum <- 0
      obj$sample_count <- 1
      return(list(obj=obj, pred=TRUE))
    }
    else{
      return(list(obj=obj, pred=FALSE))
    }
  }

  non_na <- base::which(stats::complete.cases(serie))
  data <- serie[non_na, ]

  # Transform to percentile (0 to 1) if data has more than one column
  data <- base::sapply(data, function(c) stats::ecdf(c)(c))
  data <- base::apply(data, 1, mean)

  # Perform change point detection using Page Hinkley
  ph_result <- rep(FALSE, length(data))
  output <- update(obj, data[1])
  for (i in 1:length(data)){
    output <- update(output$obj, data[i])
    ph_result[i] <- output$pred
  }

  inon_na <- rep(FALSE, length(non_na))
  n <- length(ph_result)
  if (n > 1)
    inon_na[ph_result[1:(n-1)]] <- TRUE

  i <- rep(NA, nrow(serie))
  i[non_na] <- inon_na
  detection <- data.frame(idx=1:length(i), event = i, type="")
  detection$type[i] <- "changepoint"

  return(detection)
}
