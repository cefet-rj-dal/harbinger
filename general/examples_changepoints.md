---
title: An R Markdown document converted from "./general/examples_changepoints.ipynb"
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
data(examples_changepoints)
model <- harbinger()
```


```r
#Using the simple time series 
dataset <- examples_changepoints$simple
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png)


```r
#Using the sinusoidal time series
dataset <- examples_changepoints$sinusoidal
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4-1.png)


```r
#Using the incremental time series
dataset <- examples_changepoints$incremental
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-1.png)


```r
#Using the abrupt time series 
dataset <- examples_changepoints$abrupt
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

```
## Don't know how to automatically pick scale for object of type <ts>. Defaulting to continuous.
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png)


```r
#Using the volatility time series
dataset <- examples_changepoints$volatility
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

```
## Don't know how to automatically pick scale for object of type <ts>. Defaulting to continuous.
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png)


```r
#Using the increasing_amplitude time series
dataset <- examples_changepoints$increasing_amplitude
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8-1.png)


```r
#Using the complex time series
dataset <- examples_changepoints$complex
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-1.png)

