# Overview

This Rmd demonstrates anomaly detection via a basic feed-forward autoencoder (`han_autoencoder(..., autoenc_ed, ...)`). The model reconstructs the input window; high reconstruction error indicates anomalies. Steps: load packages/data, visualize, define the autoencoder (layers/epochs), fit, detect, evaluate, and plot series and residuals.


``` r
# Install Harbinger (only once, if needed)
#install.packages("harbinger")
```


``` r
# Load required packages
library(daltoolbox)
library(daltoolboxdp)
library(harbinger) 
```


``` r
# Load example datasets bundled with harbinger
data(examples_anomalies)
```


``` r
# Select a simple synthetic time series with labeled anomalies
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


``` r
# Plot the time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/han_autoenc_ed/unnamed-chunk-5-1.png)


``` r
# Define autoencoder-based detector (autoenc_ed)
# - first/second args: encoder/decoder sizes; num_epochs: training epochs
model <- han_autoencoder(3, 2, autoenc_ed, num_epochs = 1500)
```


``` r
# Fit the model
  model <- fit(model, dataset$serie)
```

```
## No module named 'torch'
```


``` r
# Detect anomalies (reconstruction error -> events)
  detection <- detect(model, dataset$serie)
```

```
## No module named 'torch'
```


``` r
# Show only timestamps flagged as events
  print(detection |> dplyr::filter(event==TRUE))
```

```
## Error: objeto 'detection' não encontrado
```


``` r
# Evaluate detections against ground-truth labels
  evaluation <- evaluate(model, detection$event, dataset$event)
```

```
## Error: objeto 'detection' não encontrado
```

``` r
  print(evaluation$confMatrix)
```

```
## Error: objeto 'evaluation' não encontrado
```


``` r
# Plot detections over the series
  har_plot(model, dataset$serie, detection, dataset$event)
```

```
## Error: objeto 'detection' não encontrado
```


``` r
# Plot residual scores and threshold
  har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

```
## Error: objeto 'detection' não encontrado
```
