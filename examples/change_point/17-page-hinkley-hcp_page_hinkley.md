---
title: "Page-Hinkley with `hcp_page_hinkley()`"
output: rmarkdown::html_document
---



## Objective

This notebook demonstrates Page-Hinkley change-point detection on a univariate time series. The detector monitors the cumulative deviation from the running mean and flags a changepoint when the score becomes too large.

## Method at a glance

Page-Hinkley is a sequential test for persistent mean shifts. In Harbinger it is used as a univariate change-point detector for virtual drift in a single numeric series.

## Prepare the Example


``` r
data(examples_changepoints)
dataset <- examples_changepoints$simple
```

## Visualize the Raw Series


``` r
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-2](fig/17-page-hinkley-hcp_page_hinkley/unnamed-chunk-2-1.png)

## Configure the Method


``` r
model <- hcp_page_hinkley(min_instances = 30, delta = 0.005, threshold = 3, alpha = 0.999)
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

- Page ES (1954). Continuous Inspection Schemes. Biometrika, 41(1/2), 100-115.
- Raab C, Heusinger M, Schleif FM (2020). Reactive Soft Prototype Computing for Concept Drift Streams. Neurocomputing.
