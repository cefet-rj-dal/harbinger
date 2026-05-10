## Objective

This notebook demonstrates change-point detection with a ChangeFinder variant
based on ETS (`hcp_cf_ets`). The detector scores short-term prediction residuals
and flags structural changes when those scores persist.

## Method at a glance

ChangeFinder with ETS models residual deviations, smooths the score over time,
and applies a threshold to highlight structural changes. The ETS component is
provided by `forecast`, and thresholds are handled by `harutils()`.

## What you will do

- load the example data and inspect the raw series
- configure the detector with a sliding window
- fit the model, detect change points, evaluate the result, and plot the output








### Prepare the Example

This setup anchors the notebook in the specific series used to examine `hcp_cf_ets`. The key idea is that the detector works on residual deviations, so the raw signal should be visible before any fitting step hides that structure behind model output.


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







### Interpret the Result Visually

This first visual pass establishes what the method should react to in the raw series. Keep the method summary in mind here, because the plot reveals whether the signal contains clean, weak, local, repeated, or mixed structural changes.


``` r
# Plot the raw time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/08-changefinder-hcp_cf_ets/unnamed-chunk-5-1.png)







### Configure the Method

The choices below turn the central modeling idea into concrete parameters. Each argument controls how strongly the method emphasizes residual shifts when it produces change-point candidates.


``` r
# Configure the ChangeFinder-ETS model
model <- hcp_cf_ets(sw_size = 10)
```

```
## Error:
## ! cannot allocate vector of size 3.3 Gb
```




``` r
# Fit the detector
model <- fit(model, dataset$serie)
```

```
## Error:
## ! object 'model' not found
```







### Run the Core Analysis

This is the moment where the notebook tests its central assumption on actual data. After applying `hcp_cf_ets`, the question is whether the resulting change-point candidates correspond to the residual pattern described above rather than to arbitrary numerical variation.


``` r
# Run detection
detection <- detect(model, dataset$serie)
```

```
## Error:
## ! object 'model' not found
```




``` r
# Show detected change points
print(detection |> dplyr::filter(event == TRUE))
```

```
## Error:
## ! object 'detection' not found
```







### Evaluate What Was Found

The evaluation asks whether the change-point candidates produced by `harutils()` match the labeled structure on this dataset. Read the scores as evidence about the method's assumptions in practice, not as detached summary numbers.


``` r
# Evaluate detections against labels
evaluation <- evaluate(model, detection$event, dataset$event)
```

```
## Error:
## ! object 'model' not found
```

``` r
print(evaluation$confMatrix)
```

```
## Error:
## ! object 'evaluation' not found
```







### Interpret the Result Visually

This visual check puts the model output back on top of the original signal. What matters now is whether the highlighted change-point candidates line up with the structure suggested by the method, which is the real semantic test of whether the example is teaching the right lesson.


``` r
# Plot detections vs. ground truth
har_plot(model, dataset$serie, detection, dataset$event)
```

```
## Error:
## ! object 'detection' not found
```




``` r
# Plot residual magnitude and decision thresholds
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

```
## Error:
## ! object 'detection' not found
```

## References

- Takeuchi, J., Yamanishi, K. (2006). A unifying framework for detecting outliers and change points from time series. IEEE TKDE. doi:10.1109/TKDE.2006.1599387
