# Harbinger Package
# version 1.1.707



#loading Harbinger
library(daltoolbox)
library(harbinger)

#loading the example database
data(examples_anomalies)
#

#{r}
#Using the simple time series
dataset <- examples_anomalies$simple
head(dataset)
#

#{r}
#ploting the time series
har_plot(harbinger(), dataset$serie)
#

#{r}
model <- hanr_ml(ts_elm(ts_norm_gminmax(), input_size=4, nhid=3, actfun="purelin"))
#

#{r}
# fitting the model
model <- fit(model, dataset$serie)
#

#{r}
# making detections
detection <- detect(model, dataset$serie)
#

#{r}
# filtering detected events
print(detection |> dplyr::filter(event==TRUE))
#

#{r}
# evaluating the detections
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)
#

#{r}
# plotting the results
har_plot(model, dataset$serie, detection, dataset$event)

#

#{r}
# plotting the residuals
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

#
