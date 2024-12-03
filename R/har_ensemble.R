#'@title Harbinger Ensemble
#'@description Ensemble detector
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
har_ensemble <- function() {
  obj <- harbinger()
  class(obj) <- append("har_ensemble", class(obj))

  return(obj)
}


