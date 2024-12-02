---
title: An R Markdown document converted from "./general/examples_harbinger.ipynb"
output: html_document
---


```r
# Harbinger Package
# version 1.1.707

source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/jupyter.R")

#loading Harbinger
load_library("daltoolbox") 
load_library("harbinger") 
```


```r
#loading the example database
data(examples_harbinger)
model <- harbinger()
```


```r
#Using the nonstationarity time series 
dataset <- examples_harbinger$nonstationarity
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png)


```r
#Using the global temperature (yearly) time series
dataset <- examples_harbinger$global_temperature_yearly
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4-1.png)


```r
#Using the global temperature (monthly) time series
dataset <- examples_harbinger$global_temperature_monthly
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-1.png)


```r
#Using the multidimensional time series 
dataset <- examples_harbinger$multidimensional
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png)

```r
model <- fit(model, dataset$x)
detection <- detect(model, dataset$x)
grf <- har_plot(model, dataset$x, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-2.png)


```r
#Using the Seattle weekly temperature time series
dataset <- examples_harbinger$seattle_week
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png)


```r
#Using the Seattle daily temperature time series
dataset <- examples_harbinger$seattle_daily
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8-1.png)

