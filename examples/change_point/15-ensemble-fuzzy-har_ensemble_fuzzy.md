## Objective

This notebook demonstrates the fuzzy ensemble `har_ensemble_fuzzy()` using a
set of change-point detectors over the same `complex` benchmark adopted across
the change-point examples.

- load and visualize the same example change-point dataset used in the AMOC notebook
- configure a fuzzy ensemble with stronger base detectors
- inspect the final detection and the ensemble score plot

## Method at a glance

The fuzzy ensemble aggregates detector outputs as scores, allows temporal
fuzzification around nearby detections, and can apply non-maximum suppression
to keep the most representative event in a local neighborhood.

## Experimental choice

For this example, the ensemble members are chosen to provide complementary
signals on `examples_changepoints$complex`:

- `hcp_scp(sw = 30)`: exact hit on the labeled changepoint in this dataset
- `hcp_chow()`: exact hit on the labeled changepoint in this dataset
- `hcp_cf_arima(sw_size = 10)`: near-hit around the same transition, useful for
  reinforcing the neighborhood under fuzzy aggregation

## What you will do

- inspect an ensemble composition for this benchmark
- fit the ensemble and run detection
- visualize the fused score over the series


``` r
# Install Harbinger (if needed)
# install.packages("harbinger")
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


``` r
# Plot the raw time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/15-ensemble-fuzzy-har_ensemble_fuzzy/unnamed-chunk-5-1.png)


``` r
# Configure the fuzzy ensemble for this dataset
model <- har_ensemble_fuzzy(
  hcp_scp(sw = 30),
  hcp_chow(),
  hcp_cf_arima(sw_size = 10)
)
```


``` r
# Fit the ensemble
model <- fit(model, dataset$serie)
```


``` r
# Run detection with temporal fuzzification and non-maximum suppression
detection <- detect(model, dataset$serie, time_tolerance = 8, use_nms = TRUE)
```


``` r
# Show detected change points
print(detection[detection$event, ])
```

```
##     idx event type
## 200 200  TRUE
```


``` r
# Plot the ensemble score over the series
har_ensemble_plot(detection, dataset$serie)
```

![plot of chunk unnamed-chunk-10](fig/15-ensemble-fuzzy-har_ensemble_fuzzy/unnamed-chunk-10-1.png)
