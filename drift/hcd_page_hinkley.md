---
title: An R Markdown document converted from "./drift/hcd_page_hinkley.ipynb"
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
#Creating dataset
n <- 100  # size of each segment
serie1 <- c(sin((1:n)/pi), 2*sin((1:n)/pi), 10 + sin((1:n)/pi),
           10-10/n*(1:n)+sin((1:n)/pi)/2, sin((1:n)/pi)/2)
serie2 <- 2*c(sin((1:n)/pi), 2*sin((1:n)/pi), 10 + sin((1:n)/pi),
           10-10/n*(1:n)+sin((1:n)/pi)/2, sin((1:n)/pi)/2)
event <- rep(FALSE, length(serie1))
event[c(100, 200, 300, 400)] <- TRUE
dataset <- data.frame(serie1, serie2, event)
```


```r
#ploting the time series
plot_ts(x = 1:length(dataset$serie1), y = dataset$serie1)
```

![plot of chunk unnamed-chunk-3](hcd_page_hinkley/unnamed-chunk-3-1.png)


```r
#ploting serie #2
plot_ts(x = 1:length(dataset$serie2), y = dataset$serie2)
```

![plot of chunk unnamed-chunk-4](hcd_page_hinkley/unnamed-chunk-4-1.png)


```r
# establishing drift method 
model <- hcd_page_hinkley(threshold=3)
```

```
## Error in hcd_page_hinkley(threshold = 3): could not find function "hcd_page_hinkley"
```


```r
# fitting the model
model <- fit(model, dataset)
```


```r
# making detections
detection <- detect(model, dataset)
```

```
## Warning in obj$anomalies[obj$non_na] <- anomalies: number of items to replace is not a multiple of replacement length
```


```r
# filtering detected events
print(detection[(detection$event),])
```

```
##     idx event    type
## 201 201  TRUE anomaly
## 210 210  TRUE anomaly
## 230 230  TRUE anomaly
## 250 250  TRUE anomaly
## 270 270  TRUE anomaly
## 289 289  TRUE anomaly
## 302 302  TRUE anomaly
## 309 309  TRUE anomaly
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
## FALSE     4     488
```


```r
# ploting the results
  grf <- har_plot(model, dataset$serie1, detection, dataset$event)
  plot(grf)
```

![plot of chunk unnamed-chunk-10](hcd_page_hinkley/unnamed-chunk-10-1.png)

