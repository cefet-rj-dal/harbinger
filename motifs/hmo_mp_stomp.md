# Overview

This Rmd demonstrates motif discovery using Matrix Profile with the STOMP algorithm via `hmo_mp("stomp", ...)`. It identifies repeated subsequences (motifs) efficiently in long series. Steps: load packages/data, visualize, configure subsequence length and number of motifs, fit, detect, evaluate, and plot.


``` r
# Install Harbinger (only once, if needed)
#install.packages("harbinger")
```


``` r
# Load required packages
library(daltoolbox)
library(harbinger) 
```


``` r
# Load example datasets bundled with harbinger
data(examples_motifs)
```


``` r
# Select a simple example time series
dataset <- examples_motifs$simple
head(dataset)
```

```
##       serie event
## 1 1.0000000 FALSE
## 2 0.9939124 FALSE
## 3 0.9275826 FALSE
## 4 0.8066889 FALSE
## 5 0.6403023 FALSE
## 6 0.4403224 FALSE
```


``` r
# Plot the time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/hmo_mp_stomp/unnamed-chunk-5-1.png)


``` r
# Define Matrix Profile (STOMP) motif model
# - second arg: subsequence length (window)
# - third arg: number of motifs to retrieve
  model <- hmo_mp("stomp", 4, 3)
```


``` r
# Fit the model
  model <- fit(model, dataset$serie)
```


``` r
# Detect motifs
  detection <- detect(model, dataset$serie)
```

```
## 
STOMP [==>----------------------------]   8% at 5.1 it/s, elapsed:  2s, eta: 18s
STOMP [==>----------------------------]   9% at 5.7 it/s, elapsed:  2s, eta: 16s
STOMP [==>----------------------------]  10% at 6.3 it/s, elapsed:  2s, eta: 14s
STOMP [===>-----------------------------]  11% at 7 it/s, elapsed:  2s, eta: 13s
STOMP [===>---------------------------]  12% at 7.6 it/s, elapsed:  2s, eta: 11s
STOMP [===>---------------------------]  13% at 8.2 it/s, elapsed:  2s, eta: 10s
STOMP [===>---------------------------]  14% at 8.8 it/s, elapsed:  2s, eta: 10s
STOMP [====>--------------------------]  15% at 9.5 it/s, elapsed:  2s, eta:  9s
STOMP [====>---------------------------]  16% at 10 it/s, elapsed:  2s, eta:  8s
STOMP [=====>--------------------------]  17% at 11 it/s, elapsed:  2s, eta:  8s
STOMP [=====>--------------------------]  18% at 11 it/s, elapsed:  2s, eta:  7s
STOMP [=====>--------------------------]  19% at 12 it/s, elapsed:  2s, eta:  7s
STOMP [======>-------------------------]  20% at 13 it/s, elapsed:  2s, eta:  6s
STOMP [======>-------------------------]  21% at 13 it/s, elapsed:  2s, eta:  6s
STOMP [======>-------------------------]  22% at 14 it/s, elapsed:  2s, eta:  6s
STOMP [=======>------------------------]  23% at 14 it/s, elapsed:  2s, eta:  5s
STOMP [=======>------------------------]  24% at 15 it/s, elapsed:  2s, eta:  5s
STOMP [=======>------------------------]  26% at 16 it/s, elapsed:  2s, eta:  5s
STOMP [=======>------------------------]  27% at 16 it/s, elapsed:  2s, eta:  4s
STOMP [========>-----------------------]  28% at 17 it/s, elapsed:  2s, eta:  4s
STOMP [========>-----------------------]  29% at 17 it/s, elapsed:  2s, eta:  4s
STOMP [========>-----------------------]  30% at 18 it/s, elapsed:  2s, eta:  4s
STOMP [=========>----------------------]  31% at 19 it/s, elapsed:  2s, eta:  4s
STOMP [=========>----------------------]  32% at 19 it/s, elapsed:  2s, eta:  3s
STOMP [=========>----------------------]  33% at 20 it/s, elapsed:  2s, eta:  3s
STOMP [==========>---------------------]  34% at 20 it/s, elapsed:  2s, eta:  3s
STOMP [==========>---------------------]  35% at 21 it/s, elapsed:  2s, eta:  3s
STOMP [==========>---------------------]  36% at 22 it/s, elapsed:  2s, eta:  3s
STOMP [===========>--------------------]  37% at 22 it/s, elapsed:  2s, eta:  3s
STOMP [===========>--------------------]  38% at 23 it/s, elapsed:  2s, eta:  3s
STOMP [===========>--------------------]  39% at 23 it/s, elapsed:  2s, eta:  3s
STOMP [============>-------------------]  40% at 24 it/s, elapsed:  2s, eta:  2s
STOMP [============>-------------------]  41% at 25 it/s, elapsed:  2s, eta:  2s
STOMP [============>-------------------]  42% at 25 it/s, elapsed:  2s, eta:  2s
STOMP [=============>------------------]  43% at 26 it/s, elapsed:  2s, eta:  2s
STOMP [=============>------------------]  44% at 26 it/s, elapsed:  2s, eta:  2s
STOMP [=============>------------------]  45% at 27 it/s, elapsed:  2s, eta:  2s
STOMP [==============>-----------------]  46% at 28 it/s, elapsed:  2s, eta:  2s
STOMP [==============>-----------------]  47% at 28 it/s, elapsed:  2s, eta:  2s
STOMP [==============>-----------------]  48% at 29 it/s, elapsed:  2s, eta:  2s
STOMP [===============>----------------]  49% at 29 it/s, elapsed:  2s, eta:  2s
STOMP [===============>----------------]  50% at 30 it/s, elapsed:  2s, eta:  2s
STOMP [===============>----------------]  51% at 30 it/s, elapsed:  2s, eta:  2s
STOMP [================>---------------]  52% at 31 it/s, elapsed:  2s, eta:  2s
STOMP [================>---------------]  53% at 32 it/s, elapsed:  2s, eta:  1s
STOMP [================>---------------]  54% at 32 it/s, elapsed:  2s, eta:  1s
STOMP [=================>--------------]  55% at 33 it/s, elapsed:  2s, eta:  1s
STOMP [=================>--------------]  56% at 33 it/s, elapsed:  2s, eta:  1s
STOMP [=================>--------------]  57% at 34 it/s, elapsed:  2s, eta:  1s
STOMP [==================>-------------]  58% at 35 it/s, elapsed:  2s, eta:  1s
STOMP [==================>-------------]  59% at 35 it/s, elapsed:  2s, eta:  1s
STOMP [==================>-------------]  60% at 36 it/s, elapsed:  2s, eta:  1s
STOMP [===================>------------]  61% at 36 it/s, elapsed:  2s, eta:  1s
STOMP [===================>------------]  62% at 37 it/s, elapsed:  2s, eta:  1s
STOMP [===================>------------]  63% at 37 it/s, elapsed:  2s, eta:  1s
STOMP [====================>-----------]  64% at 38 it/s, elapsed:  2s, eta:  1s
STOMP [====================>-----------]  65% at 39 it/s, elapsed:  2s, eta:  1s
STOMP [====================>-----------]  66% at 39 it/s, elapsed:  2s, eta:  1s
STOMP [=====================>----------]  67% at 40 it/s, elapsed:  2s, eta:  1s
STOMP [=====================>----------]  68% at 40 it/s, elapsed:  2s, eta:  1s
STOMP [=====================>----------]  69% at 41 it/s, elapsed:  2s, eta:  1s
STOMP [======================>---------]  70% at 41 it/s, elapsed:  2s, eta:  1s
STOMP [======================>---------]  71% at 42 it/s, elapsed:  2s, eta:  1s
STOMP [======================>---------]  72% at 42 it/s, elapsed:  2s, eta:  1s
STOMP [=======================>--------]  73% at 43 it/s, elapsed:  2s, eta:  1s
STOMP [=======================>--------]  74% at 44 it/s, elapsed:  2s, eta:  1s
STOMP [=======================>--------]  76% at 44 it/s, elapsed:  2s, eta:  1s
STOMP [=======================>--------]  77% at 45 it/s, elapsed:  2s, eta:  1s
STOMP [========================>-------]  78% at 45 it/s, elapsed:  2s, eta:  0s
STOMP [========================>-------]  79% at 46 it/s, elapsed:  2s, eta:  0s
STOMP [========================>-------]  80% at 46 it/s, elapsed:  2s, eta:  0s
STOMP [=========================>------]  81% at 47 it/s, elapsed:  2s, eta:  0s
STOMP [=========================>------]  82% at 47 it/s, elapsed:  2s, eta:  0s
STOMP [=========================>------]  83% at 48 it/s, elapsed:  2s, eta:  0s
STOMP [==========================>-----]  84% at 49 it/s, elapsed:  2s, eta:  0s
STOMP [==========================>-----]  85% at 49 it/s, elapsed:  2s, eta:  0s
STOMP [==========================>-----]  86% at 50 it/s, elapsed:  2s, eta:  0s
STOMP [===========================>----]  87% at 50 it/s, elapsed:  2s, eta:  0s
STOMP [===========================>----]  88% at 51 it/s, elapsed:  2s, eta:  0s
STOMP [===========================>----]  89% at 51 it/s, elapsed:  2s, eta:  0s
STOMP [============================>---]  90% at 52 it/s, elapsed:  2s, eta:  0s
STOMP [============================>---]  91% at 52 it/s, elapsed:  2s, eta:  0s
STOMP [============================>---]  92% at 53 it/s, elapsed:  2s, eta:  0s
STOMP [=============================>--]  93% at 53 it/s, elapsed:  2s, eta:  0s
STOMP [=============================>--]  94% at 54 it/s, elapsed:  2s, eta:  0s
STOMP [=============================>--]  95% at 55 it/s, elapsed:  2s, eta:  0s
STOMP [==============================>-]  96% at 55 it/s, elapsed:  2s, eta:  0s
STOMP [==============================>-]  97% at 56 it/s, elapsed:  2s, eta:  0s
STOMP [==============================>-]  98% at 56 it/s, elapsed:  2s, eta:  0s
STOMP [===============================>]  99% at 57 it/s, elapsed:  2s, eta:  0s
STOMP [================================] 100% at 57 it/s, elapsed:  2s, eta:  0s
## Finished in 1.71 secs
```


``` r
# Show only timestamps flagged as events
  print(detection |> dplyr::filter(event==TRUE))
```

```
##    idx event  type seq seqlen
## 1    6  TRUE motif   3      4
## 2   19  TRUE motif   2      4
## 3   25  TRUE motif   1      4
## 4   31  TRUE motif   3      4
## 5   44  TRUE motif   2      4
## 6   50  TRUE motif   1      4
## 7   56  TRUE motif   3      4
## 8   69  TRUE motif   2      4
## 9   75  TRUE motif   1      4
## 10  81  TRUE motif   3      4
## 11  94  TRUE motif   2      4
```


``` r
# Evaluate detections against ground-truth labels
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      3     8    
## FALSE     0     90
```


``` r
# Plot detections over the series
  har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/hmo_mp_stomp/unnamed-chunk-11-1.png)
