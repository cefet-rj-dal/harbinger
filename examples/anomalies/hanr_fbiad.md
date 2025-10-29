FBIAD regression anomaly detection: Forward and Backward Inertial Anomaly Detector compares each point against forward and backward inertia, flagging observations that break both temporal tendencies. Scores are summarized and thresholded using `harutils()`.

FBIAD (Forward and Backward Inertial Anomaly Detector) compares deviations from sliding-window means computed forward and backward in time, then merges evidence. In this tutorial we:

- Load and visualize a simple anomaly dataset
- Configure and run the FBIAD detector (`hanr_fbiad`)
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

![plot of chunk unnamed-chunk-5](fig/hanr_fbiad/unnamed-chunk-5-1.png)


``` r
# Configure the FBIAD detector
model <- hanr_fbiad()
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

![plot of chunk unnamed-chunk-11](fig/hanr_fbiad/unnamed-chunk-11-1.png)


``` r
# Plot residual magnitude and decision thresholds
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-12](fig/hanr_fbiad/unnamed-chunk-12-1.png)

References 
- Lima, J., et al. Forward and Backward Inertial Anomaly Detector: A Novel Time Series Event Detection Method. IJCNN, 2022. doi:10.1109/IJCNN55064.2022.9892088
