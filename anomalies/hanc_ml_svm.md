---
title: An R Markdown document converted from "./anomalies/hanc_ml_svm.ipynb"
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


```r
#ploting the time series
plot_ts(x = 1:length(dataset$serie), y = dataset$serie)
```

```
## Warning: Removed 1 rows containing missing values (`geom_point()`).
```

```
## Warning: Removed 1 row containing missing values (`geom_line()`).
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4-1.png)


```r
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


```r
model <- hanc_ml(cla_svm("event", slevels, epsilon=0.0,cost=20.000))
```


```r
# fitting the model
model <- fit(model, train_n)
detection <- detect(model, train_n)
print(detection |> dplyr::filter(event==TRUE))
```

```
##   idx event    type
## 1  12  TRUE anomaly
## 2  24  TRUE anomaly
## 3  38  TRUE anomaly
## 4  50  TRUE anomaly
```

```r
# evaluating the training
evaluation <- evaluate(model, detection$event, as.logical(train_n$event))
print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      4     0    
## FALSE     0     76
```


```r
# ploting training results
  grf <- har_plot(model, train_n$serie, detection, as.logical(train_n$event))
  plot(grf)
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8-1.png)


```r
# preparing for testing
  test_n <- transform(norm, test)
```


```r
# evaluating the detections during testing
  detection <- detect(model, test_n)

  print(detection |> dplyr::filter(event==TRUE))
```

```
##   idx event    type
## 1  10  TRUE anomaly
```

```r
  evaluation <- evaluate(model, detection$event, as.logical(test_n$event))
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     0    
## FALSE     1     20
```


```r
# ploting the results during testing
  grf <- har_plot(model, test_n$serie, detection, as.logical(test_n$event))
  plot(grf)
```

```
## Warning: Removed 1 rows containing missing values (`geom_point()`).
```

```
## Warning: Removed 1 row containing missing values (`geom_line()`).
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11-1.png)

