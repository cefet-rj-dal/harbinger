---
title: An R Markdown document converted from "./change_point/hcp_chow.ipynb"
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
data(examples_changepoints)
```


```r
#Using the simple time series 
dataset <- examples_changepoints$simple
head(dataset)
```

```
##   serie event
## 1  0.00 FALSE
## 2  0.25 FALSE
## 3  0.50 FALSE
## 4  0.75 FALSE
## 5  1.00 FALSE
## 6  1.25 FALSE
```


```r
#ploting the time series
plot_ts(x = 1:length(dataset$serie), y = dataset$serie)
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4-1.png)


```r
# establishing change point method 
  model <- hcp_chow()
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
##   idx event        type
## 1  50  TRUE changepoint
```


```r
# evaluating the detections
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     0    
## FALSE     0     100
```


```r
# ploting the results
  grf <- har_plot(model, dataset$serie, detection, dataset$event)
  plot(grf)
```

![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10-1.png)

