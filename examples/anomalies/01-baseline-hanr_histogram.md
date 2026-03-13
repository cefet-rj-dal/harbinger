## Objective

This notebook demonstrates anomaly detection with `hanr_histogram()`. The goal is to show how a simple histogram-based density rule can flag rare observations without fitting a forecasting model.

## Method at a glance

`hanr_histogram()` builds a histogram of the observed values and labels points as anomalies when they fall into low-density bins or outside the observed bin range. It is a useful baseline because it focuses only on the empirical distribution of the series.

## What you will do

- load a labeled anomaly dataset from Harbinger
- inspect the raw series before modeling
- configure the histogram detector and run detection
- compare the detected events with the ground truth
- visualize the result with `har_plot()`

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
```

```
## 
## Attaching package: 'daltoolbox'
```

```
## The following object is masked from 'package:base':
## 
##     transform
```

``` r
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
har_plot(harbinger(), dataset$serie, event = dataset$event)
```

![plot of chunk unnamed-chunk-5](fig/01-baseline-hanr_histogram/unnamed-chunk-5-1.png)







### Configure the Method

The next step is to instantiate the method and, when necessary, fit it to the selected series. This is where the notebook makes its analytical choice explicit: the parameters chosen here determine what kind of pattern the detector or transformer will become sensitive to and how the later outputs should be interpreted.


``` r
# Configure the histogram-based anomaly detector
# The density threshold controls how rare a bin must be to trigger an anomaly
model <- hanr_histogram(density_threshold = 0.05)
```




``` r
# Fit is a no-op here, but keeping the same workflow is useful for comparison
model <- fit(model, dataset$serie)
```







### Run the Core Analysis

With the environment and the method ready, we execute the central analytical step and inspect its immediate output. This is the point where the abstract idea described earlier becomes operational, so the reader should pay attention to what is produced and how Harbinger standardizes the result.


``` r
# Run detection
detection <- detect(model, dataset$serie)
```




``` r
# Show the detected anomaly indices
print(detection |> dplyr::filter(event == TRUE))
```

```
##   idx event    type
## 1   1  TRUE anomaly
## 2  50  TRUE anomaly
```







### Evaluate What Was Found

After producing detections or transformed outputs, we compare them with the reference labels whenever they are available. This stage matters because it connects the visual intuition of the method with an explicit measurement of quality, helping the learner understand not only whether the method runs, but how well it behaves.


``` r
# Evaluate detections against the labeled events
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     1    
## FALSE     0     99
```







### Interpret the Result Visually

The final plots are not just illustrations. They help the reader connect the method's internal output with the original series, making it easier to see why a point, range, motif, or symbolic pattern was emphasized and whether that emphasis is coherent with the stated objective of the example.


``` r
# Plot detections and ground truth on the same series
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/01-baseline-hanr_histogram/unnamed-chunk-11-1.png)

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. Springer, 2025. doi:10.1007/978-3-031-75941-3

