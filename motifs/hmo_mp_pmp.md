# Overview

This Rmd demonstrates motif discovery with the Pan Matrix Profile (`hmo_mp("pmp", ...)`), which summarizes motifs across multiple subsequence lengths. Steps: load packages/data, visualize, configure parameters, fit, detect, evaluate, and plot.


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

![plot of chunk unnamed-chunk-5](fig/hmo_mp_pmp/unnamed-chunk-5-1.png)


``` r
# Define Pan Matrix Profile (PMP) motif model
# - second arg: subsequence length (window)
# - third arg: number of motifs to retrieve
  model <- hmo_mp("pmp", 4, 3)
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
## step: 1/1 binary idx: 1 window: 4
```


``` r
# Show only timestamps flagged as events
  print(detection |> dplyr::filter(event==TRUE))
```

```
##   idx event  type seq seqlen
## 1  19  TRUE motif   3      4
## 2  25  TRUE motif   2      4
## 3  44  TRUE motif   3      4
## 4  50  TRUE motif   2      4
## 5  69  TRUE motif   3      4
## 6  75  TRUE motif   2      4
## 7  94  TRUE motif   3      4
```


``` r
# Evaluate detections against ground-truth labels
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      3     4    
## FALSE     0     94
```


``` r
# Plot detections over the series
  har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/hmo_mp_pmp/unnamed-chunk-11-1.png)

