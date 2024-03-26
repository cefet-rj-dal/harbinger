#'@title KSWIN method
#'@description Kolmogorov-Smirnov Windowing method for concept drift detection <doi:10.1016/j.neucom.2019.11.111>.
#'@param alpha Probability for the test statistic of the Kolmogorov-Smirnov-Test The alpha parameter is very sensitive, therefore should be set below 0.01.
#'@param window_size Size of the sliding window
#'@param stat_size Size of the statistic window
#'@param data Already collected data to avoid cold start.
#KSWIN detection: Christoph Raab, Moritz Heusinger, Frank-Michael Schleif, Reactive Soft Prototype Computing for Concept Drift Streams, Neurocomputing, 2020.
#KSWIN detection implementation: Scikit-Multiflow, https://github.com/scikit-multiflow/scikit-multiflow/blob/a7e316d/src/skmultiflow/drift_detection/kswin.py#L5
#'@return `hcd_kswin` object
#'@examples
#'library('daltoolbox')
#'
#'n <- 100  # Number of time points
#'# Multivariate Example
#'data <- as.data.frame(c(sin((1:n)/pi), 2*sin((1:n)/pi), 10 + sin((1:n)/pi), 10-10/n*(1:n)+sin((1:n)/pi)/2, sin((1:n)/pi)/2))
#'names(data) <- c('serie1')
#'data['serie2'] <- c(sin((1:n)/pi), 2*sin((1:n)/pi), 10 + sin((1:n)/pi), 10-10/n*(1:n)+sin((1:n)/pi)/2, sin((1:n)/pi)/2) + runif(length(data), 0, 1)
#'
#'event <- rep(FALSE, n)
#'
#'model <- fit(hcd_kswin(), data)
#'detection <- detect(model, data)
#'print(detection[(detection$event),])
#'
#'@export
hcd_kswin <- function(window_size=100, stat_size=30, alpha=0.005, data=NULL) {
    obj <- harbinger()
    obj$window_size <- window_size
    obj$stat_size <- stat_size
    obj$alpha = alpha
    obj$p_value <- 0
    obj$n <- 0

    if ((obj$alpha < 0) | (obj$alpha > 1)) stop("Alpha must be between 0 and 1", call = FALSE)
    if (obj$window_size < 0) stop("window_size must be greater than 0", call = FALSE)
    if (obj$window_size < obj$stat_size) stop("stat_size must be smaller than window_size")

    if (missing(data)){
      obj$window <- c()
    }
    else{
      obj$window <- data
    }

    class(obj) <- append("hcd_kswin", class(obj))
    return(obj)
}

#'@importFrom stats ecdf
#'@importFrom stats complete.cases
#'@export
detect.hcd_kswin <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)
  if(!is.data.frame(serie)) stop("serie is not a data frame", call. = FALSE)

  update <- function(obj, x){
      obj$n <- obj$n + 1
      currentLength <- nrow(obj$window)
      if (is.null(currentLength)){
        currentLength <- 0
      }
      if (currentLength >= obj$window_size){
        obj$window <- obj$window[-1, drop=FALSE]
        rnd_window <- sample(x=obj$window[1:(length(obj$window)-obj$stat_size)], size=obj$stat_size)

        ks_res <- ks.test(rnd_window, obj$window[(length(obj$window)-obj$stat_size):length(obj$window)], exact=TRUE)
        st <- unlist(ks_res[1])
        obj$p_value <- unlist(ks_res[2])

        if((obj$p_value < obj$alpha) & (st > 0.1)){
          obj$window <- obj$window[(length(obj$window)-obj$stat_size):length(obj$window)]
          obj$window <- rbind(obj$window, x)
          return(list(obj=obj, pred=TRUE))
        }
        else{
          obj$window <- rbind(obj$window, x)
          return(list(obj=obj, pred=FALSE))
        }
      }else{
        obj$window <- rbind(obj$window, x)
        return(list(obj=obj, pred=FALSE))
      }
  }

  non_na <- base::which(stats::complete.cases(serie))
  data <- serie[non_na, , drop=FALSE]

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
