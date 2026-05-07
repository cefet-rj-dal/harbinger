---
title: "BOCPD with `hcp_bocpd()`"
output: rmarkdown::html_document
---




``` r
data(examples_changepoints)
dataset <- examples_changepoints$simple

model <- hcp_bocpd(hazard = 100, dist = "gaussian", threshold = 0.5)
```

```
## Error in `hcp_bocpd()`:
## ! could not find function "hcp_bocpd"
```

``` r
model <- fit(model, dataset$serie)
```

```
## Error:
## ! object 'model' not found
```

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

``` r
har_plot(model, dataset$serie, detection, dataset$event)
```

```
## Error:
## ! object 'detection' not found
```
