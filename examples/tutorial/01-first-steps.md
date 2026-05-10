## Tutorial 01 - First Steps

The first objective is simple: understand the basic Harbinger workflow on a labeled series. In the examples that follow, this same rhythm will appear repeatedly: load data, configure a method, run the analysis, inspect the output, and plot the result.

This notebook uses the default `harbinger()` object because the focus is not on a specific detector yet. The goal is to make the package interface familiar before introducing specialized methods.

Conceptually, this object represents the common contract of the package: a Harbinger method receives a series and returns a standardized event-oriented output that can later be plotted or evaluated. Learning that contract first makes the later detectors much easier to understand.


``` r
# Install Harbinger (if needed)
# install.packages("harbinger")
```

Load the package and a small labeled anomaly series.

``` r
library(harbinger)

data(examples_anomalies)
dataset <- examples_anomalies$simple
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

Before running a method, it helps to see the series and the known event labels.

``` r
har_plot(harbinger(), dataset$serie, event = dataset$event)
```

![plot of chunk unnamed-chunk-3](fig/01-first-steps/unnamed-chunk-3-1.png)

Now create the default Harbinger model.

``` r
model <- harbinger()
```

Run the analysis and inspect the returned structure.

``` r
detection <- detect(model, dataset$serie)
head(detection)
```

```
##   idx event type
## 1   1 FALSE     
## 2   2 FALSE     
## 3   3 FALSE     
## 4   4 FALSE     
## 5   5 FALSE     
## 6   6 FALSE
```

Finish by plotting the detections against the labeled events.

``` r
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-6](fig/01-first-steps/unnamed-chunk-6-1.png)

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. Springer, 2025. doi:10.1007/978-3-031-75941-3
