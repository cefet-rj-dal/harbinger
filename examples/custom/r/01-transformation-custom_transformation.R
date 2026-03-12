# installation
# install.packages(c("harbinger", "daltoolbox"))

library(daltoolbox)
library(harbinger)

har_fil_median_custom <- function(k = 5) {
  if (k %% 2 == 0) {
    k <- k + 1
  }

  obj <- daltoolbox::dal_transform()
  obj$k <- k
  class(obj) <- append("har_fil_median_custom", class(obj))
  obj
}

transform.har_fil_median_custom <- function(obj, data, ...) {
  result <- stats::runmed(as.numeric(data), k = obj$k, endrule = "keep")
  result[is.na(result)] <- as.numeric(data)[is.na(result)]
  result
}

data(examples_anomalies)
dataset <- examples_anomalies$simple

har_plot(harbinger(), dataset$serie, event = dataset$event)

filter_custom <- har_fil_median_custom(k = 5)
serie_filtered <- transform(filter_custom, dataset$serie)

har_plot(harbinger(), serie_filtered, event = dataset$event)

model <- hanr_arima()
model <- fit(model, as.numeric(serie_filtered))
detection <- detect(model, as.numeric(serie_filtered))

har_plot(model, as.numeric(serie_filtered), detection, dataset$event)
