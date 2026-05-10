---
title: "Fuzzy Ensemble with `har_ensemble_fuzzy()`"
output: rmarkdown::html_document
---




``` r
data(examples_changepoints)
dataset <- examples_changepoints$simple

model <- har_ensemble_fuzzy(hcp_amoc(), hcp_pelt(), hcp_cf_lr())
```

```
## Error:
## ! cannot allocate vector of size 2.9 Gb
```

``` r
model <- fit(model, dataset$serie)
```

```
## Error:
## ! object 'model' not found
```

``` r
detection <- detect(model, dataset$serie, time_tolerance = 8, use_nms = TRUE)
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

``` r
har_ensemble_plot(detection, dataset$serie)
```

```
## Error:
## ! cannot allocate vector of size 2.5 Gb
```
