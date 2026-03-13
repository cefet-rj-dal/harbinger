## Objective

The ARIMA-based anomaly detector fits an ARIMA model to the time series and flags large residuals as anomalies. In this walkthrough we will:

- Load a synthetic anomaly dataset and visualize it
- Configure and run the ARIMA detector (`hanr_arima`)
- Inspect detections, evaluate against ground truth, and plot residuals and thresholds

## Method at a glance

ARIMA regression anomaly detection: This detector fits an ARIMA(p, d, q) model to the series and uses large standardized residuals as anomaly evidence. After estimating the model, residual magnitudes are summarized via a distance function and thresholded using outlier heuristics provided by `harutils()`.

## What you will do

- understand the purpose of the example and when the technique is useful
- follow the workflow from data loading to model fitting and detection
- inspect the evaluation outputs and the diagnostic plots produced by Harbinger

## How to read this walkthrough

The code blocks below follow the same learning rhythm used throughout the collection: prepare the environment, choose the dataset, configure the method, run the analysis, and then inspect the result. Readers who are still learning time-series mining can use that order to understand not only *what* each command does, but also *why* it appears at that stage of the workflow.

As you go through the notebook, read the inline comments inside each chunk as the operational explanation and use the surrounding prose as the conceptual guide.

## Walkthrough







### Prepare the Example

We begin by organizing the environment, loading the packages, and selecting the dataset used in the notebook. This part is intentionally more direct: the goal is to make the starting point explicit before the method-specific reasoning begins.


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







### Interpret the Result Visually

The final plots are not just illustrations. They help the reader connect the method's internal output with the original series, making it easier to see why a point, range, motif, or symbolic pattern was emphasized and whether that emphasis is coherent with the stated objective of the example.


``` r
# Plot the raw time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/02-regression-hanr_arima/unnamed-chunk-5-1.png)







### Configure the Method

The next step is to instantiate the method and, when necessary, fit it to the selected series. This is where the notebook makes its analytical choice explicit: the parameters chosen here determine what kind of pattern the detector or transformer will become sensitive to and how the later outputs should be interpreted.


``` r
# Configure ARIMA-based anomaly detector
model <- hanr_arima()
```




``` r
# Fit the detector (estimates ARIMA order and caches parameters)
model <- fit(model, dataset$serie)
```







### Run the Core Analysis

With the environment and the method ready, we execute the central analytical step and inspect its immediate output. This is the point where the abstract idea described earlier becomes operational, so the reader should pay attention to what is produced and how Harbinger standardizes the result.


``` r
# Run detection to compute residual magnitudes and flags
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







### Evaluate What Was Found

After producing detections or transformed outputs, we compare them with the reference labels whenever they are available. This stage matters because it connects the visual intuition of the method with an explicit measurement of quality, helping the learner understand not only whether the method runs, but how well it behaves.


``` r
# Evaluate detections against labeled events
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     0    
## FALSE     0     100
```







### Interpret the Result Visually

The final plots are not just illustrations. They help the reader connect the method's internal output with the original series, making it easier to see why a point, range, motif, or symbolic pattern was emphasized and whether that emphasis is coherent with the stated objective of the example.


``` r
# Plot detections vs. ground truth
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/02-regression-hanr_arima/unnamed-chunk-11-1.png)




``` r
# Plot the residual magnitude and the decision thresholds
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-12](fig/02-regression-hanr_arima/unnamed-chunk-12-1.png)

## References

- Box, G. E. P., Jenkins, G. M., Reinsel, G. C., Ljung, G. M. (2015). Time Series Analysis: Forecasting and Control. Wiley.
