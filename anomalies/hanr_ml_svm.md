
```r
# Harbinger Package
# version 1.1.707



#loading Harbinger
library(daltoolbox)
library(harbinger) 
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

![plot of chunk unnamed-chunk-4](fig/hanr_ml_svm/unnamed-chunk-4-1.png)


```r
# establishing SVM
  model <- hanr_ml(ts_svm(ts_norm_gminmax(), input_size=4,  kernel = "radial"))
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
## Warning in obj$res[obj$non_na] <- res: number of items to replace is not a multiple of replacement length
```


```r
# filtering detected events
  print(detection |> dplyr::filter(event==TRUE))
```

```
##    idx event    type
## 1   16  TRUE anomaly
## 2   27  TRUE anomaly
## 3   29  TRUE anomaly
## 4   32  TRUE anomaly
## 5   41  TRUE anomaly
## 6   50  TRUE anomaly
## 7   54  TRUE anomaly
## 8   57  TRUE anomaly
## 9   66  TRUE anomaly
## 10  77  TRUE anomaly
## 11  80  TRUE anomaly
## 12  91  TRUE anomaly
```


```r
# evaluating the detections
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     11   
## FALSE     0     89
```


```r
# ploting the results
  grf <- har_plot(model, dataset$serie, detection, dataset$event)
  plot(grf)
```

![plot of chunk unnamed-chunk-10](fig/hanr_ml_svm/unnamed-chunk-10-1.png)


```r
# ploting the results
  res <-  attr(detection, "res")
  plot(res)
```

![plot of chunk unnamed-chunk-11](fig/hanr_ml_svm/unnamed-chunk-11-1.png)


```r
# ploting the results
  res <-  attr(detection, "res")
  plot(res)
```

![plot of chunk unnamed-chunk-12](fig/hanr_ml_svm/unnamed-chunk-12-1.png)