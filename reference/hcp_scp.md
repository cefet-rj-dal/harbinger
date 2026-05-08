# Seminal change point

Window-based change-point detection that compares two local linear
models fitted on each sliding window: one using the full window and
another using the same window split around its central observation. The
difference between the two residual summaries is used as the change
score.

The method is called "seminal" because the paper defines a seminal point
for each window family, i.e. the central observation used to split the
local regression into two sides. This makes the detector a local family
method based on windows rather than a global segmentation algorithm.

## Usage

``` r
hcp_scp(sw_size = 30)
```

## Arguments

- sw_size:

  Sliding window size.

## Value

`hcp_scp` object

## References

- The seminal change-point paper referenced in
  `Event Detection from Time Series Data`.

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

# Configure the seminal change-point detector
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
