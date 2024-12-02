---
title: An R Markdown document converted from "./anomalies/hanr_emd.ipynb"
output: html_document
---


```r
# Harbinger Package
# version 1.1.707

source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/jupyter.R")

#loading Harbinger
load_library("daltoolbox") 
load_library("harbinger") 

source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/R/hanr_emd.R")
```


```r
#loading the example database
data(examples_anomalies)
```


```r
#Using the simple time series 
dataset <- examples_anomalies$simple
head(dataset)
```

```
##       serie event
## 1 1.0000000 FALSE
## 2 0.9689124 FALSE
## 3 0.8775826 FALSE
## 4 0.7316889 FALSE
## 5 0.5403023 FALSE
## 6 0.3153224 FALSE
```


```r
#ploting the time series
plot_ts(x = 1:length(dataset$serie), y = dataset$serie)
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4-1.png)


```r
# establishing hanr_emd method 
  model <- hanr_emd()
```


```r
# fitting the model
  model <- fit(model, dataset$serie)
```


```r
# making detections
  detection <- detect(model, dataset$serie)
```

```
## Error in obj$har_distance(sum_high_freq): attempt to apply non-function
```


```r
# filtering detected events
  print(detection |> dplyr::filter(event==TRUE))
```

```
## Error in eval(expr, envir, enclos): object 'detection' not found
```


```r
# evaluating the detections
  evaluation <- evaluate(model, detection$event, dataset$event)
```

```
## Error in eval(expr, envir, enclos): object 'detection' not found
```

```r
  print(evaluation$confMatrix)
```

```
## Error in eval(expr, envir, enclos): object 'evaluation' not found
```


```r
# ploting the results
  grf <- har_plot(model, dataset$serie, detection, dataset$event)
```

```
## Error in eval(expr, envir, enclos): object 'detection' not found
```

```r
  plot(grf)
```

```
## Error in eval(expr, envir, enclos): object 'grf' not found
```

