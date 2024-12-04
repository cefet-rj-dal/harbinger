---
title: /general/examples_harutils.Rmd
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
#class harutils
  hutils <- harutils()
```


```r
values <- rnorm(30, mean = 0, sd = 1)
```


```r
v1 <- hutils$har_distance_l1(values)
plot(v1)
```

![plot of chunk unnamed-chunk-4](fig/examples_harutils_distance/unnamed-chunk-4-1.png)

```r
v2 <- hutils$har_distance_l2(values)
plot(v2)
```

![plot of chunk unnamed-chunk-5](fig/examples_harutils_distance/unnamed-chunk-5-1.png)