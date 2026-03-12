## Objective

This notebook explains how to use `mas()` as a simple moving-average transformation for time series. The goal is to help the reader understand what the smoother does, how the `order` parameter changes the result, and why smoothing can be useful before downstream tasks such as change-point detection.

## Method at a glance

`mas()` computes a simple moving average. Each output point is the average of a local window of consecutive observations. As a transformation, it reduces short-term noise and makes broader movement patterns easier to inspect.

## What you will do

- load an example time series
- inspect the original series
- compute moving-average smoothers with different window sizes
- compare the original and smoothed versions visually
- understand the trade-off between smoothness and temporal detail
- see why smoothing is often used before a modeling step

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
library(harbinger)
```






``` r
# Load example change-point datasets
data(examples_changepoints)
```




``` r
# Select a simple change-point dataset
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







### Interpret the Result Visually

The final plots are not just illustrations. They help the reader connect the method's internal output with the original series, making it easier to see why a point, range, motif, or symbolic pattern was emphasized and whether that emphasis is coherent with the stated objective of the example.


``` r
# Plot the original time series
har_plot(harbinger(), dataset$serie, event = dataset$event)
```

![plot of chunk unnamed-chunk-5](fig/01-smoothing-mas/unnamed-chunk-5-1.png)







### Configure the Method

The next step is to instantiate the method and, when necessary, fit it to the selected series. This is where the notebook makes its analytical choice explicit: the parameters chosen here determine what kind of pattern the detector or transformer will become sensitive to and how the later outputs should be interpreted.


``` r
# Compute smoothers with two different window sizes
ma_5 <- mas(dataset$serie, order = 5)
ma_15 <- mas(dataset$serie, order = 15)
```








``` r
# Inspect the first smoothed values
head(ma_5)
```

```
## Time Series:
## Start = 1 
## End = 6 
## Frequency = 1 
## [1] 0.50 0.75 1.00 1.25 1.50 1.75
```

``` r
head(ma_15)
```

```
## Time Series:
## Start = 1 
## End = 6 
## Frequency = 1 
## [1] 1.75 2.00 2.25 2.50 2.75 3.00
```







### Interpret the Result Visually

The final plots are not just illustrations. They help the reader connect the method's internal output with the original series, making it easier to see why a point, range, motif, or symbolic pattern was emphasized and whether that emphasis is coherent with the stated objective of the example.


``` r
# Plot the 5-point moving average
har_plot(
  harbinger(),
  as.numeric(ma_5),
  event = dataset$event[5:length(dataset$event)]
)
```

![plot of chunk unnamed-chunk-8](fig/01-smoothing-mas/unnamed-chunk-8-1.png)




``` r
# Plot the 15-point moving average
har_plot(
  harbinger(),
  as.numeric(ma_15),
  event = dataset$event[15:length(dataset$event)]
)
```

![plot of chunk unnamed-chunk-9](fig/01-smoothing-mas/unnamed-chunk-9-1.png)

## References

- Shumway, R. H., Stoffer, D. S. Time Series Analysis and Its Applications. Springer.

