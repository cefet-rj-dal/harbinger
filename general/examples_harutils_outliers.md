
``` r
# Harbinger Package
# version 1.1.707


#loading Harbinger
library(daltoolbox)
library(harbinger) 
```


``` r
#class harutils
  hutils <- harutils()
```


``` r
#loading the example database
data(examples_anomalies)
#Using the simple time series 
dataset <- examples_anomalies$simple
plot_ts(x = 1:length(dataset$serie), y = dataset$serie)
```

![plot of chunk unnamed-chunk-3](fig/examples_harutils_outliers/unnamed-chunk-3-1.png)


``` r
# establishing arima method 
  model <- hanr_arima()
  #using default hutils$har_outliers_boxplot
  #using default hutils$har_distance_l2
  # fitting the model
  model <- fit(model, dataset$serie)
# making detections
  detection <- detect(model, dataset$serie)
  res <- attr(detection, "res")
  plot(res)
  abline(v = which(detection$event==TRUE), col = "darkred") 
```

![plot of chunk unnamed-chunk-4](fig/examples_harutils_outliers/unnamed-chunk-4-1.png)


``` r
  model <- hanr_arima()
  model$har_outliers <- hutils$har_outliers_gaussian
# fitting the model
  model <- fit(model, dataset$serie)
# making detections
  detection <- detect(model, dataset$serie)
  res <- attr(detection, "res")
  plot(res)
  abline(v = which(detection$event==TRUE), col = "darkred") 
```

![plot of chunk unnamed-chunk-5](fig/examples_harutils_outliers/unnamed-chunk-5-1.png)


``` r
  model <- hanr_arima()
  model$har_outliers <- hutils$har_outliers_ratio
# fitting the model
  model <- fit(model, dataset$serie)
# making detections
  detection <- detect(model, dataset$serie)
  res <- attr(detection, "res")
  plot(res)
  abline(v = which(detection$event==TRUE), col = "darkred")   
```

![plot of chunk unnamed-chunk-6](fig/examples_harutils_outliers/unnamed-chunk-6-1.png)


``` r
  model <- hanr_arima()
  model$har_distance <- hutils$har_distance_l1
# fitting the model
  model <- fit(model, dataset$serie)
# making detections
  detection <- detect(model, dataset$serie)
  res <- attr(detection, "res")
  plot(res)
  abline(v = which(detection$event==TRUE), col = "darkred") 
```

![plot of chunk unnamed-chunk-7](fig/examples_harutils_outliers/unnamed-chunk-7-1.png)


``` r
  model <- hanr_arima()
  model$har_distance <- hutils$har_distance_l1
  model$har_outliers <- hutils$har_outliers_gaussian
# fitting the model
  model <- fit(model, dataset$serie)
# making detections
  detection <- detect(model, dataset$serie)
  res <- attr(detection, "res")
  plot(res)
  abline(v = which(detection$event==TRUE), col = "darkred") 
```

![plot of chunk unnamed-chunk-8](fig/examples_harutils_outliers/unnamed-chunk-8-1.png)


``` r
  model <- hanr_arima()
  model$har_distance <- hutils$har_distance_l1
  model$har_outliers <- hutils$har_outliers_ratio
# fitting the model
  model <- fit(model, dataset$serie)
# making detections
  detection <- detect(model, dataset$serie)
  res <- attr(detection, "res")
  plot(res)
  abline(v = which(detection$event==TRUE), col = "darkred") 
```

![plot of chunk unnamed-chunk-9](fig/examples_harutils_outliers/unnamed-chunk-9-1.png)

``` r
  model <- hanr_arima()
  model$har_distance <- hutils$har_distance_l1
  model$har_outliers <- hutils$har_outliers_gaussian
  model$har_outliers_checks <- hutils$har_outliers_checks_firstgroup  
# fitting the model
  model <- fit(model, dataset$serie)
# making detections
  detection <- detect(model, dataset$serie)
  res <- attr(detection, "res")
  plot(res)
  abline(v = which(detection$event==TRUE), col = "darkred") 
```

![plot of chunk unnamed-chunk-10](fig/examples_harutils_outliers/unnamed-chunk-10-1.png)
