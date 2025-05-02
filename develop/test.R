library(daltoolbox)
#library(harbinger)

#loading the example database
data(examples_anomalies)

#Using the simple time series
dataset <- examples_anomalies$simple
head(dataset)

##       serie event
## 1 1.0000000 FALSE
## 2 0.9689124 FALSE
## 3 0.8775826 FALSE
## 4 0.7316889 FALSE
## 5 0.5403023 FALSE
## 6 0.3153224 FALSE

#ploting the time series
plot_ts(x = 1:length(dataset$serie), y = dataset$serie)

# establishing hanr_fft method
model <- hanr_fft()

# fitting the model
model <- fit(model, dataset$serie)

# making detections
detection <- detect(model, dataset$serie)

# filtering detected events
print(detection |> dplyr::filter(event==TRUE))

##   idx event    type
## 1   1  TRUE anomaly
## 2  44  TRUE anomaly
## 3 101  TRUE anomaly

# evaluating the detections
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)

##           event
## detection TRUE  FALSE
## TRUE      0     3
## FALSE     1     97

# ploting the results
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)

# ploting the results
res <-  attr(detection, "res")
threshold <-


grf <- har_plot(model, res, detection, dataset$event, yline = attr(detection, "threshold"))
plot(grf)


grf <- har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
plot(grf)

