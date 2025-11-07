# Time series for motif/discord discovery

A list of time series for motif (repeated patterns) and discord (rare
patterns) discovery.

- simple: simple synthetic series with motifs.

- mitdb100: sample from MIT-BIH arrhythmia database (record 100).

- mitdb102: sample from MIT-BIH arrhythmia database (record 102).

\#'

## Usage

``` r
data(examples_motifs)
```

## Format

A list of time series for motif discovery.

## Source

[Harbinger package](https://github.com/cefet-rj-dal/harbinger)

## References

[Harbinger package](https://github.com/cefet-rj-dal/harbinger)

Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in
Time Series. 1st ed. Cham: Springer Nature Switzerland, 2025.
doi:10.1007/978-3-031-75941-3

## Examples

``` r
data(examples_motifs)
# Select a simple motif series
serie <- examples_motifs$simple
head(serie)
#>       serie event
#> 1 1.0000000 FALSE
#> 2 0.9939124 FALSE
#> 3 0.9275826 FALSE
#> 4 0.8066889 FALSE
#> 5 0.6403023 FALSE
#> 6 0.4403224 FALSE
```
