Ensemble Fuzzy anomaly detection: Ensemble voting with temporal fuzzification merges detections within a tolerance window into a single event before voting, reducing duplicate triggers and aligning with ground-truth granularity.

Objectives: This Rmd demonstrates anomaly detection using a fuzzy-tolerant ensemble (`har_ensemble(...)` with `time_tolerance`). Multiple detectors (FBIAD, ARIMA, EMD) vote and detections within a time tolerance are merged. Steps: load packages/data, visualize, define ensemble and tolerance, fit, detect, evaluate, and plot.


``` r
# Install Harbinger (only once, if needed)
#install.packages("harbinger")
```


``` r
# Load required packages
library(daltoolbox)
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

![plot of chunk unnamed-chunk-5](fig/hanr_ensemble_fuzzy/unnamed-chunk-5-1.png)


``` r
# Define the ensemble and set time tolerance for fuzzy matching
  model <- har_ensemble(hanr_fbiad(), hanr_arima(), hanr_emd())
  model$time_tolerance <- 10
```


``` r
# Fit the model
  model <- fit(model, dataset$serie)
```


``` r
# Detect anomalies via ensemble voting with tolerance
  detection <- detect(model, dataset$serie)
```


``` r
# Show only timestamps flagged as events
  print(detection |> dplyr::filter(event==TRUE))
```

```
##   idx event    type
## 1  50  TRUE anomaly
```


``` r
# Evaluate detections against ground-truth labels
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     0    
## FALSE     0     100
```


``` r
# Plot detections over the series
  har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/hanr_ensemble_fuzzy/unnamed-chunk-11-1.png)

``` r
# Plot residual scores and threshold
  har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-12](fig/hanr_ensemble_fuzzy/unnamed-chunk-12-1.png)

References 
- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. Springer, 2025. doi:10.1007/978-3-031-75941-3
