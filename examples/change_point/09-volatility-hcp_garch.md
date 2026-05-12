## Objective

This notebook demonstrates change-point detection with a GARCH-based ChangeFinder (`hcp_garch`). The detector tracks volatility regimes by scoring short-term residual behavior.

## Method at a glance

ChangeFinder with GARCH models conditional variance dynamics; residual-based scores are smoothed and thresholded to flag volatility regime shifts.

## What you will do

- load the example data and inspect the raw series
- configure the detector with a sliding window
- fit the model, detect change points, evaluate the result, and plot the output








### Prepare the Example

This setup anchors the notebook in the specific series used to examine `hcp_garch`. The key idea is that the detector works on residual behavior, so the raw signal should be visible before any fitting step hides that structure behind model output.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/main/examples/seed.R"))
```

```
## Warning in readLines(file, warn = FALSE): cannot open URL
## 'https://raw.githubusercontent.com/cefet-rj-dal/harbinger/main/examples/seed.R': HTTP status was '404 Not Found'
```

```
## Error in `readLines()`:
## ! cannot open the connection to 'https://raw.githubusercontent.com/cefet-rj-dal/harbinger/main/examples/seed.R'
```

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
# Select the same dataset used in the AMOC example
dataset <- examples_changepoints$complex
head(dataset)
```

```
##       serie event
## 1 0.3129618 FALSE
## 2 0.5944808 FALSE
## 3 0.8162731 FALSE
## 4 0.9560557 FALSE
## 5 0.9997847 FALSE
## 6 0.9430667 FALSE
```







### Interpret the Result Visually

This first visual pass establishes what the method should react to in the raw series. Keep the method summary in mind here, because the plot reveals whether the signal contains clean, weak, local, repeated, or mixed structural changes.


``` r
# Plot the raw time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/09-volatility-hcp_garch/unnamed-chunk-5-1.png)







### Configure the Method

The choices below turn the central modeling idea into concrete parameters. Each argument controls how strongly the method emphasizes residual shifts when it produces change-point candidates.


``` r
# Configure the GARCH-based ChangeFinder model
model <- hcp_garch()
```




``` r
# Fit the detector
set_example_seed()
```

```
## Error in `set_example_seed()`:
## ! could not find function "set_example_seed"
```

``` r
model <- fit(model, dataset$serie)
```







### Run the Core Analysis

This is the moment where the notebook tests its central assumption on actual data. After applying `hcp_garch`, the question is whether the resulting change-point candidates correspond to the residual pattern described above rather than to arbitrary numerical variation.


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
## 1 201  TRUE changepoint
```







### Evaluate What Was Found

The evaluation asks whether the change-point candidates produced by `hcp_garch` match the labeled structure on this dataset. Read the scores as evidence about the method's assumptions in practice, not as detached summary numbers.


``` r
# Evaluate detections against labels
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0     1    
## FALSE     4     495
```







### Interpret the Result Visually

This visual check puts the model output back on top of the original signal. What matters now is whether the highlighted change-point candidates line up with the structure suggested by the method, which is the real semantic test of whether the example is teaching the right lesson.


``` r
# Plot detections vs. ground truth
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/09-volatility-hcp_garch/unnamed-chunk-11-1.png)




``` r
# Plot residual magnitude and decision thresholds
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-12](fig/09-volatility-hcp_garch/unnamed-chunk-12-1.png)

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. Springer, 2025. doi:10.1007/978-3-031-75941-3
