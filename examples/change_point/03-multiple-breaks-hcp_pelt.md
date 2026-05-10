## Objective

PELT (Pruned Exact Linear Time) finds multiple change points efficiently by pruning candidates under a penalized cost. In this tutorial we:

- Load and visualize a simple change-point dataset
- Configure and run the PELT detector (`hcp_pelt`)
- Inspect detections, evaluate, and plot results

## Method at a glance

PELT: PELT performs optimal partitioning of the time series under a penalized cost function while pruning candidate change locations to achieve near-linear time under suitable penalties. In Harbinger this wraps the `changepoint` package implementation and returns detected change indices along with evaluation helpers.

## What you will do

- understand the purpose of the example and when the technique is useful
- follow the workflow from data loading to model fitting and detection
- inspect the evaluation outputs and the diagnostic plots produced by Harbinger








### Prepare the Example

This setup anchors the notebook in the specific series used to examine `hcp_pelt`. The semantic point is the one stated above: pELT: PELT performs optimal partitioning of the time series under a penalized cost function while pruning candidate change locations to achieve near-linear time under suitable penalties, so the raw signal needs to be visible before any fitting step hides that structure behind model output.


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

This first visual pass establishes what the method should react to in the raw series. Keep the method summary in mind here, because pELT: PELT performs optimal partitioning of the time series under a penalized cost function while pruning candidate change locations to achieve near-linear time under suitable penalties and the plot tells you whether that structure is clean, weak, local, repeated, or mixed with other effects.


``` r
# Plot the raw time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/03-multiple-breaks-hcp_pelt/unnamed-chunk-5-1.png)







### Configure the Method

The choices below turn the central modeling idea into concrete parameters. They matter because pELT: PELT performs optimal partitioning of the time series under a penalized cost function while pruning candidate change locations to achieve near-linear time under suitable penalties, so each argument controls how strongly the method will emphasize that pattern when it later produces change-point candidates.


``` r
# Configure the PELT detector
model <- hcp_pelt()
```




``` r
# Fit the detector (no training required)
model <- fit(model, dataset$serie)
```







### Run the Core Analysis

This is the moment where the notebook tests its central assumption on actual data. After applying `hcp_pelt`, the important question is whether the resulting change-point candidates really correspond to the pattern implied by the method description above, rather than to arbitrary numerical variation.


``` r
# Run detection
detection <- detect(model, dataset$serie)
```




``` r
# Show detected change points
print(detection |> dplyr::filter(event == TRUE))
```

```
##   idx event        type
## 1   9  TRUE changepoint
## 2  19  TRUE changepoint
## 3  29  TRUE changepoint
## 4  39  TRUE changepoint
## 5  60  TRUE changepoint
## 6  71  TRUE changepoint
## 7  81  TRUE changepoint
## 8  91  TRUE changepoint
```







### Evaluate What Was Found

The evaluation asks whether the change-point candidates produced by `hcp_pelt` match the labeled structure on this dataset. Read the scores as evidence about the method's assumptions in practice, not as detached summary numbers.


``` r
# Evaluate detections against labels
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0     8    
## FALSE     1     92
```







### Interpret the Result Visually

This visual check puts the model output back on top of the original signal. What matters now is whether the highlighted change-point candidates line up with the structure suggested by the method, which is the real semantic test of whether the example is teaching the right lesson.


``` r
# Plot detections vs. ground truth
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/03-multiple-breaks-hcp_pelt/unnamed-chunk-11-1.png)

## References

- Killick, R., Fearnhead, P., Eckley, I. A. (2012). Optimal detection of changepoints with a linear computational cost. Journal of the American Statistical Association, 107(500), 1590-1598.
