# installation
# install.packages(c("harbinger", "daltoolbox", "forecast"))

library(daltoolbox)
library(harbinger)

hanr_tsoutliers_custom <- function(frequency = 1) {
  obj <- harbinger()
  obj$frequency <- frequency
  class(obj) <- append("hanr_tsoutliers_custom", class(obj))
  obj
}

detect.hanr_tsoutliers_custom <- function(obj, serie, ...) {
  obj <- obj$har_store_refs(obj, serie)

  y_ts <- stats::ts(obj$serie, frequency = obj$frequency)
  out <- forecast::tsoutliers(y_ts)

  anomalies <- rep(FALSE, length(obj$serie))
  if (!is.null(out$index) && length(out$index) > 0) {
    anomalies[unique(out$index)] <- TRUE
  }

  obj$har_restore_refs(obj, anomalies = anomalies)
}

data(examples_anomalies)
dataset <- examples_anomalies$simple

model <- hanr_tsoutliers_custom()
detection <- detect(model, dataset$serie)

evaluation <- evaluate(model, detection$event, dataset$event)
evaluation$confMatrix

har_plot(model, dataset$serie, detection, dataset$event)
