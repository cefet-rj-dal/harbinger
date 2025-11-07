# Time series for anomaly detection

A list of time series designed for anomaly detection tasks.

- simple: simple synthetic series with isolated anomalies.

- contextual: contextual anomalies relative to local behavior.

- trend: synthetic series with trend and anomalies.

- multiple: multiple anomalies.

- sequence: repeated anomalous sequences.

- tt: train-test split synthetic series.

- tt_warped: warped train-test synthetic series.

\#'

## Usage

``` r
data(examples_anomalies)
```

## Format

A list of time series for anomaly detection.

## Source

[Harbinger package](https://github.com/cefet-rj-dal/harbinger)

## References

[Harbinger package](https://github.com/cefet-rj-dal/harbinger)

Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in
Time Series. 1st ed. Cham: Springer Nature Switzerland, 2025.
doi:10.1007/978-3-031-75941-3

## Examples

``` r
data(examples_anomalies)
# Select a simple anomaly series
serie <- examples_anomalies$simple
head(serie)
#>       serie event
#> 1 1.0000000 FALSE
#> 2 0.9689124 FALSE
#> 3 0.8775826 FALSE
#> 4 0.7316889 FALSE
#> 5 0.5403023 FALSE
#> 6 0.3153224 FALSE
```
