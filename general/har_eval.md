---
title: An R Markdown document converted from "./general/har_eval.ipynb"
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

![plot of chunk unnamed-chunk-4](fig/har_eval/unnamed-chunk-4-1.png)


```r
# establishing mlp method 
  model <- hanr_ml(ts_mlp(ts_norm_gminmax(), input_size=5, size=3, decay=0))
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
## 1  24  TRUE anomaly
## 2  49  TRUE anomaly
## 3  74  TRUE anomaly
## 4  99  TRUE anomaly
```


```r
# evaluating the detections using hard evaluation
  evaluation <- evaluate(har_eval(), detection$event, dataset$event)
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0     4    
## FALSE     1     96
```

