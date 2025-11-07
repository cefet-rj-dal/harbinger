# Time series for event detection

A list of time series for demonstrating event detection tasks.

- nonstationarity: synthetic nonstationary time series.

- global_temperature_yearly: yearly global temperature.

- global_temperature_monthly: monthly global temperature.

- multidimensional: multivariate series with a change point.

- seattle_week: Seattle weekly temperature in 2019.

- seattle_daily: Seattle daily temperature in 2019.

\#'

## Usage

``` r
data(examples_harbinger)
```

## Format

A list of time series.

## Source

[Harbinger package](https://github.com/cefet-rj-dal/harbinger)

## References

[Harbinger package](https://github.com/cefet-rj-dal/harbinger)

Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in
Time Series. 1st ed. Cham: Springer Nature Switzerland, 2025.
doi:10.1007/978-3-031-75941-3

## Examples

``` r
data(examples_harbinger)
# Inspect a series (Seattle daily temperatures)
serie <- examples_harbinger$seattle_daily
head(serie)
#> # A tibble: 6 × 5
#>       i serie   min   max event
#>   <int> <dbl> <dbl> <dbl> <lgl>
#> 1     1  3.28 0.556  6.11 FALSE
#> 2     2  3.78 0      8.33 FALSE
#> 3     3  9    6.11  13.3  FALSE
#> 4     4  9.44 8.33  11.1  FALSE
#> 5     5  7.83 5.56  10.6  FALSE
#> 6     6  5.72 2.78   8.89 FALSE
```
