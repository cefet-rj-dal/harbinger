---
title: An R Markdown document converted from "./general/examples_anomalies.ipynb"
output: html_document
---


```r
# Harbinger Package
# version 1.0.787

source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/jupyter.R")

#loading Harbinger
load_library("daltoolbox") 
load_library("harbinger") 
```


```r
#loading the example database
data(examples_anomalies)
model <- harbinger()
```


```r
#Using the simple time series 
dataset <- examples_anomalies$simple
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png)


```r
#Using the contextual time series
dataset <- examples_anomalies$contextual
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4-1.png)


```r
#Using the trend time series
dataset <- examples_anomalies$trend
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-1.png)


```r
#Using the multiple-event time series 
dataset <- examples_anomalies$multiple
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png)


```r
#Using the sequence time series 
dataset <- examples_anomalies$sequence
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png)


```r
#Using the train-test (tt) time series
dataset <- examples_anomalies$tt
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

```
## Warning: Removed 1 rows containing missing values (`geom_point()`).
```

```
## Warning: Removed 1 row containing missing values (`geom_line()`).
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8-1.png)


```r
#Using the train-test warped (tt_warped) time series
dataset <- examples_anomalies$tt_warped
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-1.png)


```r
#Using the increasing_amplitude time series
dataset <- examples_anomalies$increasing_amplitude
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10-1.png)


```r
#Using the decreasing_amplitude time series
dataset <- examples_anomalies$decreasing_amplitude
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11-1.png)


```r
#Using the volatile time series
dataset <- examples_anomalies$volatile
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-12-1.png)

