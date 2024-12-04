---
title: /drift/hcd_eddm.Rmd
output: html_document
---


```r
# Harbinger Package
# version 1.1.707



#loading Harbinger
library(daltoolbox)
library(harbinger) 
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

![plot of chunk unnamed-chunk-3](fig/hcd_eddm/unnamed-chunk-3-1.png)


```r
#ploting serie #2
plot_ts(x = 1:length(dataset$serie2), y = dataset$serie2)
```

![plot of chunk unnamed-chunk-4](fig/hcd_eddm/unnamed-chunk-4-1.png)


```r
# establishing drift method 
model <- hcd_eddm()
```

```
## Error in hcd_eddm(): could not find function "hcd_eddm"
```


```r
# fitting the model
model <- fit(model, dataset)
```

```
## Error in eval(expr, envir, enclos): object 'model' not found
```


```r
# making detections
detection <- detect(model, dataset)
```

```
## Error in eval(expr, envir, enclos): object 'model' not found
```


```r
# filtering detected events
print(detection[(detection$event),])
```

```
## Error in eval(expr, envir, enclos): object 'detection' not found
```


```r
# evaluating the detections
  evaluation <- evaluate(model, detection$event, dataset$event)
```

```
## Error in eval(expr, envir, enclos): object 'model' not found
```

```r
  print(evaluation$confMatrix)
```

```
## Error in eval(expr, envir, enclos): object 'evaluation' not found
```


```r
# ploting the results
  grf <- har_plot(model, dataset$serie1, detection, dataset$event)
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
