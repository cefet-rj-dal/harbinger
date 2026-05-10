# SAX transformation

Symbolic Aggregate approXimation (SAX) discretization of a numeric time
series. The series is z-normalized, quantile-binned, and mapped to an
alphabet of size `alpha`.

## Usage

``` r
trans_sax(alpha)
```

## Arguments

- alpha:

  Integer. Alphabet size (2–26).

## Value

A `trans_sax` transformer object.

## References

- Lin J, Keogh E, Lonardi S, Chiu B (2007). A symbolic representation of
  time series, with implications for streaming algorithms. Data Mining
  and Knowledge Discovery 15, 107–144.

## Examples

``` r
library(daltoolbox)
vector <- 1:52
model <- trans_sax(alpha = 26)
model <- fit(model, vector)
xvector <- transform(model, vector)
print(xvector)
#>  [1] "A" "A" "B" "B" "C" "C" "D" "D" "E" "E" "F" "F" "G" "G" "H" "H" "I" "I" "J"
#> [20] "J" "K" "K" "L" "L" "M" "M" "N" "N" "O" "O" "P" "P" "Q" "Q" "R" "R" "S" "S"
#> [39] "T" "T" "U" "U" "V" "V" "W" "W" "X" "X" "Y" "Y" "Z" "Z"
```
