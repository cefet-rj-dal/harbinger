
``` r
# Installing Harbinger
install.packages("harbinger")
```


``` r
# Loading Harbinger
library(daltoolbox)
library(harbinger) 
```


``` r
# loading the example database
data(examples_anomalies)
```


``` r
# Using the simple time series 
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
# ploting the time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/har_eval_soft/unnamed-chunk-5-1.png)


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


``` r
# filtering detected events
  print(detection |> dplyr::filter(event==TRUE))
```

```
##   idx event    type
## 1  50  TRUE anomaly
```


``` r
# evaluating the detections using hard evaluation
  evaluation <- evaluate(model, detection$event, dataset$event, evaluation=har_eval())
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     0    
## FALSE     0     100
```


``` r
# evaluating the detections using soft evaluation
  result <- evaluate(model, detection$event, dataset$event, evaluation=har_eval_soft(sw_size=5))
  print(result$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     0    
## FALSE     0     100
```


``` r
# evaluation can be done directly without a model 
  result <- evaluate(har_eval_soft(sw_size=5), detection$event, dataset$event)
  print(result$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     0    
## FALSE     0     100
```

