---
title: "KSWIN with `hcp_kswin()`"
output: rmarkdown::html_document
---



## Objective

This notebook demonstrates KSWIN change-point detection on a univariate time series. The detector compares an early sample with the most recent observations inside a sliding window and flags a changepoint when the two distributions differ significantly.

## Method at a glance

KSWIN is a window-based sequential detector for distributional change. In Harbinger it is restricted to one numeric series so that the output can be interpreted directly as virtual drift on the observed signal.

## Prepare the Example


``` r
data(examples_changepoints)
dataset <- examples_changepoints$simple
```

## Visualize the Raw Series


``` r
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-2](fig/18-kswin-hcp_kswin/unnamed-chunk-2-1.png)

## Configure the Method


``` r
model <- hcp_kswin(window_size = 100, stat_size = 30, alpha = 0.005)
```

```
## Warning: internal error 1 in R_decompress1 with libdeflate
```

```
## Error:
## ! lazy-load database 'C:/R/R-4.5.0/library/harbinger/R/harbinger.rdb' is corrupt
```

``` r
model <- fit(model, dataset$serie)
```

```
## Error:
## ! object 'model' not found
```

## Run Detection


``` r
detection <- detect(model, dataset$serie)
```

```
## Error:
## ! object 'model' not found
```

``` r
print(detection[detection$event, ])
```

```
## Error:
## ! object 'detection' not found
```

## Evaluate the Result


``` r
evaluation <- evaluate(har_eval(), detection$event, dataset$event)
```

```
## Error:
## ! object 'detection' not found
```

``` r
print(evaluation$confMatrix)
```

```
## Error:
## ! object 'evaluation' not found
```

## Plot the Detections


``` r
har_plot(model, dataset$serie, detection, dataset$event)
```

```
## Error:
## ! object 'detection' not found
```

## References

- Raab C, Heusinger M, Schleif FM (2020). Reactive Soft Prototype Computing for Concept Drift Streams. Neurocomputing.
- Bifet A, Gavaldà R (2007). Learning from time-changing data with adaptive windowing. SIAM International Conference on Data Mining.
