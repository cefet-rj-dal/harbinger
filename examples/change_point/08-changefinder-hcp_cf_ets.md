## Objective

ChangeFinder-ETS detects change points by modeling residual deviations with an ETS model and smoothing over a sliding window. We will:

- Load and visualize a simple change-point dataset
- Configure the ChangeFinder-ETS detector (`sw_size` controls smoothing)
- Inspect detections, evaluate, and plot residuals with thresholds

## Method at a glance

ChangeFinder with ETS: ChangeFinder with ETS models residual deviations and applies a second-stage smoothing/thresholding to highlight structural changes. Implementation wraps ETS from `forecast` and uses `harutils()` for thresholds.

## What you will do

- understand the purpose of the example and when the technique is useful
- follow the workflow from data loading to model fitting and detection
- inspect the evaluation outputs and the diagnostic plots produced by Harbinger

## How to read this walkthrough

The code blocks below follow the same learning rhythm used throughout the collection: prepare the environment, choose the dataset, configure the method, run the analysis, and then inspect the result. Readers who are still learning time-series mining can use that order to understand not only *what* each command does, but also *why* it appears at that stage of the workflow.

As you go through the notebook, read the inline comments inside each chunk as the operational explanation and use the surrounding prose as the conceptual guide.

## Walkthrough


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
# Load example change-point datasets
data(examples_changepoints)
```


``` r
# Select the simple dataset
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


``` r
# Plot the raw time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/08-changefinder-hcp_cf_ets/unnamed-chunk-5-1.png)


``` r
# Configure ChangeFinder-ETS
model <- hcp_cf_ets(sw_size = 10)
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
# Show detected change points
print(detection |> dplyr::filter(event == TRUE))
```

```
##   idx event    type
## 1  51  TRUE anomaly
```


``` r
# Evaluate detections against labels
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0     1    
## FALSE     1     99
```


``` r
# Plot detections vs. ground truth
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/08-changefinder-hcp_cf_ets/unnamed-chunk-11-1.png)


``` r
# Plot residual magnitude and decision thresholds
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-12](fig/08-changefinder-hcp_cf_ets/unnamed-chunk-12-1.png)

## References

- Takeuchi, J., Yamanishi, K. (2006). A unifying framework for detecting outliers and change points from time series. IEEE TKDE. doi:10.1109/TKDE.2006.1599387


