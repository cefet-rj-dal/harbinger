# Seminal change point

Change-point detection is related to event/trend change detection.
Seminal change point detects change points based on deviations of linear
regression models adjusted with and without a central observation in
each sliding window \<10.1145/312129.312190\>.

## Usage

``` r
hcp_scp(sw_size = 30)
```

## Arguments

- sw_size:

  Sliding window size

## Value

`hcp_scp` object

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in
  Time Series. 1st ed. Cham: Springer Nature Switzerland, 2025.
  doi:10.1007/978-3-031-75941-3

## Examples

``` r
library(daltoolbox)

# Load change-point example data
data(examples_changepoints)

# Use a simple example
dataset <- examples_changepoints$simple
head(dataset)
#>   serie event
#> 1  0.00 FALSE
#> 2  0.25 FALSE
#> 3  0.50 FALSE
#> 4  0.75 FALSE
#> 5  1.00 FALSE
#> 6  1.25 FALSE

# Configure seminal change-point detector
model <- hcp_scp()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected change points
print(detection[(detection$event),])
#>    idx event        type
#> 50  50  TRUE changepoint
```
