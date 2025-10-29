EMD regression anomaly detection: This detector uses Empirical Mode Decomposition (CEEMD) to extract intrinsic mode functions (IMFs) and isolates high-frequency components that capture abrupt deviations. Anomalies are flagged where these components show large magnitudes relative to baseline. Computation wraps `hht::CEEMD` and thresholds are applied via `harutils()`.

The EMD-based detector (CEEMD variant) decomposes the series into intrinsic mode functions (IMFs) and uses high-frequency components to flag anomalies. In this tutorial we:

- Load and visualize a simple anomaly dataset
- Configure and run the EMD detector (`hanr_emd`)
- Inspect detections, evaluate, and plot residual magnitudes


``` r
# Install Harbinger (if needed)
#install.packages("harbinger")
```


``` r
# Load required packages
library(daltoolbox)
library(harbinger) 
```


``` r
# Load example anomaly datasets
data(examples_anomalies)
```


``` r
# Select a simple anomaly dataset
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
# Plot the raw time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/hanr_emd/unnamed-chunk-5-1.png)


``` r
# Configure the EMD-based detector
model <- hanr_emd()
```


``` r
# Fit the detector
model <- fit(model, dataset$serie)
```


``` r
# Run detection
detection <- detect(model, dataset$serie)
```


``` r
# Show detected anomaly indices
print(detection |> dplyr::filter(event == TRUE))
```

```
##   idx event    type
## 1  50  TRUE anomaly
```


``` r
# Evaluate detections against labels
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
# Plot detections vs. ground truth
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/hanr_emd/unnamed-chunk-11-1.png)


``` r
# Plot residual magnitude and decision thresholds
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-12](fig/hanr_emd/unnamed-chunk-12-1.png)

References 
- Huang, N. E., et al. (1998). The empirical mode decomposition and the Hilbert spectrum for nonlinear and non-stationary time series analysis. Proceedings of the Royal Society A.

