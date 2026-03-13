## Tutorial 04 - First Anomaly Detector

This tutorial introduces anomaly detection with a simple and interpretable baseline: `hanr_histogram()`. It is a good first detector because the logic is easy to explain: points in very low-density histogram bins are treated as unusual.

The value of this notebook is not raw performance. It gives the reader a concrete reference before moving to model-based methods.

The technique is distribution-based anomaly detection. Instead of learning temporal dynamics, the method asks a simpler question: which values are rare relative to the empirical distribution of the series? That makes it useful as a baseline and as a sanity check.

Load the packages and a labeled anomaly series.

``` r
library(daltoolbox)
library(harbinger)

data(examples_anomalies)
dataset <- examples_anomalies$simple
```

Plot the original series and the labeled anomalies.

``` r
har_plot(harbinger(), dataset$serie, event = dataset$event)
```

![plot of chunk unnamed-chunk-2](fig/04-first-anomaly-detector/unnamed-chunk-2-1.png)

Configure the detector, run it, and inspect the output.

``` r
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

Compare the detections with the ground truth.

``` r
evaluation <- evaluate(model, detection$event, dataset$event)
evaluation$confMatrix
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     1    
## FALSE     0     99
```

Plot detections and labels together.

``` r
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-5](fig/04-first-anomaly-detector/unnamed-chunk-5-1.png)

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. Springer, 2025. doi:10.1007/978-3-031-75941-3
