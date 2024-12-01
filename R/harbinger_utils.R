#'@title Harbinger Utils
#'@description Utility class that contains major distance measures,
#'threshold limits, and outliers grouping functions
#'@return Harbinger Utils
#'@examples
#'# See ?hanc_ml for an example of anomaly detection using machine learning classification
#'@import daltoolbox
#'@importFrom stats quantile
#'@export
harutils <- function() {
  har_residuals_l1 <- function(values) {
    return(values)
  }

  har_residuals_l2 <- function(values) {
    return(values^2)
  }

  har_outliers_boxplot <- function(data){
    org = length(data)
    cond <- rep(FALSE, org)
    q = stats::quantile(data, na.rm=TRUE)
    IQR = q[4] - q[2]
    lq1 = as.double(q[2] - 1.5*IQR)
    hq3 = as.double(q[4] + 1.5*IQR)
    cond = data > hq3
    index = which(cond)
    return (index)
  }

  har_outliers_checks_mingroup <- function(outliers, size, values = NULL) {
    group <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
    outliers <- rep(FALSE, size)
    for (g in group) {
      if (length(g) > 0) {
        if (is.null(values)) {
          i <- min(g)
          outliers[i] <- TRUE
        }
        else {
          i <- which.max(values[g])
          i <- g[i]
          outliers[i] <- TRUE
        }
      }
    }
    return(outliers)
  }


  obj <- dal_base()
  class(obj) <- append("harutils", class(obj))
  obj$har_residuals_l1 <- har_residuals_l1
  obj$har_residuals_l2 <- har_residuals_l2
  obj$har_outliers_boxplot <- har_outliers_boxplot
  obj$har_outliers_checks_mingroup <- har_outliers_checks_mingroup
  return(obj)
}



