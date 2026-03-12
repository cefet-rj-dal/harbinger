## Objective

This tutorial introduces anomaly detection with a very simple and interpretable baseline: `hanr_histogram()`. The goal is to help the reader understand what a detector does before moving to model-based methods.

## Method at a glance

`hanr_histogram()` builds a histogram of observed values and marks points as anomalies when they fall in very low-density bins or outside the observed range. It is useful as a first baseline because it focuses on the empirical distribution of the series.

## What you will do

- load a labeled anomaly dataset
- run the histogram-based detector
- inspect which points were flagged
- compare detections against the ground truth

## Walkthrough


``` r
library(daltoolbox)
library(harbinger)
```


``` r
data(examples_anomalies)
dataset <- examples_anomalies$simple
har_plot(harbinger(), dataset$serie, event = dataset$event)
```

![plot of chunk unnamed-chunk-2](fig/04-first-anomaly-detector/unnamed-chunk-2-1.png)


``` r
# Configure a simple baseline detector
model <- hanr_histogram(density_threshold = 0.05)
detection <- detect(model, dataset$serie)
head(detection)
```

```
##   idx event    type
## 1   1  TRUE anomaly
## 2   2 FALSE        
## 3   3 FALSE        
## 4   4 FALSE        
## 5   5 FALSE        
## 6   6 FALSE
```


``` r
# Compare detections with the labeled events
evaluation <- evaluate(model, detection$event, dataset$event)
evaluation$confMatrix
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     1    
## FALSE     0     99
```


``` r
# Plot detections and labels together
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-5](fig/04-first-anomaly-detector/unnamed-chunk-5-1.png)

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. Springer, 2025. doi:10.1007/978-3-031-75941-3
