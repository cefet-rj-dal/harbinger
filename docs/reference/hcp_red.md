# Anomaly and change point detector using RED

Anomaly and change point detection using RED The RED model adjusts to
the time series. Observations distant from the model are labeled as
anomalies. It wraps the EMD model presented in the hht library.

## Usage

``` r
hcp_red(
  sw_size = 30,
  noise = 0.001,
  trials = 5,
  red_cp = TRUE,
  volatility_cp = TRUE,
  trend_cp = TRUE
)
```

## Arguments

- sw_size:

  sliding window size (default 30)

- noise:

  noise

- trials:

  trials

- red_cp:

  red change point

- volatility_cp:

  volatility change point

- trend_cp:

  trend change point

## Value

`hcp_red` object

## Examples

``` r
library(daltoolbox)

#loading the example database
data(examples_changepoints)

#Using simple example
dataset <- examples_changepoints$simple
head(dataset)
#>   serie event
#> 1  0.00 FALSE
#> 2  0.25 FALSE
#> 3  0.50 FALSE
#> 4  0.75 FALSE
#> 5  1.00 FALSE
#> 6  1.25 FALSE

# setting up change point method
model <- hcp_red()

# fitting the model
model <- fit(model, dataset$serie)

# execute the detection method
detection <- detect(model, dataset$serie)

# filtering detected events
print(detection[(detection$event),])
#>    idx event        type
#> 51  51  TRUE changepoint
```
