#'@title Harbinger
#'@description Ancestor class for time series event detection
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@import daltoolbox
#'@importFrom stats quantile
#'@export
harbinger <- function() {
  obj <- dal_base()
  class(obj) <- append("harbinger", class(obj))

  har_residuals <- function(value) {
    return(value^2)
  }

  obj$har_outliers <- function(data, alpha = 1.5){
    org = length(data)
    cond <- rep(FALSE, org)
    q = stats::quantile(data, na.rm=TRUE)
    IQR = q[4] - q[2]
    lq1 = as.double(q[2] - alpha*IQR)
    hq3 = as.double(q[4] + alpha*IQR)
    cond = data > hq3
    return (cond)
  }

  obj$har_outliers_idx <- function(data, alpha = 1.5){
    cond <- obj$har_outliers(data, alpha)
    index.cp = which(cond)
    return (index.cp)
  }

  har_outliers_group <- function(outliers, size) {
    group <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
    outliers <- rep(FALSE, size)
    for (g in group) {
      if (length(g) > 0) {
        i <- min(g)
        outliers[i] <- TRUE
      }
    }
    return(outliers)
  }

  obj$har_residuals <- har_residuals
  obj$har_outliers <- har_outliers
  obj$har_outliers_idx <- har_outliers_idx
  obj$har_outliers_group <- har_outliers_group

  return(obj)
}

#'@title Detect events in time series
#'@description Detect event using a Harbinger model for event detection
#'@param obj harbinger object
#'@param ... optional arguments./ further arguments passed to or from other methods.
#'@return a harbinger object with model details
#'@examples data(har_examples)
#' dataset <- har_examples[[1]]
#' detector <- harbinger()
#' detector <- detect(detector, dataset$serie)
#'@export
detect <- function(obj, ...) {
  UseMethod("detect")
}

#'@export
detect.harbinger <- function(obj, serie, ...) {
  return(data.frame(idx = 1:length(serie), event = rep(FALSE, length(serie)), type = ""))
}

#'@import daltoolbox
#'@export
evaluate.harbinger <- function(obj, detection, event, evaluation = har_eval(), ...) {
  return(evaluate(evaluation, detection, event))
}


