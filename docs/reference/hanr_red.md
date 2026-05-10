# Anomaly and change point detector using RED

Anomaly and change point detection using RED The RED model adjusts to
the time series. Observations distant from the model are labeled as
anomalies. It wraps the EMD model presented in the hht library.

## Usage

``` r
hanr_red(sw_size = 30, noise = 0.001, trials = 5)
```

## Arguments

- sw_size:

  sliding window size (default 30)

- noise:

  noise

- trials:

  trials

## Value

`hanr_red` object

## Examples

``` r
library(daltoolbox)
library(zoo)
#> 
#> Attaching package: ‘zoo’
#> The following objects are masked from ‘package:base’:
#> 
#>     as.Date, as.Date.numeric

#loading the example database
data(examples_anomalies)

#Using simple example
dataset <- examples_anomalies$simple
head(dataset)
#>       serie event
#> 1 1.0000000 FALSE
#> 2 0.9689124 FALSE
#> 3 0.8775826 FALSE
#> 4 0.7316889 FALSE
#> 5 0.5403023 FALSE
#> 6 0.3153224 FALSE

# setting up time series emd detector
model <- hanr_red()

# fitting the model
model <- fit(model, dataset$serie)

detection <- detect(model, dataset$serie)

# filtering detected events
print(detection[(detection$event),])
#>    idx event    type
#> 50  50  TRUE anomaly
```
