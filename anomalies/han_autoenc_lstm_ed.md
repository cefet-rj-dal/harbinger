
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

![plot of chunk unnamed-chunk-5](fig/han_autoenc_lstm_ed/unnamed-chunk-5-1.png)


``` r
# Define LSTM autoencoder-based detector (autoenc_lstm_ed)
  model <- han_autoencoder(3, 2, autoenc_lstm_ed, num_epochs = 1500)
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
# plotting the residuals
  har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

```
## Error: objeto 'detection' não encontrado
```
# Overview

This Rmd demonstrates anomaly detection with an LSTM autoencoder (`han_autoencoder(..., autoenc_lstm_ed, ...)`). The model encodes and decodes sequences; high reconstruction error flags anomalies. Steps: load packages/data, visualize, define the architecture/epochs, fit, detect, evaluate, and plot.
