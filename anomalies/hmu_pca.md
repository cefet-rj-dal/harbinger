---
title: An R Markdown document converted from "./anomalies/hmu_pca.ipynb"
output: html_document
---


```r
# Harbinger Package
# version 1.1.707

source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/jupyter.R")

#loading Harbinger
load_library("daltoolbox") 
load_library("harbinger") 
load_library("ggplot2")
```

```
## Loading required package: ggplot2
```


```r
data("examples_harbinger")
dataset <- examples_harbinger$multidimensional
dataset$event <- FALSE
dataset$event[c(101,128,167)] <- TRUE
```


```r
head(dataset)
```

```
##        serie           x event
## 1 -0.6264538  0.40940184 FALSE
## 2 -0.8356286  1.58658843 FALSE
## 3  1.5952808 -0.33090780 FALSE
## 4  0.3295078 -2.28523554 FALSE
## 5 -0.8204684  2.49766159 FALSE
## 6  0.5757814 -0.01339952 FALSE
```


```r
#ploting the time series
plot_ts(x = 1:length(dataset$serie), y = dataset$serie)
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4-1.png)


```r
#ploting the time x
plot_ts(x = 1:length(dataset$x), y = dataset$x)
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-1.png)


```r
model <- fit(hmu_pca(), dataset[,1:2])
pca_detection <- detect(model, dataset[,1:2])
```


```r
grf <- har_plot(model, dataset$serie, pca_detection, dataset$event)
grf <- grf + ylab("serie")
plot(grf)
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png)


```r
grf <- har_plot(model, dataset$x, pca_detection, dataset$event)
grf <- grf + ylab("x")
plot(grf)
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8-1.png)

