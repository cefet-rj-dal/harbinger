---
title: An R Markdown document converted from "./anomalies/hanr_remd.ipynb"
output: html_document
---


```r
# Harbinger Package
# version 1.1.707

source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/jupyter.R")

#loading Harbinger
load_library("daltoolbox") 
load_library("harbinger") 

source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/R/hanr_remd.R")
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

![plot of chunk unnamed-chunk-4](hanr_remd/unnamed-chunk-4-1.png)


```r
# establishing hanr_remd method 
  model <- hanr_remd()
```

```
## Error in harutils(): could not find function "harutils"
```


```r
# fitting the model
  model <- fit(model, dataset$serie)
```


```r
# making detections
  detection <- detect(model, dataset$serie)
```


```r
# filtering detected events
  print(detection |> dplyr::filter(event==TRUE))
```

```
##   idx event    type
## 1   2  TRUE anomaly
## 2   5  TRUE anomaly
## 3  27  TRUE anomaly
## 4  30  TRUE anomaly
## 5  51  TRUE anomaly
## 6  55  TRUE anomaly
## 7  77  TRUE anomaly
## 8  81  TRUE anomaly
```


```r
# evaluating the detections
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0     8    
## FALSE     1     92
```


```r
# ploting the results
  grf <- har_plot(model, dataset$serie, detection, dataset$event)
  plot(grf)
```

![plot of chunk unnamed-chunk-10](hanr_remd/unnamed-chunk-10-1.png)

