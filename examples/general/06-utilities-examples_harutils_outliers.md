## Objective

The goal of this notebook is to present a complete Harbinger workflow: loading an example dataset, configuring the method used in the notebook, running the analysis, and interpreting the resulting outputs and plots.

## Method at a glance

This notebook shows how Harbinger's utility functions for distance aggregation, thresholding, and grouping affect anomaly flags and decision thresholds. We compare Gaussian 3-sigma vs. boxplot/IQR vs. ratio rules, and grouping strategies for contiguous detections.

## What you will do

- understand the purpose of the example and when the technique is useful
- follow the workflow from data loading to model fitting and detection
- inspect the evaluation outputs and the diagnostic plots produced by Harbinger








### Prepare the Example

This setup anchors the notebook in the specific series used to examine `harutils()`. The semantic point is the one stated above: this notebook shows how Harbinger's utility functions for distance aggregation, thresholding, and grouping affect anomaly flags and decision thresholds, so the raw signal needs to be visible before any fitting step hides that structure behind model output.


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
# Instantiate utilities
hutils <- harutils()
```







### Interpret the Result Visually

This first visual pass establishes what the method should react to in the raw series. Keep the method summary in mind here, because this notebook shows how Harbinger's utility functions for distance aggregation, thresholding, and grouping affect anomaly flags and decision thresholds and the plot tells you whether that structure is clean, weak, local, repeated, or mixed with other effects.


``` r
# Load a simple anomaly dataset and plot it
data(examples_anomalies)
dataset <- examples_anomalies$simple
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-4](fig/06-utilities-examples_harutils_outliers/unnamed-chunk-4-1.png)







### Configure the Method

The choices below turn the central modeling idea into concrete parameters. They matter because this notebook shows how Harbinger's utility functions for distance aggregation, thresholding, and grouping affect anomaly flags and decision thresholds, so each argument controls how strongly the method will emphasize that pattern when it later produces utility outputs.


``` r
# Baseline: ARIMA with default distance (L2) and threshold (Gaussian 3-sigma)
model <- hanr_arima()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-5](fig/06-utilities-examples_harutils_outliers/unnamed-chunk-5-1.png)




``` r
# Use Boxplot/IQR threshold instead of Gaussian
model <- hanr_arima()
model$har_outliers <- hutils$har_outliers_boxplot
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-6](fig/06-utilities-examples_harutils_outliers/unnamed-chunk-6-1.png)




``` r
# Use ratio thresholding emphasizing relative deviation
model <- hanr_arima()
model$har_outliers <- hutils$har_outliers_ratio
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-7](fig/06-utilities-examples_harutils_outliers/unnamed-chunk-7-1.png)




``` r
# Change distance to L1 (absolute deviation)
model <- hanr_arima()
model$har_distance <- hutils$har_distance_l1
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-8](fig/06-utilities-examples_harutils_outliers/unnamed-chunk-8-1.png)




``` r
# L1 distance + Boxplot/IQR threshold
model <- hanr_arima()
model$har_distance <- hutils$har_distance_l1
model$har_outliers <- hutils$har_outliers_boxplot
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-9](fig/06-utilities-examples_harutils_outliers/unnamed-chunk-9-1.png)




``` r
# L1 distance + ratio threshold
model <- hanr_arima()
model$har_distance <- hutils$har_distance_l1
model$har_outliers <- hutils$har_outliers_ratio
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-10](fig/06-utilities-examples_harutils_outliers/unnamed-chunk-10-1.png)




``` r
# Keep only the highest-magnitude index in contiguous runs
model <- hanr_arima()
model$har_distance <- hutils$har_distance_l1
model$har_outliers <- hutils$har_outliers_boxplot
model$har_outliers_check <- hutils$har_outliers_checks_highgroup
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-11](fig/06-utilities-examples_harutils_outliers/unnamed-chunk-11-1.png)

## References

- Tukey, J. W. (1977). Exploratory Data Analysis. Addison-Wesley. (boxplot/IQR outlier rule)
- Shewhart, W. A. (1931). Economic Control of Quality of Manufactured Product. D. Van Nostrand. (three-sigma rule)
