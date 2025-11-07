# Time series for change point detection

A list of time series for change point experiments.

- simple: simple synthetic series with one change point.

- sinusoidal: sinusoidal pattern with a regime change.

- incremental: gradual change in mean/variance.

- abrupt: abrupt level shift.

- volatility: variance change.

\#'

## Usage

``` r
data(examples_changepoints)
```

## Format

A list of time series for change point detection.

## Source

[Harbinger package](https://github.com/cefet-rj-dal/harbinger)

## References

[Harbinger package](https://github.com/cefet-rj-dal/harbinger)

Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in
Time Series. 1st ed. Cham: Springer Nature Switzerland, 2025.
doi:10.1007/978-3-031-75941-3

## Examples

``` r
data(examples_changepoints)
# Select a simple change point series
serie <- examples_changepoints$simple
head(serie)
#>   serie event
#> 1  0.00 FALSE
#> 2  0.25 FALSE
#> 3  0.50 FALSE
#> 4  0.75 FALSE
#> 5  1.00 FALSE
#> 6  1.25 FALSE
```
