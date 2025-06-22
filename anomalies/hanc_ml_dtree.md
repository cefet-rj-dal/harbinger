
``` r
# Installing Harbinger
#install.packages"harbinger")
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
# Using the tt time series
dataset <- examples_anomalies$tt

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

![plot of chunk unnamed-chunk-5](fig/hanc_ml_dtree/unnamed-chunk-5-1.png)


``` r
# data preprocessing


train <- dataset[1:80,]
test <- dataset[-(1:80),]

norm <- minmax()
norm <- fit(norm, train)
train_n <- transform(norm, train)
summary(train_n)
```

```
##      serie          event        
##  Min.   :0.0000   Mode :logical  
##  1st Qu.:0.2859   FALSE:76       
##  Median :0.5348   TRUE :4        
##  Mean   :0.5221                  
##  3rd Qu.:0.7587                  
##  Max.   :1.0000
```


``` r
# establishing decision tree method 
model <- hanc_ml(cla_dtree("event", c("FALSE", "TRUE")))
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
# plotting training results
  har_plot(model, train_n$serie, detection, as.logical(train_n$event))
```

![plot of chunk unnamed-chunk-9](fig/hanc_ml_dtree/unnamed-chunk-9-1.png)


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
## FALSE     2     19
```


``` r
# plotting the results during testing
  har_plot(model, test_n$serie, detection, as.logical(test_n$event))
```

![plot of chunk unnamed-chunk-12](fig/hanc_ml_dtree/unnamed-chunk-12-1.png)


``` r
# plotting the residuals
har_plot(model, attr(detection, "res"), detection, test_n$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-13](fig/hanc_ml_dtree/unnamed-chunk-13-1.png)
