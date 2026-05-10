## Tutorial 07 - First Change-Point Detector

Change-point detection is different from point-anomaly detection: the target is a transition in the behavior of the series, not only an isolated unusual observation. `hcp_amoc()` is a good first method because it searches for one dominant break.

This notebook keeps the workflow short so the reader can focus on the meaning of a labeled change point.

The technique behind AMOC is single-break optimization: among all possible split positions, the method searches for the location that best separates two regimes with distinct statistical behavior. It is a strong entry point before studying multiple-break methods.


``` r
library(harbinger)

data(examples_changepoints)
dataset <- examples_changepoints$simple
head(dataset)
```

```
##   serie event
## 1  0.00 FALSE
## 2  0.25 FALSE
## 3  0.50 FALSE
## 4  0.75 FALSE
## 5  1.00 FALSE
## 6  1.25 FALSE
```

Plot the original series and the labeled change point.

``` r
har_plot(harbinger(), dataset$serie, event = dataset$event)
```

![plot of chunk unnamed-chunk-2](fig/07-first-change-point-detector/unnamed-chunk-2-1.png)

Configure the detector and inspect the detected location.

``` r
model <- hcp_amoc()
```

```
## Warning: restarting interrupted promise evaluation
```

```
## Error:
## ! cannot allocate vector of size 3.9 Gb
```

``` r
detection <- detect(model, dataset$serie)
```

```
## Error:
## ! object 'model' not found
```

``` r
detection
```

```
## Error:
## ! object 'detection' not found
```

Plot the result against the reference event.

``` r
har_plot(model, dataset$serie, detection, dataset$event)
```

```
## Error:
## ! object 'detection' not found
```

## References

- Killick, R., Eckley, I. A. changepoint: An R Package for Changepoint Analysis. Journal of Statistical Software, 58(3), 2014.
