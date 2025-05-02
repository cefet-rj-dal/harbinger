
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
#Using the sequence time series
dataset <- examples_anomalies$sequence
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

![plot of chunk unnamed-chunk-4](fig/hanct_dtw_discord/unnamed-chunk-4-1.png)


``` r
# establishing the method 
  model <- hanct_dtw(3)
```


``` r
# fitting the model
  model <- fit(model, dataset$serie)
```


``` r
# making detections of discords using kmeans
  detection <- detect(model, dataset$serie)
```

```
## Warning in obj$anomalies[obj$non_na] <- anomalies: number of items to replace is not a multiple of replacement length
```

```
## Warning in obj$res[obj$non_na] <- res: number of items to replace is not a multiple of replacement length
```


``` r
# filtering detected events
  print(detection |> dplyr::filter(event==TRUE))
```

```
##   idx event    type seq seqlen
## 1  50  TRUE discord   3      3
```


``` r
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


``` r
# ploting the results
  grf <- har_plot(model, dataset$serie, detection, dataset$event)
  plot(grf)
```

![plot of chunk unnamed-chunk-10](fig/hanct_dtw_discord/unnamed-chunk-10-1.png)


``` r
# ploting the results
  res <-  attr(detection, "res")
  plot(res)
```

![plot of chunk unnamed-chunk-11](fig/hanct_dtw_discord/unnamed-chunk-11-1.png)
