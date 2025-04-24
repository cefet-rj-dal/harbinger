
``` r
# Harbinger Package
# version 1.1.707



#loading Harbinger
library(daltoolbox)
library(harbinger) 
```


``` r
#loading the example database
data(examples_anomalies)
```


``` r
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


``` r
#ploting the time series
plot_ts(x = 1:length(dataset$serie), y = dataset$serie)
```

![plot of chunk unnamed-chunk-4](fig/har_eval_soft/unnamed-chunk-4-1.png)


``` r
# establishing mlp method 
  model <- hanr_ml(ts_mlp(ts_norm_gminmax(), input_size=5, size=3, decay=0))
```


``` r
# fitting the model
  model <- fit(model, dataset$serie)
```


``` r
# making detections 
  detection <- detect(model, dataset$serie)
```

```
## Warning in obj$res[obj$non_na] <- res: number of items to replace is not a multiple of replacement length
```


``` r
# filtering detected events
  print(detection |> dplyr::filter(event==TRUE))
```

```
##   idx event    type
## 1  24  TRUE anomaly
## 2  49  TRUE anomaly
## 3  55  TRUE anomaly
## 4  74  TRUE anomaly
## 5  99  TRUE anomaly
```


``` r
# evaluating the detections using hard evaluation
  evaluation <- evaluate(model, detection$event, dataset$event, evaluation=har_eval())
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0     5    
## FALSE     1     95
```


``` r
# evaluating the detections using soft evaluation
  result <- evaluate(model, detection$event, dataset$event, evaluation=har_eval_soft(sw_size=5))
  print(result$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0.8   4.2  
## FALSE     0.2   95.8
```


``` r
# evaluation can be done directly without a model 
  result <- evaluate(har_eval_soft(sw_size=5), detection$event, dataset$event)
  print(result$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0.8   4.2  
## FALSE     0.2   95.8
```

