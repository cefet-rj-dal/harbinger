#'@title Harbinger
#'@description Ancestor class for time series event detection
#'@return Harbinger object
#'@examples
#'# See ?hanc_ml for an example of anomaly detection using machine learning classification
#'# See ?hanr_arima for an example of anomaly detection using ARIMA
#'# See ?hanr_fbiad for an example of anomaly detection using FBIAD
#'# See ?hanr_garch for an example of anomaly detection using GARCH
#'# See ?hanr_kmeans for an example of anomaly detection using kmeans clustering
#'# See ?hanr_ml for an example of anomaly detection using machine learning regression
#'# See ?hanr_cf_arima for an example of change point detection using ARIMA
#'# See ?hanr_cf_ets for an example of change point detection using ETS
#'# See ?hanr_cf_lr for an example of change point detection using linear regression
#'# See ?hanr_cf_garch for an example of change point detection using GARCH
#'# See ?hanr_cf_scp for an example of change point detection using the seminal algorithm
#'# See ?hmo_sax for an example of motif discovery using SAX
#'# See ?hmu_pca for an example of anomaly detection in multivariate time series using PCA
#'@import daltoolbox
#'@importFrom stats quantile
#'@export
harbinger <- function() {
  obj <- dal_base()
  class(obj) <- append("harbinger", class(obj))

  har_residuals <- function(value) {
    return(value^2)
  }

  har_outliers <- function(data){
    org = length(data)
    cond <- rep(FALSE, org)
    q = stats::quantile(data, na.rm=TRUE)
    IQR = q[4] - q[2]
    lq1 = as.double(q[2] - 1.5*IQR)
    hq3 = as.double(q[4] + 1.5*IQR)
    cond = data > hq3
    return (cond)
  }

  har_outliers_idx <- function(data){
    cond <- obj$har_outliers(data, 1.5)
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
#'@description Event detection using a fitted Harbinger model
#'@param obj harbinger object
#'@param ... optional arguments.
#'@return a data frame with the index of observations and if they are identified or not as an event, and their type
#'@examples
#'# See ?hanc_ml for an example of anomaly detection using machine learning classification
#'# See ?hanr_arima for an example of anomaly detection using ARIMA
#'# See ?hanr_fbiad for an example of anomaly detection using FBIAD
#'# See ?hanr_garch for an example of anomaly detection using GARCH
#'# See ?hanr_kmeans for an example of anomaly detection using kmeans clustering
#'# See ?hanr_ml for an example of anomaly detection using machine learning regression
#'# See ?hanr_cf_arima for an example of change point detection using ARIMA
#'# See ?hanr_cf_ets for an example of change point detection using ETS
#'# See ?hanr_cf_lr for an example of change point detection using linear regression
#'# See ?hanr_cf_garch for an example of change point detection using GARCH
#'# See ?hanr_cf_scp for an example of change point detection using the seminal algorithm
#'# See ?hmo_sax for an example of motif discovery using SAX
#'# See ?hmu_pca for an example of anomaly detection in multivariate time series using PCA
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


