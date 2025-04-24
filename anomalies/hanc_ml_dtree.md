
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
#Using the tt time series
dataset <- examples_anomalies$tt
dataset$event <- factor(dataset$event, labels=c("FALSE", "TRUE"))
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

```
## Warning: Removed 1 row containing missing values or values outside the scale range (`geom_point()`).
```

```
## Warning: Removed 1 row containing missing values or values outside the scale range (`geom_line()`).
```

![plot of chunk unnamed-chunk-4](fig/hanc_ml_dtree/unnamed-chunk-4-1.png)


``` r
# data preprocessing
slevels <- levels(dataset$event)

train <- dataset[1:80,]
test <- dataset[-(1:80),]

norm <- minmax()
norm <- fit(norm, train)
train_n <- transform(norm, train)
summary(train_n)
```

```
##      serie          event   
##  Min.   :0.0000   FALSE:76  
##  1st Qu.:0.2859   TRUE : 4  
##  Median :0.5348             
##  Mean   :0.5221             
##  3rd Qu.:0.7587             
##  Max.   :1.0000
```


``` r
# establishing decision tree method 
model <- hanc_ml(cla_dtree("event", slevels))
```


``` r
# fitting the model
model <- fit(model, train_n)
detection <- detect(model, train_n)
print(detection |> dplyr::filter(event==TRUE))
```

```
## [1] idx   event type 
## <0 rows> (or 0-length row.names)
```

``` r
# evaluating the training
evaluation <- evaluate(model, detection$event, as.logical(train_n$event))
print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0     0    
## FALSE     4     76
```


``` r
# ploting training results
  grf <- har_plot(model, train_n$serie, detection, as.logical(train_n$event))
  plot(grf)
```

![plot of chunk unnamed-chunk-8](fig/hanc_ml_dtree/unnamed-chunk-8-1.png)


``` r
# preparing for testing
  test_n <- transform(norm, test)
```


``` r
# evaluating the detections during testing
  detection <- detect(model, test_n)

  print(detection |> dplyr::filter(event==TRUE))
```

```
## [1] idx   event type 
## <0 rows> (or 0-length row.names)
```

``` r
  evaluation <- evaluate(model, detection$event, as.logical(test_n$event))
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0     0    
## FALSE     2     20
```


``` r
# ploting the results during testing
  grf <- har_plot(model, test_n$serie, detection, as.logical(test_n$event))
  plot(grf)
```

```
## Warning: Removed 1 row containing missing values or values outside the scale range (`geom_point()`).
```

```
## Warning: Removed 1 row containing missing values or values outside the scale range (`geom_line()`).
```

![plot of chunk unnamed-chunk-11](fig/hanc_ml_dtree/unnamed-chunk-11-1.png)


``` r
# ploting the results
  res <-  attr(detection, "res")
  plot(res)
```

![plot of chunk unnamed-chunk-12](fig/hanc_ml_dtree/unnamed-chunk-12-1.png)
